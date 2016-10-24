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
    
    var currentVehicles = [String: Vehicle]()
    var updatedVehicles = [String: Vehicle]()
    var elements = [String]()
    var lastUpdated = String()
    let regionRadius: CLLocationDistance = 20000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Requests user's location once to trigger locationManager function that zooms to user's current location
        locationManager.delegate = self;
        locationManager.requestLocation()
        
        // run the xml parser
        let timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.refreshData), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // zooms to user's current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("did update location")
        if let userLocation = locations.last {
            let center = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
            mapView.setCenter(center, zoomLevel: 15, animated: true)
            print("setting center")
        }
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
            print (String(self.updatedVehicles.count) + " vehicle locations obtained")
            print (String(self.currentVehicles.count) + " vehicles in the current vehicle list")
            print ("last updated at " + (self.lastUpdated))
            let cv = self.currentVehicles
            DispatchQueue.main.async {
                print ("adding vehicles to map on main...")
                self.addVehiclesToMap(v: Array(cv.values))
                print ("... done adding vehicles to map on main")
            }
            self.updatedVehicles.removeAll()
            self.elements.removeAll()
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
            
            updatedVehicles[id] = vehicle
            updateCurrentVehicles()
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
    
    // currently not doing anything!!! 
    func updateCurrentVehicles() {
        // iterate through the most recent GTFS vehicle feed, update previous vehicle info and add new vehicles if they don't exist
        for updatedid in updatedVehicles.keys {
            for currentid in currentVehicles.keys {
                if updatedid == currentid {
                    // if updated id matches a current id, set the current id's value to that of the updated id
                    currentVehicles[currentid] = updatedVehicles[updatedid]
                }
                else {
                    // if updated id matches none of the current id's, add it to the current id dictionary
                    currentVehicles[updatedid] = updatedVehicles[updatedid]
                    print ("vehicle added to current vehicle list")
                }
            }
        }
        // iterate through the current vehicle list and remove any vehicles that are not present in the most recent GTFS feed
        for currentid in currentVehicles.keys {
            for updatedid in updatedVehicles.keys {
                if currentid == updatedid {
                    // break out and move to the next current id
                    break
                }
                else {
                    // if current id matches none of the updated id's, remove it from the dictionary
                    currentVehicles[currentid] = nil
                    print ("vehicle removed from current vehicle list")
                }
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
    
    // mapping functions
    
    func addVehiclesToMap(v: [Vehicle]) {
        for vehicle in v {
            mapView.addAnnotation(vehicle)
        }
    }
}

// extention for mapview delegates

extension ViewController: MGLMapViewDelegate {
    
/*    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        // we only want vehicle annotations
        guard annotation is Vehicle else {
            return nil
        }
        
        let reuseIdentifier = "\(annotation.coordinate.longitude)"

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            
            // Set the annotation view’s background color to a value determined by its longitude.
            let hue = CGFloat(annotation.coordinate.longitude) / 100
            annotationView!.backgroundColor = UIColor(hue: hue, saturation: 0.5, brightness: 1, alpha: 1)
        }
        
        return annotationView
    } */

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

class CustomAnnotationView: MGLAnnotationView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Force the annotation view to maintain a constant size when the map is tilted.
        scalesWithViewingDistance = false
        
        // Use CALayer’s corner radius to turn this view into a circle.
        layer.cornerRadius = frame.width / 2
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
    }
}


