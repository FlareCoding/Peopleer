//
//  EventViewerViewController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 5/26/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

enum EventViewerViewControllerViewingMode {
    case Create
    case Edit
    case View
}

class EventViewerViewController: UIViewController {
    
    var event = Event()
    var viewingMode = EventViewerViewControllerViewingMode.View
    var exitSegueIdentifier = ""
    
    @IBOutlet weak var editEventNavigationBarButton: UIBarButtonItem!
    @IBOutlet weak var updateEventNavigationBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteEventNavigationBarButton: UIBarButtonItem!
    @IBOutlet weak var eventTitleLabel: UITextView!
    @IBOutlet weak var addressLabel: UITextView!
    @IBOutlet weak var eventDescriptionView: UITextView!
    @IBOutlet weak var startTimeView: UITextView!
    @IBOutlet weak var endTimeView: UITextView!
    @IBOutlet weak var currentParticipantCountView: UITextView!
    @IBOutlet weak var participantLimitCountView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editEventNavigationBarButton.isEnabled = false
        editEventNavigationBarButton.title = ""
        
        updateEventNavigationBarButton.isEnabled = false
        updateEventNavigationBarButton.title = ""
        
        deleteEventNavigationBarButton.isEnabled = false
        deleteEventNavigationBarButton.title = ""
        
        eventTitleLabel.text = event.title
        addressLabel.text = "Located at:\n" + event.address
        eventDescriptionView.text = event.description
        startTimeView.text = "Start Time: " + DateTimeUtils.getEventDateAndTime(date: event.startTime)
        endTimeView.text = "End Time: " + DateTimeUtils.getEventDateAndTime(date: event.endTime)
        currentParticipantCountView.text = "Current Participants: " + String(describing: event.currentParticipants)
        participantLimitCountView.text = "Participant Limit: " + String(describing: event.maxParticipants)
        
        if viewingMode == .Edit {
            editEventNavigationBarButton.title = "Edit"
            editEventNavigationBarButton.isEnabled = true
            
            updateEventNavigationBarButton.title = "Update"
            updateEventNavigationBarButton.isEnabled = true
            
            deleteEventNavigationBarButton.title = "Delete"
            deleteEventNavigationBarButton.isEnabled = true
        }
        
        if viewingMode == .Create {
            editEventNavigationBarButton.title = "Edit"
            editEventNavigationBarButton.isEnabled = true
            
            updateEventNavigationBarButton.title = "Create"
            updateEventNavigationBarButton.isEnabled = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editEventSegue" {
            let vc = segue.destination as! EventEditorViewController
            vc.viewingMode = self.viewingMode
            vc.event = self.event
            vc.eventViewerExitSegueIndetifierCopy = self.exitSegueIdentifier
        }
    }
    
    @IBAction func ReturnNavigationBarButton_OnClick(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: self.exitSegueIdentifier, sender: nil)
    }
    
    @IBAction func UpdateEventButton_OnClick(_ sender: UIBarButtonItem) {
        if viewingMode == .Create {
            UIUtils.showConfirmAlert(view: self, title: "Creating Event", message: "Are you sure you want to create new event?") { result in
                if result == true {
                    self.CreateEvent()
                }
            }
        }
        else if viewingMode == .Edit {
            UIUtils.showConfirmAlert(view: self, title: "Updating Event", message: "Are you sure you want to update current event?") { result in
                if result == true {
                    self.UpdateEvent()
                }
            }
        }
    }
    
    @IBAction func DeleteEventButton_OnClick(_ sender: UIBarButtonItem) {
        UIUtils.showConfirmAlert(view: self, title: "Deleting Event", message: "Are you sure you want to delete current event?") { result in
            if result == true {
                self.DeleteEvent()
            }
        }
    }
    
    private func CreateEvent() {
        EventDataManager.shared.CreateNewEvent(view: self, event: event) { succeeded in
            if succeeded {
                UIUtils.showAlert(view: self, title: "Success", message: "Successfully created new event!") {
                    self.performSegue(withIdentifier: self.exitSegueIdentifier, sender: nil)
                }
            }
        }
    }
    
    private func UpdateEvent() {
        EventDataManager.shared.ModifyEvent(event: event, view: self) { succeeded in
            if succeeded {
                UIUtils.showAlert(view: self, title: "Success", message: "Successfully updated event!") {
                    self.performSegue(withIdentifier: self.exitSegueIdentifier, sender: nil)
                }
            }
        }
    }
    
    private func DeleteEvent() {
        EventDataManager.shared.DeleteEvent(event: event, view: self) { succeeded in
            if succeeded {
                UIUtils.showAlert(view: self, title: "Success", message: "Successfully deleted event!") {
                    self.performSegue(withIdentifier: self.exitSegueIdentifier, sender: nil)
                }
            }
        }
    }
}
