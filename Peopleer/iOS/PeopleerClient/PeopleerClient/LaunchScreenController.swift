//
//  LaunchScreenController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 4/22/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

class LaunchScreenController : UIViewController {
    
    @IBOutlet weak var logo: UILabel!
    
    let fadeDuration = 1.1
    
    override func viewDidLoad() {
        self.logo.alpha = 0
        
        // Fade in the logo
        UIView.animate(withDuration: self.fadeDuration, delay: 0.5, animations: { () -> Void in
            self.logo.alpha = 1
        }) { (Bool) -> Void in
            // Fade out the logo
            UIView.animate(withDuration: self.fadeDuration, delay: 0.2, animations: { () -> Void in
                self.logo.alpha = 0
            }) { (success) in
                // Transition to the main menu screen
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateInitialViewController()
                UIApplication.shared.keyWindow?.rootViewController = vc
            }
        }
    }
    
    
}
