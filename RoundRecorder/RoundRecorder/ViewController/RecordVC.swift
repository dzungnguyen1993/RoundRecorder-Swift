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
    }

    @IBAction func stopRecord(_ sender: UIButton) {
        recordView.stopRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recordView.startSession()
    }
}
