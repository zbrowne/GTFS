//
//  ViewController.swift
//  GTFS
//
//  Created by Zachary Browne on 9/23/16.
//  Copyright © 2016 zbrowne. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, XMLParserDelegate {
    
    var xmlParser: XMLParser!

    var Elements = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        refreshData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshData() {
        let urlString = NSURL(string: "http://webservices.nextbus.com/service/publicXMLFeed?command=vehicleLocations&a=sf-muni")
        let URLRequest:URLRequest = NSURLRequest(url:urlString! as URL) as URLRequest
        let session = URLSession.shared
        
        session.dataTask(with: URLRequest) {data, URLResponse, err in
            self.xmlParser = XMLParser(data: data!)
            self.xmlParser.delegate = self
            self.xmlParser.parse()
            
            print ("line number " + String(self.xmlParser.lineNumber))
            print ("task completed")
            
            }.resume()
    }
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        print (elementName)
        if elementName == "vehicle" {
            if let id = attributeDict["id"] as String? {
                print(id)
            } else {
                print ("vehicle has no id")
            }
            
            if let routeTag = attributeDict["routeTag"] as String? {
                print(routeTag)
            } else {
                print ("vehicle has no routeTag")
            }
            
            if let dirTag = attributeDict["dirTag"] as String? {
                print(dirTag)
            } else {
                print ("vehicle has no dirTag")
            }
            
            if let lat = attributeDict["lat"] as String? {
                print(lat)
            } else {
                print ("vehicle has no lat")
            }
            
            if let lon = attributeDict["lon"] as String? {
                print(lon)
            } else {
                print ("vehicle has no lon")
            }
            
            if let secsSinceReport = attributeDict["secsSinceReport"] as String? {
                print(secsSinceReport)
            } else {
                print ("vehicle has no secsSinceReport")
            }
            
            if let predictable = attributeDict["predictable"] as String? {
                print(predictable)
            } else {
                print ("vehicle has no predictable")
            }
            
            if let heading = attributeDict["heading"] as String? {
                print(heading)
            } else {
                print ("vehicle has no heading")
            }
            
            if let speedKmHr = attributeDict["speedKmHr"] as String? {
                print(speedKmHr)
            } else {
                print ("vehicle has no speedKmHr")
            }
            
            if let leadingVehicleId = attributeDict["leadingVehicleId"] as String? {
                print(leadingVehicleId)
            } else {
                print ("vehicle has no leadingVehicleId")
            }
        }
        
        if elementName == "lastTime" {
            if let time = attributeDict["time"] as String? {
                print(time)
            } else {
                print ("time of latest information not available")
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if string.characters.count > 1 {
            print (string)
        }
        Elements.append(string)
        print (String(Elements.count) + " elements parsed")
        print ("")
    }
}


