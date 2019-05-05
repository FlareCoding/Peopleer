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
            annotation.coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
    func RemoveAllAnnotations() {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
    }
    
    @IBAction func RefreshMap(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        RemoveAllAnnotations()
        
        EventDataManager.shared.RetrieveEvents(view: self) { events in
            self.createMapAnnotations(events: EventDataManager.shared.events)
            sender.isEnabled = true
        }
    }
    
    @IBAction func MapLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let point = sender.location(in: mapView)
            let tapPoint = mapView.convert(point, toCoordinateFrom: view)
            
            selectedEvent.latitude = tapPoint.latitude
            selectedEvent.longitude = tapPoint.longitude
            
            performSegue(withIdentifier: "EditEventSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let eventEditorViewController = segue.destination as? EventEditorViewController else { return }
        
        eventEditorViewController.event = Event()
        
        eventEditorViewController.event.title = selectedEvent.title
        eventEditorViewController.event.latitude = selectedEvent.latitude
        eventEditorViewController.event.longitude = selectedEvent.longitude
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
        EventDataManager.shared.GetSpecificEvent(event_title: selectedEvent.title, view: self) { event in
            if event != nil {
                self.selectedEvent = event!
                self.performSegue(withIdentifier: "EditEventSegue", sender: nil)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Annotation was selected
    }
}
