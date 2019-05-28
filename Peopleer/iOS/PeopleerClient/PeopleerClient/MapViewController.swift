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
    
    var locationManager: CLLocationManager!
    let distanceSpan = 50000
    
    var viewLoadedAlertTitle: String? = nil
    var viewLoadedAlertMsg: String? = nil
    
    private var selectedEvent = Event()
    var eventEditorStartupMode = EventEditingMode.CreateEvent
    
    override func viewDidAppear(_ animated: Bool) {
        if viewLoadedAlertMsg != nil && viewLoadedAlertTitle != nil {
            let topVC = UIUtils.currentTopViewController()
            UIUtils.showAlert(view: topVC, title: viewLoadedAlertTitle!, message: viewLoadedAlertMsg!)
            viewLoadedAlertTitle = nil
            viewLoadedAlertMsg = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RemoveAllAnnotations()
        
        EventDataManager.shared.RetrieveEvents(view: self) { events in
            self.createMapAnnotations(events: EventDataManager.shared.events)
        }
        
        mapView.delegate = self
        createLocationManager()
        
        if locationManager.location != nil {
            setMapZoomLevel(location: locationManager.location!)
        }
    }
    
    func createLocationManager() {
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
        let mapCoordinates = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: CLLocationDistance(distanceSpan), longitudinalMeters: CLLocationDistance(distanceSpan))
        mapView.setRegion(mapCoordinates, animated: true)
    }
    
    func createMapAnnotations(events: [Event]) {
        for event in events {
            let annotation = MKPointAnnotation()
            annotation.title = event.title
            annotation.subtitle = "By \(event.owner)"
            annotation.coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
    func RemoveAllAnnotations() {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations(annotationsToRemove)
    }
    
    @IBAction func RefreshMap(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        RemoveAllAnnotations()
        
        EventDataManager.shared.RetrieveEvents(view: self) { events in
            self.createMapAnnotations(events: events)
            sender.isEnabled = true
        }
    }
    
    @IBAction func MapLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let point = sender.location(in: mapView)
            let tapPoint = mapView.convert(point, toCoordinateFrom: view)
            
            selectedEvent.latitude = tapPoint.latitude
            selectedEvent.longitude = tapPoint.longitude
            eventEditorStartupMode = EventEditingMode.CreateEvent
            
            performSegue(withIdentifier: "EditEventSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditEventSegue" {
            guard let eventEditorViewController = segue.destination as? EventEditorViewController else { return }
            
            eventEditorViewController.startupMode = eventEditorStartupMode
            eventEditorViewController.event = selectedEvent
        }
        else if segue.identifier == "ViewEventSegue" {
            guard let eventViewerViewController = segue.destination as? EventViewerViewController else { return }
            eventViewerViewController.event = selectedEvent
        }
    }
}


extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        
        if annotation === mapView.userLocation {
            return nil
        } else {
            annotationView?.image = UIImage(named: "EventFlag")
        }
        
        annotationView?.canShowCallout = true
        annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        selectedEvent.title = (view.annotation?.title!)!
        selectedEvent.latitude = (view.annotation?.coordinate.latitude)!
        selectedEvent.longitude = (view.annotation?.coordinate.longitude)!
        
        EventDataManager.shared.GetSpecificEvent(event: selectedEvent, view: self) { event in
            if event != nil {
                self.selectedEvent = event!
                
                if self.selectedEvent.owner == LoginManager.username {
                    self.eventEditorStartupMode = EventEditingMode.EditEvent
                } else {
                    self.eventEditorStartupMode = EventEditingMode.ViewEvent
                }
                
                self.performSegue(withIdentifier: "ViewEventSegue", sender: nil)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Annotation was selected
    }
}
