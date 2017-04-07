//
//  Route.swift
//  GTFS
//
//  Created by Samuel Daly on 12/10/16.
//  Copyright © 2016 zbrowne. All rights reserved.
//

import Foundation

/*
 The goal of this code is to import route information data so we can draw route maps.
 
 Here is thr source: http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=sf-muni&r=N
 
 VARIABLE DEFINITIONS:
 
 Source (page 8): https://www.nextbus.com/xmlFeedDocs/NextBusXMLFeed.pdf
 */

import Foundation
import Mapbox

class Route {
    var routeTag: String
    var routeDict: [Int:[CLLocationCoordinate2D]]
    
    init(routeTag: String,
         routeDict: [Int:[CLLocationCoordinate2D]])  {
        
        self.routeTag = routeTag
        self.routeDict = routeDict
    }
}
