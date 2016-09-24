//
//  ViewController.swift
//  GTFS
//
//  Created by Zachary Browne on 9/23/16.
//  Copyright © 2016 zbrowne. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, XMLParserDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let urlString = "http://webservices.nextbus.com/service/publicXMLFeed?command=vehicleLocations&a=sf-muni"
        beginParsing(urlString: urlString)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - XML Parsing Code
    func beginParsing(urlString:String){
        guard let myURL = NSURL(string:urlString) else {
            print("URL not defined properly")
            return
        }
        guard let parser = XMLParser(contentsOf: myURL as URL) else {
            print("Cannot Read Data")
            return
        }
        parser.delegate = self
        if !parser.parse(){
            print("Data Errors Exist:")
            let error = parser.parserError!
            print("Error Description:\(error.localizedDescription)")
            print("Line number: \(parser.lineNumber)")
        }
        tableView.reloadData()
    }
}


