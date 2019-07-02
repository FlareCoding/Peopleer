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
    @IBOutlet weak var deleteEventNavigationBarButton: UIBarButtonItem!
    @IBOutlet weak var eventTitleLabel: UITextView!
    @IBOutlet weak var addressLabel: UITextView!
    @IBOutlet weak var eventDescriptionView: UITextView!
    @IBOutlet weak var startTimeView: UITextView!
    @IBOutlet weak var endTimeView: UITextView!
    @IBOutlet weak var currentParticipantCountView: UITextView!
    @IBOutlet weak var participantLimitCountView: UITextView!
    @IBOutlet weak var joinEventButton: UIButton!
    @IBOutlet weak var signedUpCheckmarkImage: UIImageView!
    @IBOutlet weak var signedUpDisplayLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.onViewDidLoad();
    }
    
    func onViewDidLoad() {
        //
        // By default controls will be set only for viewing the event
        //
        
        // Disable and hide "Edit" button
        editEventNavigationBarButton.isEnabled = false
        editEventNavigationBarButton.title = ""
        
        // Disable and hide "Delete" button
        deleteEventNavigationBarButton.isEnabled = false
        deleteEventNavigationBarButton.title = ""
        
        // Show "Join Event" button only if viewing mode is "View" and if there is space for another participant
        
        if viewingMode == .View && (event.currentParticipants < event.maxParticipants) && (LoginManager.username != event.owner)  {
            joinEventButton.isHidden = false
        } else { joinEventButton.isHidden = true }
        
        // Check if user is already signed up for this event
        EventDataManager.shared.IsUserSignedUpForEvent(view: self, user: LoginManager.username, event: self.event) { userSignedUp in
            if userSignedUp {
                self.joinEventButton.isHidden = true
                self.signedUpCheckmarkImage.isHidden = false
                self.signedUpDisplayLabel.isHidden = false
            }
        }
        
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
            
            deleteEventNavigationBarButton.title = "Delete"
            deleteEventNavigationBarButton.isEnabled = true
        }
        
        // Enable "Edit" and "Create" buttons in the navigation bar if user is creating a new event
        if viewingMode == .Create {
            editEventNavigationBarButton.title = "Edit"
            editEventNavigationBarButton.isEnabled = true
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
    
    @IBAction func DeleteEventButton_OnClick(_ sender: UIBarButtonItem) {
        UIUtils.showConfirmAlert(view: self, title: "Deleting Event", message: "Are you sure you want to delete \"\(self.event.title)\"?") { result in
            if result == true {
                self.DeleteEvent()
            }
        }
    }
    
    @IBAction func JoinEventButton_OnClick(_ sender: UIButton) {
        JoinEvent()
    }
    
    private func DeleteEvent() {
        // Permanently deletes the event
        EventDataManager.shared.DeleteEvent(event: event, view: self) { succeeded in
            if succeeded {
                UIUtils.showAlert(view: self, title: "Success", message: "Successfully deleted \"\(self.event.title)\"") {
                    self.performSegue(withIdentifier: self.exitSegueIdentifier, sender: nil)
                }
            }
        }
    }
    
    private func JoinEvent() {
        // Signs the user up for a selected event
        EventDataManager.shared.SignUserUpForEvent(view: self, userToSignUp: LoginManager.username, event: self.event) { succeeded in
            if succeeded {
                UIUtils.showAlert(view: self, title: "Success", message: "Successfully joined \"\(self.event.title)\"") {
                    self.ReloadViewWithUpdatedEventInfo()
                }
            } else {
                self.ReloadViewWithUpdatedEventInfo()
            }
        }
    }
    
    private func ReloadViewWithUpdatedEventInfo() {
        EventDataManager.shared.GetSpecificEvent(event: self.event) { updatedEvent in
            self.event = updatedEvent ?? Event()
            self.onViewDidLoad()
        }
    }
}
