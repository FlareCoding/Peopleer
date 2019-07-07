//
//  UIUtils.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 4/29/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import Foundation
import UIKit

class UIUtils {
    
    static func showAlert(view: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        view.present(alert, animated: true, completion: nil)
    }
    
    static func showAlert(view: UIViewController, title: String, message: String, actionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) in
            actionHandler()
        }))
        view.present(alert, animated: true, completion: nil)
    }
    
    static func showConfirmAlert(view: UIViewController, title: String, message: String, actionHandler: @escaping (_ result: Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) in
            actionHandler(false)
        }))
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) in
            actionHandler(true)
        }))
        view.present(alert, animated: true, completion: nil)
    }
    
    static func currentTopViewController() -> UIViewController {
        var topVC: UIViewController? = UIApplication.shared.delegate?.window?!.rootViewController
        while ((topVC?.presentedViewController) != nil) {
            topVC = topVC?.presentedViewController
        }
        return topVC!
    }
    
    static func addCoverLayer(view: UIView, layerColor: UIColor, layerOpacity: Float) {
        let coverLayer = CALayer()
        coverLayer.frame = view.bounds;
        coverLayer.backgroundColor = layerColor.cgColor
        view.layer.addSublayer(coverLayer)
        coverLayer.opacity = layerOpacity
    }
    
    static func springAnimate(view: UIView, duration: CGFloat, springScaleFactor: CGFloat) {
        UIView.animate(withDuration: TimeInterval(duration / 2.0), delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            view.transform = CGAffineTransform(scaleX: springScaleFactor, y: springScaleFactor)
        }) { (_) in
            UIView.animate(withDuration: TimeInterval(duration / 2.0), delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
}
