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

class Recorder: AVCaptureVideoDataOutput, AVCaptureVideoDataOutputSampleBufferDelegate {
    override init() {
        super.init()
        let queue = DispatchQueue(label: "com.invasivecode.videoQueue")
        self.setSampleBufferDelegate(self, queue: queue)
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // Here you collect each frame and process it
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // Here you can count how many frames are dopped
    }
}
