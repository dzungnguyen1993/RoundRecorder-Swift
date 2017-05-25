//
//  Recorder.swift
//  RoundRecorder
//
//  Created by Thanh-Dung Nguyen on 5/5/17.
//  Copyright © 2017 Dzung Nguyen. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

protocol RecorderDelegate: class {
    func didFinishExportVideo(atUrl url: URL)
}

class Recorder: AVCaptureVideoDataOutput {
    typealias RecordCompletion = () -> Swift.Void
    
    var writers = [AVAssetWriter?]()
    var inputs = [AVAssetWriterInput?]()
    var isSavingVideo = false
    var videoOrder = 0
    var lastRecordTimestamp = 0
    weak var delegate: RecorderDelegate?
    
    override init() {
        super.init()
        let queue = DispatchQueue(label: "com.invasivecode.videoQueue")
        self.setSampleBufferDelegate(self, queue: queue)
        
        self.reset()
    }
    
    // MARK: Init asset writers
    func initWriters() {
        do {
            self.writers = [AVAssetWriter?](repeating: nil, count: Constant.NUMBER_OF_VIDEO)
            self.inputs = [AVAssetWriterInput?](repeating: nil, count: Constant.NUMBER_OF_VIDEO)
            for i in 0..<Constant.NUMBER_OF_VIDEO {
                try self.initWriter(order: i)
            }
        } catch {
            print(error)
        }
        
    }
    
    func reset() {
        self.initWriters()
        self.isSavingVideo = false
        self.lastRecordTimestamp = 0
        self.videoOrder = 0
    }
    
    func initWriter(order: Int) throws {
        do {
            if FileManager.default.fileExists(atPath: Utils.getVideoUrl(order: order).path) == true {
                try FileManager.default.removeItem(at: Utils.getVideoUrl(order: order))
            }
        } catch {
            print(error)
        }
        do {
            let assetWriter = try AVAssetWriter(outputURL: Utils.getVideoUrl(order: order), fileType: AVFileTypeQuickTimeMovie)
            
            let outputSettings = [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : NSNumber(value: Constant.VIDEO_WIDTH), AVVideoHeightKey : NSNumber(value: Constant.VIDEO_HEIGHT)] as [String : Any]

            let assetWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: outputSettings)
            assetWriterInput.expectsMediaDataInRealTime = true
            
            assetWriter.add(assetWriterInput)
            
            self.writers[order] = assetWriter
            self.inputs[order] = assetWriterInput
            
        } catch {
            throw error
        }
    }

    
    func stopRecord() {
        // save current video
        isSavingVideo = true
        self.saveVideo(order: videoOrder) {
            self.startProcessVideo(lastVideoOrder: self.videoOrder)
        }
    }
}

// MARK: Save Video
extension Recorder: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if isSavingVideo == true {
            return
        }
        
        if lastRecordTimestamp == 0 {
            lastRecordTimestamp = Int(Date().timeIntervalSince1970)
        }
        
        // save buffer to file
        do {
            try self.save(sampleBuffer: sampleBuffer)
        } catch {
            
        }
        
        // save video
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        if (currentTimestamp - lastRecordTimestamp >= Constant.VIDEO_LENGTH) {
            // save current video
            self.saveVideo(order: videoOrder) {

            }
            
            // switch writer
            videoOrder += 1
            if videoOrder >= writers.count {
                videoOrder = 0
            }

            lastRecordTimestamp = currentTimestamp;
        }
    }
    
    func save(sampleBuffer: CMSampleBuffer!) throws {
        let assetWriter = writers[videoOrder]!
        let input = inputs[videoOrder]!
        
        if (CMSampleBufferDataIsReady(sampleBuffer)) {
            if (assetWriter.status != .writing && assetWriter.status != .cancelled && assetWriter.status != .failed) {
                print("Start writing")
                let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                assetWriter.startWriting()
                assetWriter.startSession(atSourceTime: startTime)
            }
            if (input.isReadyForMoreMediaData == true)
            {
                input.append(sampleBuffer)
            }
        }
    }
    
    func saveVideo(order: Int, completionHandler completion: @escaping RecordCompletion) {
        let writer = writers[order]!
        let input = inputs[order]!
        print("Save video number \(order)")
        input.markAsFinished()
        
        writer.finishWriting {
            if writer.error != nil {
//                print(writer.error)
                return
            }
            
            let fileManager = FileManager.default
            
            do {
                if fileManager.fileExists(atPath: Utils.getRecordUrl(order: order).path) == true {
                    try fileManager.removeItem(at: Utils.getRecordUrl(order: order))
                }
                try fileManager.moveItem(at: Utils.getVideoUrl(order: order), to: Utils.getRecordUrl(order: order))
                
                // reinit asset writer
                try self.initWriter(order: order)
                
                completion()
            } catch {
                print(error)
            }
        }
    }
}

// MARK: Video Processing
extension Recorder {
    func startProcessVideo(lastVideoOrder: Int) {
        var listVideoIds = [Int]()
        var currentDuration: Double = 0
        var currentIds = lastVideoOrder
        
        while currentDuration < Double(Constant.FINAL_LENGTH) && listVideoIds.count < Constant.NUMBER_OF_VIDEO {
            let videoPath = Utils.getRecordUrl(order: currentIds)
            
            if FileManager.default.fileExists(atPath: videoPath.path) == false {
                break
            }
            
            let duration = self.getDuration(fileURL: videoPath)
            
            currentDuration += duration
            listVideoIds.append(currentIds)
            
            currentIds -= 1
            if currentIds < 0 {
                currentIds = Constant.NUMBER_OF_VIDEO - 1
            }
        }

        // merge video
        self.mergeVideo(listVideoIds: listVideoIds.reversed())
    }
    
    func mergeVideo(listVideoIds: [Int]) {
        // now get the list of video to merge
        // let's merge video
        let mixComposition = AVMutableComposition()
        let firstTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        var lastDuration: CMTime = kCMTimeZero
        do {
            for i in 0..<listVideoIds.count {
                let url = Utils.getRecordUrl(order: listVideoIds[i])
                print(url.path)
                let asset = AVAsset(url: url)
                try firstTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), of: asset.tracks(withMediaType: AVMediaTypeVideo)[0], at: lastDuration)
                
                lastDuration = lastDuration + asset.duration
            }
        } catch {
            return
        }


        let resultUrl = Utils.getResult()
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: resultUrl.path) {
            do {
                try fileManager.removeItem(at: resultUrl)
            } catch {
                return
            }
        }

        let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = resultUrl
        exporter?.outputFileType = AVFileTypeQuickTimeMovie
        exporter?.shouldOptimizeForNetworkUse = true

        let stopTime = CMTimeGetSeconds(mixComposition.duration)
        let startTime = stopTime - Double(Constant.FINAL_LENGTH)

        let start = CMTimeMakeWithSeconds(startTime, mixComposition.duration.timescale)
        let end = CMTimeMakeWithSeconds(stopTime, mixComposition.duration.timescale)

        let range = CMTimeRangeMake(start, CMTimeSubtract(end, start))
        exporter?.timeRange = range

        exporter?.exportAsynchronously {
            self.delegate?.didFinishExportVideo(atUrl: resultUrl)
        }
    }
    
    func getDuration(fileURL: URL) -> Double {
        let asset = AVAsset(url: fileURL)
        return CMTimeGetSeconds(asset.duration)
    }
}
