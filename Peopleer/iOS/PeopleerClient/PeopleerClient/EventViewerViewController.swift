//
//  EventViewerViewController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 5/26/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

class EventViewerViewController: UIViewController {

    var event = Event()
    
    @IBOutlet weak var editEventNavigationBarButton: UIBarButtonItem!
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
        
        eventTitleLabel.text = event.title
        addressLabel.text = "Located at:\n" + event.address
        eventDescriptionView.text = event.description
        startTimeView.text = "Start Time: " + DateTimeUtils.getEventDateAndTime(date: event.startTime)
        endTimeView.text = "End Time: " + DateTimeUtils.getEventDateAndTime(date: event.endTime)
        currentParticipantCountView.text = "Current Participants: " + String(describing: event.currentParticipants)
        participantLimitCountView.text = "Participant Limit: " + String(describing: event.maxParticipants)
        
        if event.owner == LoginManager.username {
            editEventNavigationBarButton.title = "Edit"
            editEventNavigationBarButton.isEnabled = true
        }
    }

}
