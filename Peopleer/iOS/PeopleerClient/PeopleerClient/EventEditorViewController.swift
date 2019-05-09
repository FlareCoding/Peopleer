//
//  EventEditorController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 4/30/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

enum EventEditingMode {
    case CreateEvent
    case EditEvent
}

class EventEditorViewController: UIViewController, UITextFieldDelegate {
    
    var event = Event()
    private var selectedEventCopy = Event()
    
    @IBOutlet weak var latitudeTextfield: UITextField!
    @IBOutlet weak var longitudeTextfield: UITextField!
    @IBOutlet weak var titleTextfield: UITextField!
    
    @IBOutlet weak var CreateEventButton: UIButton!
    @IBOutlet weak var ChangeEventButton: UIButton!
    @IBOutlet weak var DeleteEventButton: UIButton!
    
    private struct ReturnCodes {
        static let Default          = 0
        static let EventCreated     = 1
        static let EventDeleted     = 2
        static let EventModified    = 3
    }
    
    var startupMode = EventEditingMode.CreateEvent
    
    var returnViewAlertMessages = [Int : [String]]()
    var returnCode = ReturnCodes.Default
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReturnToMapKitFromEventEditorSegue" && returnCode != 0 {
            let vc = segue.destination as! MapViewController
            vc.viewLoadedAlertTitle = returnViewAlertMessages[returnCode]![0]
            vc.viewLoadedAlertMsg = returnViewAlertMessages[returnCode]![1]
        }
        
        returnCode = ReturnCodes.Default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedEventCopy = event // preserving a copy of selected event
        
        self.initializeReturnCodes()
        
        self.latitudeTextfield.delegate = self
        self.longitudeTextfield.delegate = self
        self.titleTextfield.delegate = self
        
        initializeViewBasedOnStartupMode()
        
        latitudeTextfield.text = String(describing: event.latitude)
        longitudeTextfield.text = String(describing: event.longitude)
        titleTextfield.text = String(describing: event.title)
    }
    
    
    @IBAction func TitleTextfieldValueChanged(_ sender: UITextField) {
        event.title = sender.text ?? "Title"
    }
    
    @IBAction func LatitudeTextfieldValueChanged(_ sender: UITextField) {
        event.latitude = Double(sender.text ?? "0.0") ?? 0.0
    }
    
    @IBAction func LongitudeTextfieldValueChanged(_ sender: UITextField) {
        event.longitude = Double(sender.text ?? "0.0") ?? 0.0
    }
    
    @IBAction func CreateEvent(_ sender: UIButton) {
        sender.isEnabled = false
        
        event.title = titleTextfield.text ?? "Title"
        event.latitude = Double(latitudeTextfield.text ?? "0.0") ?? 0.0
        event.longitude = Double(longitudeTextfield.text ?? "0.0") ?? 0.0
        
        EventDataManager.shared.CreateNewEvent(view: self, event: self.event) { succeeded in
            sender.isEnabled = true
            
            if succeeded {
                self.returnCode = ReturnCodes.EventCreated // event successfully created
                self.performSegue(withIdentifier: "ReturnToMapKitFromEventEditorSegue", sender: nil)
            }
        }
    }
    
    @IBAction func ChangeEvent(_ sender: UIButton) {
        sender.isEnabled = false
        
        event.title = titleTextfield.text ?? "Title"
        event.latitude = Double(latitudeTextfield.text ?? "0.0") ?? 0.0
        event.longitude = Double(longitudeTextfield.text ?? "0.0") ?? 0.0
        
        EventDataManager.shared.ModifyEvent(eventToModify: selectedEventCopy, view: self, newEventData: event) { succeeded in
            sender.isEnabled = true
            
            if succeeded {
                self.returnCode = ReturnCodes.EventModified // event successfully changed
                self.performSegue(withIdentifier: "ReturnToMapKitFromEventEditorSegue", sender: nil)
            }
        }
    }
    
    @IBAction func DeleteEvent(_ sender: UIButton) {
        sender.isEnabled = false
        
        EventDataManager.shared.DeleteEvent(event: event, view: self) { succeeded in
            sender.isEnabled = true
            
            if succeeded {
                self.returnCode = ReturnCodes.EventDeleted // event successfully deleted
                self.performSegue(withIdentifier: "ReturnToMapKitFromEventEditorSegue", sender: nil)
            }
        }
    }
    
    private func initializeReturnCodes() {
        returnViewAlertMessages = [
            ReturnCodes.EventCreated:   ["Event Created",   "Successfully created event"],
            ReturnCodes.EventDeleted:   ["Event Deleted",   "Successfully deleted event"],
            ReturnCodes.EventModified:  ["Event Modified",  "Successfully modified event"]
        ]
    }
    
    private func initializeViewBasedOnStartupMode() {
        if startupMode == .CreateEvent {
            CreateEventButton.isEnabled = true
            CreateEventButton.isHidden = false
            
            ChangeEventButton.isEnabled = false
            ChangeEventButton.isHidden = true
            
            DeleteEventButton.isEnabled = false
            DeleteEventButton.isHidden = true
        }
        else if startupMode == .EditEvent {
            CreateEventButton.isEnabled = false
            CreateEventButton.isHidden = true
            
            ChangeEventButton.isEnabled = true
            ChangeEventButton.isHidden = false
            
            DeleteEventButton.isEnabled = true
            DeleteEventButton.isHidden = false
            
            ChangeEventButton.frame.origin = CreateEventButton.frame.origin
            DeleteEventButton.frame.origin.y = ChangeEventButton.frame.origin.y - ChangeEventButton.frame.size.height - 10
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
