//
//  ViewController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 4/21/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var openMapBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EventDataManager.RefreshEventData()
    }

    @IBAction func OpenMap(_ sender: UIButton) {
        performSegue(withIdentifier: "openMapSegue", sender: self)
    }
}

