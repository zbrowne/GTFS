//
//  ViewController.swift
//  GTFS
//
//  Created by Zachary Browne on 9/23/16.
//  Copyright © 2016 zbrowne. All rights reserved.
//

import UIKit
import Mapbox

class ViewController: UIViewController, XMLParserDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var mapView: MGLMapView!
    var xmlParser: XMLParser!
    let locationManager = CLLocationManager()
    
    var vehicles = [Vehicle]()
    var elements = [String]()
    var lastUpdated = String()
    let regionRadius: CLLocationDistance = 20000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self;
        locationManager.requestLocation()
        
            // run the xml parser
            refreshData()
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        zoomToCurrentLocation(location: userLocation!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
        // reads nextbus xml data and starts the xml parser delegate methods
        func refreshData() {
            let urlString = NSURL(string: "http://webservices.nextbus.com/service/publicXMLFeed?command=vehicleLocations&a=sf-muni")
            let URLRequest:URLRequest = NSURLRequest(url:urlString! as URL) as URLRequest
            let session = URLSession.shared
            
            session.dataTask(with: URLRequest) {data, URLResponse, err in
                self.xmlParser = XMLParser(data: data!)
                self.xmlParser.delegate = self
                self.xmlParser.parse()
                print (String(self.elements.count) + " elements parsed")
                print (String(self.vehicles.count) + " vehicle locations obtained")
                print ("last updated at " + (self.lastUpdated))
                NSLog ("task completed")
                }.resume()
        }
        
        // parser delegates
        
        // uses vehicle element attributes to create a vehicle object and saves object to an array of vehicles
        func parser(_ parser: XMLParser,
                    didStartElement elementName: String,
                    namespaceURI: String?,
                    qualifiedName qName: String?,
                    attributes attributeDict: [String : String] = [:]) {
            
            if elementName == "vehicle" {
                var lat = CLLocationDegrees()
                var lon = CLLocationDegrees()
                var secsSinceReport = Int()
                var predictable = Bool()
                var heading = Int()
                var speedKmHr = Double()
                
                guard
                    let id = attributeDict["id"] as String?,
                    let routeTag = attributeDict["routeTag"] as String? else {
                        return
                }
                
                if let attributeLat = attributeDict["lat"] as String? {
                    lat = CLLocationDegrees(attributeLat)!
                }
                
                if let attributeLon = attributeDict["lon"] as String? {
                    lon = CLLocationDegrees(attributeLon)!
                }
                
                if let attributeSecsSinceReport = attributeDict["secsSinceReport"] as String? {
                    secsSinceReport = Int(attributeSecsSinceReport)!
                }
                
                if let attributePredictable = attributeDict["predictable"] as String? {
                    predictable = Bool(attributePredictable)!
                }
                
                if let attributeHeading = attributeDict["heading"] as String? {
                    heading = Int(attributeHeading)!
                }
                
                if let attributeSpeedKmHr = attributeDict["speedKmHr"] as String? {
                    speedKmHr = Double(attributeSpeedKmHr)!
                }
                
                let dirTag = attributeDict["dirTag"] as String? ?? ""
                let leadingVehicleId = attributeDict["leadingVehicleId"] as String? ?? ""
                
                let vehicle = Vehicle(title: id, routeTag: routeTag, dirTag: dirTag, lat: lat, lon: lon, secsSinceReport: secsSinceReport, predictable: predictable, heading: heading, speedKmHr: speedKmHr, leadingVehicleId: leadingVehicleId)
                
                vehicles.append(vehicle)
                mapView.addAnnotation(vehicle)
            }
            
            if elementName == "lastTime" {
                if let attributeTime = attributeDict["time"] as String? {
                    let unixTime = (Double(attributeTime)!/1000.0)
                    lastUpdated = convertToDeviceTime(timestamp: unixTime)
                } else {
                    print ("time of last update not available")
                }
            }
        }
        
        // parses each element and appends it to an array of elements
        func parser(_ parser: XMLParser, foundCharacters string: String) {
            elements.append(string)
        }
        
    // helper methods
        
        // function for printing formatted timestamp string for default timezone on device
        func convertToDeviceTime(timestamp: Double) -> String {
            let date = NSDate(timeIntervalSince1970: timestamp)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mma M-dd-yyyy"
            let formattedTimestamp = dateFormatter.string(from: date as Date)
            return formattedTimestamp
        }
        
        //zooms to user's current location
        func zoomToCurrentLocation(location: CLLocation) {
            let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            mapView.setCenter(center, zoomLevel: 15, animated: true)
        }
    }
    
    // extention for mapview delegates
    
    extension ViewController: MGLMapViewDelegate {
        
        // Allow callout view to appear when an annotation is tapped.
        func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
            return true
        }
        
        func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
            return UIButton(type: .detailDisclosure)
        }
        
        // adds information for the detailDisclosure ("info button")
        func mapView(_ mapView: MGLMapView, annotation: Vehicle, calloutAccessoryControlTapped control: UIControl) {
            
            let vehicle = annotation
            let routeTag = "Route " + vehicle.routeTag
            let secsSinceReport = "Last updated " + String(vehicle.secsSinceReport) + " seconds ago"
            
            // Hide the callout view.
            mapView.deselectAnnotation(annotation, animated: false)
            
            let ac = UIAlertController(title: routeTag, message: secsSinceReport, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
}


