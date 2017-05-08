//
//  RecordVC.swift
//  RoundRecorder
//
//  Created by Thanh-Dung Nguyen on 5/5/17.
//  Copyright © 2017 Dzung Nguyen. All rights reserved.
//

import UIKit

class RecordVC: UIViewController {

    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var recordView: RecordView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        recordView.delegate = self
    }

    @IBAction func stopRecord(_ sender: UIButton) {
        recordView.stopRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recordView.startSession()
    }
}

extension RecordVC: RecordViewDelegate {
    func didFinishExportVideo(atUrl url: URL) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Notice", message: "Enter video name", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            
            self.saveVideo(atUrl: url, withNewName: (textField?.text)!)
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveVideo(atUrl url: URL, withNewName newName: String) {
        let resultFolder = Utils.getResultFolder()
        let filePath = resultFolder.stringByAppendingPathComponent(path: newName + ".mp4")
        
        Utils.moveItem(atUrl: url, toUrl: URL(fileURLWithPath: filePath))
        
        recordView.restart()
    }
}
