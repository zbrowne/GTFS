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
    
    var entryError: String?
    var entryVehicle: String?
    var entryLastTime: String?
    
    var currentParsedElement = String()
    var weAreInsideAnItem = false
    
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
            
            // printing output for debugging
            print (data)
            print ("line number " + String(self.xmlParser.lineNumber))
            print ("task completed")
            
        }.resume()
    }
    
    private func parser(parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName: String?,
                attributes attributeDict: [NSObject : AnyObject]){
        print ("didStartElement")
        if elementName == "body" {
            weAreInsideAnItem = true
        }
        print ("weAreInsideAnItem is " + String(weAreInsideAnItem))
        if weAreInsideAnItem {
            switch elementName {
            case "error":
                entryError = String()
                currentParsedElement = "error"
            case "vehicle":
                entryVehicle = String()
                currentParsedElement = "vehicle"
            case "lastTime":
                entryLastTime = String()
                currentParsedElement = "lastTime"
            default: break
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        //printing output for debugging
        print ("running foundCharacters")
        print (weAreInsideAnItem)
        Elements.append(string)
        print (string)
        print ("String is " + String(string.characters.count) + " characters long")
        print (String(Elements.count) + " elements parsed")
        
        if weAreInsideAnItem {
            switch currentParsedElement {
            case "error":
                entryError = entryError! + string
            case "vehicle":
                entryVehicle = entryVehicle! + string
            case "lastTime":
                entryLastTime = entryLastTime! + string
            default: break
            }
        }
    }
}


