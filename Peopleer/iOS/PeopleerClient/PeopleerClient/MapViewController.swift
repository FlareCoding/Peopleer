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
        mapView.delegate = self
        
        createLocationManager()
        createMapAnnotations(locations: EventDataManager.event_locations)
        
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
    
    func createMapAnnotations(locations: [[String : Any]]) {
        for location in locations {
            if location["type"] as? String == "event" {
                let annotation = MKPointAnnotation()
                annotation.title = location["title"] as? String
                annotation.coordinate = CLLocationCoordinate2D(latitude: location["latitude"] as! CLLocationDegrees,
                                                               longitude: location["longitude"] as! CLLocationDegrees)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    
    @IBAction func RefreshMap(_ sender: UIBarButtonItem) {
        EventDataManager.RefreshEventData()
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
