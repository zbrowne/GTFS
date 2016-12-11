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
    
    var updatedVehicles = [Vehicle]()
    var oldVehicles = [Vehicle]()
    var elements = [String]()
    var lastUpdated = String()
    let regionRadius: CLLocationDistance = 20000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.styleURL = MGLStyle.lightStyleURL(withVersion: 9)
        
        // Requests user's location once to trigger locationManager function that zooms to user's current location
        locationManager.delegate = self;
        locationManager.requestLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        // run the xml parser immediately and on 5-second intervals thereafter
        let timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.refreshData), userInfo: nil, repeats: true)
        timer.fire()
        self.addVehiclesToMap(v: updatedVehicles)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // zooms to user's current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("did update location")
        if let userLocation = locations.first {
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
            let oldVehicles = self.updatedVehicles
            self.updatedVehicles.removeAll()
            self.xmlParser = XMLParser(data: data!)
            self.xmlParser.delegate = self
            self.xmlParser.parse()
            print (String(self.elements.count) + " elements parsed")
            print (String(self.updatedVehicles.count) + " vehicle locations obtained")
            print ("last updated at " + (self.lastUpdated))
            let v = self.updatedVehicles
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(oldVehicles)
                print ("adding vehicles to map on main...")
                self.addVehiclesToMap(v: v)
                print ("... done adding vehicles to map on main")
            }
            self.elements.removeAll()
            NSLog ("task completed")
            }.resume()
    }
    
    // parser delegates
    
    // uses vehicle element attributes to create a vehicle object and appends object to an array of vehicles
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
            var heading = Double()
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
                heading = Double(attributeHeading)!
            }
            
            if let attributeSpeedKmHr = attributeDict["speedKmHr"] as String? {
                speedKmHr = Double(attributeSpeedKmHr)!
            }
            
            let dirTag = attributeDict["dirTag"] as String? ?? ""
            let leadingVehicleId = attributeDict["leadingVehicleId"] as String? ?? ""
            
            let vehicle = Vehicle(title: id, routeTag: routeTag, dirTag: dirTag, lat: lat, lon: lon, secsSinceReport: secsSinceReport, predictable: predictable, heading: heading, speedKmHr: speedKmHr, leadingVehicleId: leadingVehicleId)
            updatedVehicles.append(vehicle)
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
    
    // mapping functions
    
    func addVehiclesToMap(v: [Vehicle]) {
        for vehicle in v {
            if vehicle.secsSinceReport < 120 {
                mapView.addAnnotation(vehicle)
            }
        }
    }
}

extension Double {
    func toRadians() -> CGFloat {
        return CGFloat(self * .pi / 180.0)
    }
}

// helper extension used to transform image based on header
extension UIImage {
    func rotated(by degrees: Double, flipped: Bool = false) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let transform = CGAffineTransform(rotationAngle: degrees.toRadians())
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContext(size)
        var rect = CGRect(origin: .zero, size: size).applying(transform)
        rect.origin = .zero
        
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { renderContext in
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: degrees.toRadians())
            renderContext.cgContext.scaleBy(x: flipped ? -1.0 : 1.0, y: -1.0)
            
            let drawRect = CGRect(origin: CGPoint(x: -size.width/2, y: -size.height/2), size: size)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
    }
}

// extention for mapview delegates

extension ViewController: MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        // we only want vehicle annotations
         guard let vehicle = annotation as? Vehicle else {
            return nil
         }
        let reuseIdentifier = "\(vehicle.title)"
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier)
        
        if annotationImage == nil {
            if let image = UIImage(named: "chevron-circle-up.png")?.rotated(by: vehicle.heading) {
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "\(vehicle.title)")
            }
        }
        
        return annotationImage
    }
    
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


