//
//  EventViewerViewController3.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 7/5/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

enum EventViewerViewControllerViewingMode {
    case Create
    case Edit
    case View
}

class EventViewerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var eventParticipantsTableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var editEventNavigationBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteEventNavigationBarButton: UIBarButtonItem!
    
    @IBOutlet weak var eventHeaderBackgroundImageView: UIImageView!
    @IBOutlet weak var eventHeaderEventTitle: UITextView!
    @IBOutlet weak var eventHeaderParticipantsTextView: UITextView!
    @IBOutlet weak var eventHeaderJoinButton: UIButton!
    
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    @IBOutlet weak var eventStartTimeTextView: UITextView!
    @IBOutlet weak var eventEndTimeTextView: UITextView!
    @IBOutlet weak var eventAddressTextView: UITextView!
    
    // Event object to hold current event data
    var event = Event()
    
    // Specifies event viewing rights (Create, Edit, or View)
    var viewingMode = EventViewerViewControllerViewingMode.View
    
    // Specifies which segue to use when exiting the view controller
    var exitSegueIdentifier = ""
    
    // Preserves a user object if the segue to this view controller was called from a user profile
    var preservedUserObject = User()
    
    // Holds event participants' user objects
    private var participantsList: [User] = []
    
    // Holds user object that was selected in a table view
    private var selectedUser = User()
    
    // Instance of location manager for utilizing iOS location services
    private var locationManager: CLLocationManager!
    
    // Event owner displayable name rather than raw username
    private var ownerDisplayableName = ""
    
    //****************** Constants ******************//
    let kStartTimeLabelStartingText = "Start Time:       "
    let kEndTimeLabelStartingText   = "End Time:         "
    let kParticipantsTableViewRowHeight: CGFloat = 44.0
    let kMapZoomLevel = 1400
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onViewDidLoad()
    }
    
    func getEventParticipants() {
        UserDataManager.shared.GetEventParticipants(view: self, event: event, completionHandler: { (users) in
            self.participantsList = users
            self.eventParticipantsTableView.reloadData()
        })
    }
    
    func setupMapView() {
        removeAllAnnotations()
        
        createLocationManager()
        setMapZoomLevel()
        createEventLocationAnnotation()
    }
    
    func getOwnerDisplayableName() {
        UserDataManager.shared.GetUserInformation(view: self, username: event.owner) { (user) in
            if user != nil {
                self.ownerDisplayableName = user!.displayedName
            }
        }
    }
    
    func onViewDidLoad() {
        
        // Set up map view
        setupMapView()
        
        // Remove all already-existing sublayers from image view
        eventHeaderBackgroundImageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // Make background image darker by adding black opaque sublayer to the image view
        UIUtils.addCoverLayer(view: eventHeaderBackgroundImageView!, layerColor: .black, layerOpacity: 0.56)
        
        // Make the navigation bar transparent
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        // Add a footer view to the participants table view
        eventParticipantsTableView.tableFooterView = UIView()
        
        //
        // By default controls will be set only for viewing the event
        //
        
        // Hide the join button before checking whether user is already signed up or not
        eventHeaderJoinButton.isHidden = true
        
        // Disable and hide "Edit" button
        editEventNavigationBarButton.isEnabled = false
        editEventNavigationBarButton.tintColor = .clear
        
        // Disable and hide "Delete" button
        deleteEventNavigationBarButton.isEnabled = false
        deleteEventNavigationBarButton.tintColor = .clear
        
        // Show "Join Event" button only if viewing mode is "View" and if there is space for another participant
        if viewingMode == .View && (event.currentParticipants < event.maxParticipants) && (LoginManager.username != event.owner)  {
            eventHeaderJoinButton.isHidden = false
        } else { eventHeaderJoinButton.isHidden = true }
        
        // Check if user is already signed up for this event
        if viewingMode == .View {
            EventDataManager.shared.IsUserSignedUpForEvent(view: self, user: LoginManager.username, event: self.event) { userSignedUp in
                if userSignedUp {
                    self.eventHeaderJoinButton.backgroundColor = UIColor(red: 140 / 255, green: 4 / 255, blue: 4 / 255, alpha: 1.0)
                    self.eventHeaderJoinButton.setTitle("Leave Event", for: .normal)
                } else {
                    self.eventHeaderJoinButton.backgroundColor = UIColor(red: 33 / 255, green: 178 / 255, blue: 54 / 255, alpha: 1.0)
                    self.eventHeaderJoinButton.setTitle("Join Event", for: .normal)
                }
                
                self.eventHeaderJoinButton.isHidden = false
            }
        }
        
        // Update UI controls based on the new event data
        eventHeaderEventTitle.text = event.title
        eventHeaderParticipantsTextView.text    = "Participants:   \(event.currentParticipants)/\(event.maxParticipants)"
        eventDescriptionTextView.text           = event.description
        eventStartTimeTextView.text             = kStartTimeLabelStartingText + DateTimeUtils.getEventDateAndTime(date: event.startTime)
        eventEndTimeTextView.text               = kEndTimeLabelStartingText   + DateTimeUtils.getEventDateAndTime(date: event.endTime)
        eventAddressTextView.text               = event.address
        
        // Enable "Edit" and "Delete" buttons in the navigation bar if user has event editing rights
        if viewingMode == .Edit {
            editEventNavigationBarButton.tintColor = .white
            editEventNavigationBarButton.isEnabled = true
            
            deleteEventNavigationBarButton.tintColor = .red
            deleteEventNavigationBarButton.isEnabled = true
        }
        
        // Enable "Edit" and "Create" buttons in the navigation bar if user is creating a new event
        if viewingMode == .Create {
            editEventNavigationBarButton.tintColor = .white
            editEventNavigationBarButton.isEnabled = true
        }
        
        getEventParticipants()
        getOwnerDisplayableName()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kParticipantsTableViewRowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participantsList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "eventOwnerCell")!

        if indexPath.row == 0 {
            var ownerDisplayName = self.ownerDisplayableName
            if ownerDisplayName.isEmpty {
                ownerDisplayName = event.owner
            }
            (cell as! EventOwnerCell).eventOwnerNameLabel.text = ownerDisplayName
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "eventParticipantCell")!
            (cell as! EventParticipantCell).eventParticipantNameLabel.text = participantsList[indexPath.row - 1].displayedName
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var username = event.owner
        if indexPath.row > 0 {
            username = participantsList[indexPath.row - 1].username
        }
        
        UserDataManager.shared.GetUserInformation(view: self, username: username) { (user) in
            if user != nil {
                self.selectedUser = user!
                self.performSegue(withIdentifier: Segues.ViewUserProfile, sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the user presses "Edit" button and goes to the event editing screen
        if segue.identifier == Segues.EditEvent {
            let vc = segue.destination as! EventEditorViewController
            
            // Preserve a copy of current viewing mode state
            vc.viewingMode = self.viewingMode
            
            // Pass the copy of the event object
            vc.event = self.event
            
            // Preserve a copy of current identifier for the exit segue
            vc.eventViewerExitSegueIndetifierCopy = self.exitSegueIdentifier
            
            // Preserve a copy of user object
            vc.preservedUserObject = self.preservedUserObject
        }
        
        // If the user returns to the map
        if segue.identifier == Segues.ReturnToMapFromEventViewer {
            let vc = segue.destination as! MapViewController
            
            // Set focus point of the map to event's location
            vc.initialMapPosition = CLLocation(latitude: self.event.latitude, longitude: self.event.longitude)
        }
        
        // If the user returns to UserProfileViewController
        if segue.identifier == Segues.ReturnToUserProfile {
            let vc = segue.destination as! UserProfileViewController
            
            // Set user object of the profile to the preserved copy passed here beforehand
            vc.user = preservedUserObject
        }
        
        // If the user views profile from the list of participants in the table view
        if segue.identifier == Segues.ViewUserProfile {
            let vc = segue.destination as! UserProfileViewController
            
            vc.user = selectedUser
            vc.eventViewerPreservedEvent = self.event
            vc.eventViewerPreservedViewingMode = self.viewingMode
            vc.exitSegueIdentifier = Segues.ReturnToEventViewerFromUserProfile
        }
    }
    
    func createLocationManager() {
        // Creates a new location manager instance if location services are enabled on the device
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func setMapZoomLevel() {
        // Sets the focus point of the map
        let mapCoordinates = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude), latitudinalMeters: CLLocationDistance(kMapZoomLevel), longitudinalMeters: CLLocationDistance(kMapZoomLevel))
        mapView.setRegion(mapCoordinates, animated: true)
    }
    
    func createEventLocationAnnotation() {
        // Loops through all the fetched events and creates an annotation on the map
        let annotation = MKPointAnnotation()
        annotation.title = event.title
        annotation.subtitle = "By \(event.owner)"
        annotation.coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
        mapView.addAnnotation(annotation)
    }
    
    func removeAllAnnotations() {
        // Clears the map of all existing annotations
        mapView.removeAnnotations(mapView.annotations)
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
        UIUtils.springAnimate(view: sender, duration: 0.3, springScaleFactor: 0.86)
        
        if eventHeaderJoinButton.titleLabel?.text == "Join Event" {
            JoinEvent()
        } else {
            LeaveEvent()
        }
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
            /*
            if succeeded {
                UIUtils.showAlert(view: self, title: "Success", message: "Successfully joined \"\(self.event.title)\"") {
                    self.ReloadViewWithUpdatedEventInfo()
                }
            } else {
                self.ReloadViewWithUpdatedEventInfo()
            }
            */
            self.ReloadViewWithUpdatedEventInfo()
        }
    }
    
    private func LeaveEvent() {
        // Removes the user from event
        EventDataManager.shared.RemoveUserFromEvent(view: self, userToRemove: LoginManager.username, event: self.event) { succeeded in
            /*
            if succeeded {
                UIUtils.showAlert(view: self, title: "Success", message: "Successfully left event \"\(self.event.title)\"") {
                    self.ReloadViewWithUpdatedEventInfo()
                }
            } else {
                self.ReloadViewWithUpdatedEventInfo()
            }
            */
            self.ReloadViewWithUpdatedEventInfo()
        }
    }
    
    private func ReloadViewWithUpdatedEventInfo() {
        EventDataManager.shared.GetSpecificEvent(event: self.event) { updatedEvent in
            self.event = updatedEvent ?? Event()
            self.onViewDidLoad()
        }
    }
}

class EventOwnerCell : UITableViewCell {
    
    @IBOutlet weak var eventOwnerNameLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initializeCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func initializeCell() {
        // Customize cell
    }
}

class EventParticipantCell : UITableViewCell {
    
    @IBOutlet weak var eventParticipantNameLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initializeCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func initializeCell() {
        // Customize cell
    }
}
