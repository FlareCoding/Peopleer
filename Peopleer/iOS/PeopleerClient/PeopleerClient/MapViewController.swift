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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RemoveAllAnnotations()
        
        EventDataManager.RefreshEventData()
        sleep(2)
        
        mapView.delegate = self
        
        createLocationManager()
        createMapAnnotations(events: EventDataManager.events)
        
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
            if event.type == "event" {
                let annotation = MKPointAnnotation()
                annotation.title = event.title
                annotation.coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    func RemoveAllAnnotations() {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
    }
    
    @IBAction func RefreshMap(_ sender: UIBarButtonItem) {
        RemoveAllAnnotations()
        EventDataManager.RefreshEventData()
        sleep(2)
        createMapAnnotations(events: EventDataManager.events)
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
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Annotation was selected
    }
}
