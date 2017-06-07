//
//  SwipeSegue.swift
//  CustomSegue
//
//  Created by Ju on 2017/6/4.
//  Copyright © 2017年 Ju. All rights reserved.
//

import UIKit

protocol ViewHeadabel {
    var animatedViewFrame: CGRect { get }
}

protocol ViewSwipeable {
    var direction: UISwipeGestureRecognizerDirection { get }
}

class SwipeSegue: UIStoryboardSegue {
    
    override func perform() {
        destination.transitioningDelegate = self
        super.perform()
    }

}

extension SwipeSegue: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HeadPresentAnimator()
    }
        
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HeadDismissAnimator()
    }
}

class HeadPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: .from)?.targetViewController
        let toView = transitionContext.view(forKey: .to)

        let toViewController = transitionContext.viewController(forKey: .to)
        
        if toView != nil {
            transitionContext.containerView.addSubview(toView!)
        }
        
        var startFrame: CGRect = .zero
        if let fromViewController = fromViewController as? ViewHeadabel {
            startFrame = fromViewController.animatedViewFrame
        } else {
            print("Waring: from view controller \(String(describing: fromViewController)) does not conform ViewHeadable")
        }
        
        toView?.frame = startFrame
        toView?.layoutIfNeeded()
        
        let duration = transitionDuration(using: transitionContext)
        let finalFrame = transitionContext.finalFrame(for: toViewController!)
        
        UIView.animate(withDuration: duration,
                       animations: {
                        
                        toView?.frame = finalFrame
                        toView?.layoutIfNeeded()
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
}

class HeadDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        if fromView != nil, toView != nil {
            transitionContext.containerView.insertSubview(toView!, belowSubview: fromView!)
        }
        
        let duration = transitionDuration(using: transitionContext)
        var finalFrame = transitionContext.finalFrame(for: fromViewController!)
        
        // --------------------------------------------------------
        // for sheet type of segue
        let gap = (UIWindow().bounds.width - finalFrame.width) / 2
        finalFrame.origin.x = gap
        // --------------------------------------------------------
        
        if let _ = fromViewController as? ViewSwipeable {
            finalFrame.origin.y = UIWindow().bounds.height
        }
        
        UIView.animate(withDuration: duration,
                       animations: {
                        fromView?.frame = finalFrame
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
}


extension UIViewController {
    
    var targetViewController: UIViewController {
        if let tvc = self as? UINavigationController {
            return tvc.topViewController!
        } else {
            return self
        }
    }
}
