//
//  RecordView.swift
//  RoundRecorder
//
//  Created by Thanh-Dung Nguyen on 5/5/17.
//  Copyright © 2017 Dzung Nguyen. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class RecordView: UIView {

    @IBOutlet var contentView: UIView!
    var recorder: Recorder!
    
    lazy var cameraSession: AVCaptureSession = {
        let s = AVCaptureSession()
        s.sessionPreset = AVCaptureSessionPresetHigh
        return s
    }()
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview =  AVCaptureVideoPreviewLayer(session: self.cameraSession)
        preview?.bounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        preview?.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        preview?.videoGravity = AVLayerVideoGravityResize
        return preview!
    }()

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        Bundle.main.loadNibNamed("RecordView", owner: self, options: nil)
        self.addSubview(self.contentView)
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self.contentView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self.contentView]))
        
        self.initCamera()
    }
    
    func initCamera() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) as AVCaptureDevice
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            cameraSession.beginConfiguration()
            
            if (cameraSession.canAddInput(deviceInput) == true) {
                cameraSession.addInput(deviceInput)
            }
            
            recorder = Recorder()
            recorder.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA as UInt32)]
            recorder.alwaysDiscardsLateVideoFrames = true
            
            if (cameraSession.canAddOutput(recorder) == true) {
                cameraSession.addOutput(recorder)
            }
            
            cameraSession.commitConfiguration()
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
    }

    func startSession() {
        self.layer.addSublayer(previewLayer)
        
        let connection = recorder.connection(withMediaType: AVMediaTypeVideo)
        connection?.videoOrientation = .portrait
        
        cameraSession.startRunning()
    }
    
    func stopRecord() {
        cameraSession.stopRunning()
        recorder.stopRecord()
    }
}
