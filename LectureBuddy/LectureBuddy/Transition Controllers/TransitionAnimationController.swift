//
//  TransitionAnimationController.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 12/16/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit

class TransitionAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.5
    var presenting = true
    var originFrame = CGRect.zero

    init(presenting: Bool) {
        self.presenting = presenting
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    // Check out the link to see how this works : https://www.raywenderlich.com/173576/ios-animation-tutorial-custom-view-controller-presentation-transitions-3
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! HomeTableViewController
//        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
//        transitionContext.containerView.addSubview(toViewController.view)
//        toViewController.view.alpha = 0.0
//        UIView.animate(withDuration: 0.35, animations: {
//            toViewController.view.alpha = 1.0
//        }, completion: { (finished) in
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        })
        
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!

        let newRecordingView = presenting ? toView : fromView

//        print(originFrame.origin.x)
//        print(originFrame.origin.y)
        
        let initialFrame = presenting ? originFrame : newRecordingView.frame
        let finalFrame =   presenting ? newRecordingView.frame : originFrame
        
        let xScaleFactor = presenting ?
            initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting ?
            initialFrame.height / finalFrame.height :
            finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        if presenting {
            newRecordingView.transform = scaleTransform
            newRecordingView.center = CGPoint(
                x: initialFrame.midX,
                y: initialFrame.midY)
            newRecordingView.clipsToBounds = true
        }
        
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: newRecordingView)
        
        
        let springDamping:CGFloat = self.presenting ? 0.75 : 1.00
        
        //newRecordingView.layer.speed = 100
        //containerView.
        
        UIView.animate(withDuration: self.duration, delay:0.0,
                       usingSpringWithDamping: springDamping,
                       initialSpringVelocity: 0.0,
                       options: .preferredFramesPerSecond60,
                       animations: {
                        newRecordingView.layer.cornerRadius = 40
                        newRecordingView.transform = self.presenting ? CGAffineTransform.identity : scaleTransform
                        newRecordingView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        
//        UIView.animate(withDuration: duration, animations: {
//            <#code#>
//        }) { (<#Bool#>) in
//            <#code#>
//        }
//        UIView.animate(withDuration: duration, delay:0.0,
//                       usingSpringWithDamping: 0.0, initialSpringVelocity: 0.0,
//                       animations: {
//                        newRecordingView.transform = self.presenting ?
//                            CGAffineTransform.identity : scaleTransform
//                        newRecordingView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
//        },
//                       completion: { _ in
//                        transitionContext.completeTransition(true)
//        }
//        )
    }
}
