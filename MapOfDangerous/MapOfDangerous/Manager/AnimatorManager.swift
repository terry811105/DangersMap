//
//  AnimatorManager.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/19.
//

import Foundation

import UIKit

class AnimatorManager {
    
    private init(){}
    
    static let shared = AnimatorManager()
    
    func runTest(view: UIView){
        
        let animator2 = UIViewPropertyAnimator(duration: 8, curve: .linear) {
            
            view.transform = CGAffineTransform(translationX: -500, y: 0)
            
        }
        animator2.addAnimations {
            
           // view.transform = view.transform.translatedBy(x: -100, y: 0)
        }
        animator2.addCompletion{ _ in
            
            view.transform = CGAffineTransform.identity
            view.transform = view.transform.translatedBy(x: 150, y: 0)
            self.runTest(view: view)
            
        }
        
        animator2.startAnimation()
      
    }
    
    func disappearAnimation(view: UIView){
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .allowUserInteraction){
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                view.alpha = 0.5
            }
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 1){
                view.transform = CGAffineTransform(scaleX: 2, y: 2)
                view.alpha = 0
            }
           
        }
        
    }
    
    func runAnimation1(view: UIView){
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear) {
            view.alpha = 0.1
            view.transform = CGAffineTransform(translationX: 10, y: 10).scaledBy(x: 2, y: 2).rotated(by: CGFloat.pi / 180 * 90)
        }
        animator.addCompletion{ _ in
            view.alpha = 1.0
            view.transform = CGAffineTransform.identity
            
        }
        animator.startAnimation(afterDelay: 0)
    }
    
    func runAnimation2(view: UIView) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1,
                                                       delay: 1,
                                                       options: .curveLinear,
                                                       animations: {
            view.alpha = 0.1
            view.transform = CGAffineTransform(translationX: 10, y: 10).scaledBy(x: 2, y: 2).rotated(by: CGFloat.pi / 180 * 90)
        }, completion: { _ in
            view.alpha = 1.0
            view.transform = CGAffineTransform.identity
        })
    }
    
    func runBounce1(view: UIView) {
        let animator1 = UIViewPropertyAnimator.init(duration: 0.2, curve: .linear){
            view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
        let animator2 = UIViewPropertyAnimator.init(duration: 0.2, curve: .linear)  {
            view.transform = CGAffineTransform.identity
        }
        animator1.addCompletion{ _ in
            animator2.startAnimation()
        }
        animator1.startAnimation()
    }
    
    func runBounce2(view: UIView) {
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .allowUserInteraction){
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 1){
                view.transform = CGAffineTransform.identity
            }
        }
    }
    
    func zoomIn(view: UIView, scale: CGFloat, distanceX: CGFloat, distanceY: CGFloat){
        let animator = UIViewPropertyAnimator.init(duration: 0.3, curve: .linear){
            
//            view.transform = CGAffineTransform(translationX: distanceX, y: distanceY).scaledBy(x: scale, y: scale)
            
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
            
        }
        animator.startAnimation()
    }
    
    
}
