//
//  ListVC.swift
//  RoundRecorder
//
//  Created by Thanh-Dung Nguyen on 5/17/17.
//  Copyright © 2017 Dzung Nguyen. All rights reserved.
//

import UIKit

class ListVC: UIViewController {

    var interactor:Interactor? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // add pan gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
        self.view.addGestureRecognizer(panGesture)
    }

}

extension ListVC {
    func handleGesture(gesture: UIPanGestureRecognizer) {
        let percentThreshold:CGFloat = 0.3
        
        // convert y-position to downward pull progress (percentage)
        let translation = gesture.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        
        switch gesture.state {
        case .began:
            interactor.hasStarted = true
            self.dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
}
