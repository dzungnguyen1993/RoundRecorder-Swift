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
    var timer: Timer!
    
    var interactor:Interactor = Interactor()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        recordView.delegate = self
        
        // add pan gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
        self.view.addGestureRecognizer(panGesture)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector (timerFire), userInfo: nil, repeats: true)
    }
    
    func timerFire() {
        if btnRecord.tag == 0 {
            btnRecord.tag = 1
            btnRecord.setImage(UIImage(named: "Restart-Green"), for: UIControlState.normal)
        } else {
            btnRecord.tag = 0
            btnRecord.setImage(UIImage(named: "Restart-Red"), for: UIControlState.normal)
        }
    }
    
    func stopTimer() {
        timer.invalidate()
    }

    @IBAction func stopRecord(_ sender: UIButton) {
        stopTimer()
        recordView.stopRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        recordView.startSession()
        self.startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopTimer()
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

extension RecordVC {
    func handleGesture(gesture: UIPanGestureRecognizer) {
        let vc = ListVC(nibName: "ListVC", bundle: nil)
        
        vc.transitioningDelegate = self
        vc.interactor = interactor
        
        self.present(vc, animated: true, completion: nil)
        
//        
//        let percentThreshold:CGFloat = 0.3
//        
//        // convert y-position to downward pull progress (percentage)
//        let translation = gesture.translation(in: view)
//        let verticalMovement = translation.y / view.bounds.height
//        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
//        let downwardMovementPercent = fminf(downwardMovement, 1.0)
//        let progress = CGFloat(downwardMovementPercent)
//        
//        
//        switch gesture.state {
//        case .began:
//            interactor.hasStarted = true
////            dismissViewControllerAnimated(true, completion: nil)
//            let vc = ListVC(nibName: "ListVC", bundle: nil)
//            self.present(vc, animated: true, completion: nil)
//        case .changed:
//            interactor.shouldFinish = progress > percentThreshold
//            interactor.update(progress)
//        case .cancelled:
//            interactor.hasStarted = false
//            interactor.cancel()
//        case .ended:
//            interactor.hasStarted = false
//            interactor.shouldFinish
//                ? interactor.finish()
//                : interactor.cancel()
//        default:
//            break
//        }
    }
}

extension RecordVC: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
