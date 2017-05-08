//
//  Utils.swift
//  RoundRecorder
//
//  Created by Thanh-Dung Nguyen on 5/5/17.
//  Copyright © 2017 Dzung Nguyen. All rights reserved.
//

import UIKit

class Utils {
    static func getVideoUrl(order: Int) -> URL {
        let path = NSTemporaryDirectory().stringByAppendingPathComponent(path: "video\(order).mp4")
        
        return URL(fileURLWithPath: path)
    }
    
    static func getRecordUrl(order: Int) -> URL {
        let path = NSTemporaryDirectory().stringByAppendingPathComponent(path: "record\(order).mp4")
        
        return URL(fileURLWithPath: path)
    }
    
    static func getResult() -> URL {
        let path = NSTemporaryDirectory().stringByAppendingPathComponent(path: "result.mp4")
        
        return URL(fileURLWithPath: path)
    }
    
    static func moveItem(atUrl: URL, toUrl: URL) {
        do {
            try FileManager.default.moveItem(at: atUrl, to: toUrl)
        } catch {
            
        }
    }
    
    static func getResultFolder() -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = documentsPath.stringByAppendingPathComponent(path: "result")
        
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        if fileManager.fileExists(atPath: path, isDirectory: &isDir) == false {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                
            }
        }
        
        return path
    }
}

extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
}
