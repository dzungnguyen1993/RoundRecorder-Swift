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
}

extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
}
