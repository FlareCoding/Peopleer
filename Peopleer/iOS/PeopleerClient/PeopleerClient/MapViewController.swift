//
//  MapViewController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 4/25/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    // Instance of location manager for utilizing iOS location services
    private var locationManager: CLLocationManager!
    
    // Used to set zoom level when the map loads
    private let distanceSpan = 50000
    
    // Used to set focus point of the map when it loads
    var initialMapPosition: CLLocation? = nil
    
    // Used to hold data for a selected event
    private var selectedEvent = Event()
    
    // Used for specifying viewing mode when segueing to a EventViewerViewController
    var eventViewingMode = EventViewerViewControllerViewingMode.View
    
    override func viewDidAppear(_ animated: Bool) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clears all previously created annotations
        RemoveAllAnnotations()
        
        // Fetches all events and adds them to the map as flag icons
        EventDataManager.shared.RetrieveAllEvents(view: self) { events in
            self.createMapAnnotations(events: EventDataManager.shared.events)
        }
        
        mapView.delegate = self
        
        // Registers a new location manager instance
        createLocationManager()
        
        if locationManager.location != nil {
            // Initializes location to be used as the focus point when the map loads
            var locationToUse = locationManager.location!
            
            // If initial map position exists, use that location as the focus point of the map.
            // This can occur when a user was viewing an event and returns back to the map view.
            if initialMapPosition != nil { locationToUse = initialMapPosition! }
            
            // Sets the zoom level defined in a variable "distanceSpan"
            setMapZoomLevel(location: locationToUse)
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
    
    func setMapZoomLevel(location: CLLocation) {
        // Sets the focus point of the map
        let mapCoordinates = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: CLLocationDistance(distanceSpan), longitudinalMeters: CLLocationDistance(distanceSpan))
        mapView.setRegion(mapCoordinates, animated: true)
    }
    
    func createMapAnnotations(events: [Event]) {
        // Loops through all the fetched events and creates an annotation on the map
        for event in events {
            let annotation = MKPointAnnotation()
            annotation.title = event.title
            annotation.subtitle = "By \(event.owner)"
            annotation.coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
    func RemoveAllAnnotations() {
        // Clears the map of all existing annotations
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations(annotationsToRemove)
    }
    
    @IBAction func RefreshMap(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        
        // Clears the map of existing event annotations
        RemoveAllAnnotations()
        
        // Fetches new list of events from the server and adds them to the map as new annotations
        EventDataManager.shared.RetrieveAllEvents(view: self) { events in
            self.createMapAnnotations(events: events)
            sender.isEnabled = true
        }
    }
    
    @IBAction func MapLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        // When the user presses a location point and holds it
        if sender.state == UIGestureRecognizer.State.began {
            // Converts pressed 2D coordinates to latitude and longitude on the map
            let point = sender.location(in: mapView)
            let tapPoint = mapView.convert(point, toCoordinateFrom: view)
            
            // Setting selected event data to default values
            selectedEvent = Event()
            
            // Setting correct latitude and longitude values of the new selected event data
            selectedEvent.latitude = tapPoint.latitude
            selectedEvent.longitude = tapPoint.longitude
            
            // Setting event viewing mode to Create Mode since the user wants to create a new event
            eventViewingMode = .Create
            
            // Segueing to EventViewerViewController to view the event
            performSegue(withIdentifier: Segues.ViewEvent, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check for specific segue identifiers
        if segue.identifier == "ViewEventSegue" {
            guard let eventViewerViewController = segue.destination as? EventViewerViewController else { return }
            
            // Set proper event data
            eventViewerViewController.event = selectedEvent
            
            // Set event viewing mode (Create, Edit, or View)
            eventViewerViewController.viewingMode = eventViewingMode
            
            // Sets the returning segue identifier
            eventViewerViewController.exitSegueIdentifier = "returnToMapSegue"
        }
    }
}


extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Attempt to deque annotation view
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        
        // If such annotation view doesn't exist, create it
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        
        // Set annotation image to a flag icon unless it is user's current location
        if annotation === mapView.userLocation {
            return nil
        } else {
            annotationView?.image = UIImage(named: "EventFlag")
        }
        
        // Set annotation view callout properties
        annotationView?.canShowCallout = true
        annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //
        // When the annotation "info" button is clicked
        //
        
        // Set event identifying fields for the selected event data object based on the information from the map (latitude, longitude, title)
        selectedEvent.title = (view.annotation?.title!)!
        selectedEvent.latitude = (view.annotation?.coordinate.latitude)!
        selectedEvent.longitude = (view.annotation?.coordinate.longitude)!
        
        // Fetch event data from the server for this specific event
        EventDataManager.shared.GetSpecificEvent(event: selectedEvent, view: self) { event in
            if event != nil {
                self.selectedEvent = event!
                
                // If the user is the owner of the event, set event viewing mode to Edit, otherwise set it to just View
                if self.selectedEvent.owner == LoginManager.username {
                    self.eventViewingMode = .Edit
                } else {
                    self.eventViewingMode = .View
                }
                
                // Segue over to the EventViewerViewController to display the selected event
                self.performSegue(withIdentifier: Segues.ViewEvent, sender: nil)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Annotation was selected
    }
}
