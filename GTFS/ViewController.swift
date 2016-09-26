//
//  ViewController.swift
//  GTFS
//
//  Created by Zachary Browne on 9/23/16.
//  Copyright © 2016 zbrowne. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, XMLParserDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var xmlParser: XMLParser!
    
    var vehicles = [Vehicle]()
    var elements = [String]()
    var lastUpdated = String()
    let regionRadius: CLLocationDistance = 20000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        // set initial location for map view
        let initialLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        centerMapOnLocation(location: initialLocation)
        
        // run the xml parser
        refreshData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            var id = String()
            var routeTag = String()
            var dirTag = String()
            var lat = CLLocationDegrees()
            var lon = CLLocationDegrees()
            var secsSinceReport = Int()
            var predictable = Bool()
            var heading = Int()
            var speedKmHr = Double()
            var leadingVehicleId = String()
            
            if let attributeId = attributeDict["id"] as String? {
                id = attributeId
            }
            
            if let attributeRouteTag = attributeDict["routeTag"] as String? {
                routeTag = attributeRouteTag
            }
            
            if let attributeDirTag = attributeDict["dirTag"] as String? {
                dirTag = attributeDirTag
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
            
            if let attributeLeadingVehicleId = attributeDict["leadingVehicleId"] as String? {
                leadingVehicleId = attributeLeadingVehicleId
            }
        
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
    
    // function for centering location on map
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

// extention for mapview delegates

    extension ViewController: MKMapViewDelegate {
        
        // adds pins to the map
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let annotation = annotation as? Vehicle {
                let identifier = "Vehicle"
                var view: MKPinAnnotationView
                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                    as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
                } else {
                    view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view.canShowCallout = true
                    view.calloutOffset = CGPoint(x: -5, y: 5)
                    view.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure) as UIView
                }
                return view
            }
            return nil
        }
        
        // adds information for the detailDisclosure ("info button")
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            let vehicle = view.annotation as! Vehicle
            let routeTag = "Route " + vehicle.routeTag
            let secsSinceReport = "Last updated " + String(vehicle.secsSinceReport) + " seconds ago"
            
            let ac = UIAlertController(title: routeTag, message: secsSinceReport, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }


