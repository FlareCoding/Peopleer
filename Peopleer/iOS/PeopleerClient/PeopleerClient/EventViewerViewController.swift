//
//  EventViewerViewController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 5/26/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit
import CoreLocation

enum EventViewerViewControllerViewingMode {
    case Create
    case Edit
    case View
}

class EventViewerViewController: UIViewController {
    
    // Event object to hold current event data
    var event = Event()
    
    // Specifies event viewing rights (Create, Edit, or View)
    var viewingMode = EventViewerViewControllerViewingMode.View
    
    // Specifies which segue to use when exiting the view controller
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
        
        //
        // By default controls will be set only for viewing the event
        //
        
        // Disable and hide "Edit" button
        editEventNavigationBarButton.isEnabled = false
        editEventNavigationBarButton.title = ""
        
        // Disable and hide "Create/Update" button
        updateEventNavigationBarButton.isEnabled = false
        updateEventNavigationBarButton.title = ""
        
        // Disable and hide "Delete" button
        deleteEventNavigationBarButton.isEnabled = false
        deleteEventNavigationBarButton.title = ""
        
        // Update UI controls based on the new event data
        eventTitleLabel.text                = event.title
        addressLabel.text                   = "Located at:\n" + event.address
        eventDescriptionView.text           = event.description
        startTimeView.text                  = "Start Time: " + DateTimeUtils.getEventDateAndTime(date: event.startTime)
        endTimeView.text                    = "End Time: " + DateTimeUtils.getEventDateAndTime(date: event.endTime)
        currentParticipantCountView.text    = "Current Participants: " + String(describing: event.currentParticipants)
        participantLimitCountView.text      = "Participant Limit: " + String(describing: event.maxParticipants)
        
        // Enable "Edit", "Update", and "Delete" buttons in the navigation bar if user has event editing rights
        if viewingMode == .Edit {
            editEventNavigationBarButton.title = "Edit"
            editEventNavigationBarButton.isEnabled = true
            
            updateEventNavigationBarButton.title = "Update"
            updateEventNavigationBarButton.isEnabled = true
            
            deleteEventNavigationBarButton.title = "Delete"
            deleteEventNavigationBarButton.isEnabled = true
        }
        
        // Enable "Edit" and "Create" buttons in the navigation bar if user is creating a new event
        if viewingMode == .Create {
            editEventNavigationBarButton.title = "Edit"
            editEventNavigationBarButton.isEnabled = true
            
            updateEventNavigationBarButton.title = "Create"
            updateEventNavigationBarButton.isEnabled = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the user presses "Edit" button and goes to the event editing screen
        if segue.identifier == "editEventSegue" {
            let vc = segue.destination as! EventEditorViewController
            
            // Preserve a copy of current viewing mode state
            vc.viewingMode = self.viewingMode
            
            // Pass the copy of the event object
            vc.event = self.event
            
            // Preserve a copy of current identifier for the exit segue
            vc.eventViewerExitSegueIndetifierCopy = self.exitSegueIdentifier
        }
        
        // If the user returns to the map
        if segue.identifier == "returnToMapSegue" {
            let vc = segue.destination as! MapViewController
            
            // Set focus point of the map to event's location
            vc.initialMapPosition = CLLocation(latitude: self.event.latitude, longitude: self.event.longitude)
        }
    }
    
    @IBAction func ReturnNavigationBarButton_OnClick(_ sender: UIBarButtonItem) {
        // When the user presses "Return" button in the navigation bar, exit current view controller according to the set exit segue identifier
        self.performSegue(withIdentifier: self.exitSegueIdentifier, sender: nil)
    }
    
    @IBAction func UpdateEventButton_OnClick(_ sender: UIBarButtonItem) {
        //
        // Text on the "Update" button will display either "Update" if the event already exists or "Create" if the event has not been created yet.
        // Depending on the current viewing mode (Create or Edit), event will be either updated or a request to create the event will be sent to the database.
        //
        
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
        // Sends a request to the database to create a new event based on the current event object
        EventDataManager.shared.CreateNewEvent(view: self, event: event) { succeeded in
            if succeeded {
                UIUtils.showAlert(view: self, title: "Success", message: "Successfully created new event!") {
                    self.performSegue(withIdentifier: self.exitSegueIdentifier, sender: nil)
                }
            }
        }
    }
    
    private func UpdateEvent() {
        // Sends updated event information to the database and updates the event
        EventDataManager.shared.ModifyEvent(event: event, view: self) { succeeded in
            if succeeded {
                UIUtils.showAlert(view: self, title: "Success", message: "Successfully updated event!") {
                    self.performSegue(withIdentifier: self.exitSegueIdentifier, sender: nil)
                }
            }
        }
    }
    
    private func DeleteEvent() {
        // Permanently deletes the event
        EventDataManager.shared.DeleteEvent(event: event, view: self) { succeeded in
            if succeeded {
                UIUtils.showAlert(view: self, title: "Success", message: "Successfully deleted event!") {
                    self.performSegue(withIdentifier: self.exitSegueIdentifier, sender: nil)
                }
            }
        }
    }
}
