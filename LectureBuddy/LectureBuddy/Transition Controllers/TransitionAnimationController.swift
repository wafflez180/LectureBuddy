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

        // 1. Set up transitionViews
    
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!

        let newRecordingView = presenting ? toView : fromView

        // 2. Set up initial frame, final frame, and CGAffineTransform for animation
        
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
        
        // Set up the final corner radius so when scaling/animating up,
        // it will have the same corner radius as the device
        // WHY: Implemented specifically to make iPhone X users have a better more consistent UI/UX
        
        var finalCornerRadius:CGFloat = 0.0
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                print("iPhone X")
                finalCornerRadius = 40.0
            default:
                print("Every other iPhone/iPad")
                finalCornerRadius = 0.0
            }
        }
        
        // Animate/scale/transition
        
        let springDamping:CGFloat = self.presenting ? 0.75 : 1.00
        UIView.animate(withDuration: self.duration, delay:0.0,
                       usingSpringWithDamping: springDamping,
                       initialSpringVelocity: 0.0,
                       options: .preferredFramesPerSecond60,
                       animations: {
                        
                        newRecordingView.layer.cornerRadius = finalCornerRadius
                        newRecordingView.transform = self.presenting ? CGAffineTransform.identity : scaleTransform
                        newRecordingView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
