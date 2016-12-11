//
//  Route.swift
//  GTFS
//
//  Created by Samuel Daly on 12/10/16.
//  Copyright © 2016 zbrowne. All rights reserved.
//

import Foundation

/* The goal of this code is to import route information data so we can draw route maps. 
 
 Here is thr source: http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=sf-muni&r=N
 
 VARIABLE DEFINITIONS:
 
 Source (page 8): https://www.nextbus.com/xmlFeedDocs/NextBusXMLFeed.pdf
 
 The route data returned has multiple attributes. These are:
        tag – unique alphanumeric identifier for route, such as “N”.
        title – the name of the route to be displayed in a User Interface, such as “N-Judah”.
        shortTitle – for some transit agencies shorter titles are provided that can be useful for
            User Interfaces where there is not much screen real estate, such as on smartphones.
            This element is only provided where a short title is actually available. If a short title is
            not available then the regular title element should be used.
        color – the color in hexadecimal format associated with the route. Useful for User
            Interfaces such as maps.
        oppositeColor – the color that most contrasts with the route color. Specified in
            hexadecimal format. Useful for User Interfaces such as maps. Will be either black
            or white.
        latMin, latMax, lonMin, lonMax – specifies the extent of the route.
 
 stopID (string) -A stop has the following attributes:
        tag – unique alphanumeric identifier for stop, such as “cp_1321”. Even if the stop tags
            appear to usually be numeric they can sometimes contain alphabetical characters.
            Therefore the stop tags cannot be used as a number for telephone systems and other
            such applications. For larger agencies such as Toronto TTC suffixes "_IB" and “_OB"
            are included at the end of the stop tag for the rare situations when an agency has
            defined only a single stop for both directions and the stop is not an arrival at the end of
            the route (in cases of arrivals “_ar” is used). This means that the stop tag might not
            always correspond to GTFS or other configuration data. These suffixes allow duplicate
            stops to have the identical stopID as the original stop while preserving both unique
            stops in the system. "_IB" represents a duplicated inbound stop, and "_OB" represents
            a duplicated outbound stop.
 
        title – the name of the stop to displayed in a User Interface, such as “5th St & Main,
            City Hall”.
 
        shortTitle – some transit agencies define short version of the title that are useful for
            applications where screen real estate is limited. This element is only provided when
            a separate short title exists.
 
        lat/lon – specify the location of the stop.
 
        stopId – an optional numeric ID to identify a stop. Useful for telephone or SMS
            systems so that a user can simply enter the numeric ID to identify a stop instead of
            having to select a route, direction, and stop. Not all transit agencies have numeric IDs
            to identify a stop so this element will not always be available.
 
 A direction has the following attributes:
        tag – unique alphanumeric identifier for the direction.
            title – the name of the direction to be displayed in the User Interface, such as “Inbound
            to Caltrain Station”.
        name – a simplified name so that directions can be grouped together. If there are several
            Inbound directions for example then they can all be grouped together because they will all
            have the same name “Inbound”. This element is not available for all transit agencies.
        List of stops – within the direction there is a list of stops in order. This are useful for
            creating a User Interface where the user selects a route, direction, and then stop in
            order to obtain predictions.
 
 We will parse this data in to make it digestable
 
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
