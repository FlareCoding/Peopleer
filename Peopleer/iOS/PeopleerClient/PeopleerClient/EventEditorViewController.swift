//
//  EventEditorController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 4/30/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

class EventEditorViewController: UIViewController {
    
    var event = Event(title: "[EVENT]", latitude: 0, longitude: 0)
    
    @IBOutlet weak var latitudeTextfield: UITextField!
    @IBOutlet weak var longitudeTextfield: UITextField!
    @IBOutlet weak var titleTextfield: UITextField!
    
    var returnViewAlertMessages = [Int : [String]]()
    var returnCode = 0
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReturnToMapKitFromEventEditorSegue" && returnCode != 0 {
            let vc = segue.destination as! MapViewController
            vc.viewLoadedAlertTitle = returnViewAlertMessages[returnCode]![0]
            vc.viewLoadedAlertMsg = returnViewAlertMessages[returnCode]![1]
        }
        
        returnCode = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeReturnCodes()
        self.setupHideKeyboardOnTap()
        
        latitudeTextfield.text = String(describing: event.latitude)
        longitudeTextfield.text = String(describing: event.longitude)
        titleTextfield.text = String(describing: event.title)
    }
    
    @IBAction func CreateEvent(_ sender: UIButton) {
        sender.isEnabled = false
        
        var lat: Double? { return Double(latitudeTextfield.text!) }
        var long: Double? { return Double(longitudeTextfield.text!) }
        
        self.event = Event(
            title: titleTextfield.text ?? "Title",
            latitude: lat ?? 0,
            longitude: long ?? 0
        )
        
        EventDataManager.shared.CreateNewEvent(view: self, event: self.event) { succeeded in
            sender.isEnabled = true
            
            if succeeded {
                self.returnCode = 1 // event successfully created
                self.performSegue(withIdentifier: "ReturnToMapKitFromEventEditorSegue", sender: nil)
            }
        }
    }
    
    private func initializeReturnCodes() {
        returnViewAlertMessages = [
            1: ["Success", "Successfully created event \(event.title)"]
        ]
    }
}

extension UIViewController {
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }
    
    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}
