//
//  Vehicle.swift
//  GTFS
//
//  Created by Zachary Browne on 9/25/16.
//  Copyright © 2016 zbrowne. All rights reserved.
//

/*
 
VARIABLE DEFINITIONS:
 source - http://www.nextbus.com/xmlFeedDocs/NextBusXMLFeed.pdf
 
id (string) – Identifier of the vehicle. It is often but not always numeric.
 
routeTag (string) - Specifies the ID of the route the vehicle is currently associated with.

dirTag (string) - Specifies the ID of the direction that the vehicle is currently on. The
 direction ID is usually the same as a trip pattern ID, but is very different from the
 tripTag. A direction or trip pattern ID specifies the configuration for a trip. It can be used
 multiple times for a block assignment. But a tripTag identifies a particular trip within a
 block assignment.

lat/lon – specify the location of the vehicle.

secsSinceReport (int) – How many seconds since the GPS location was actually
 recorded. It should be noted that sometimes a GPS report can be several minutes old.

predictable (boolean) – Specifies whether the vehicle is currently predictable.

heading (int) – Specifies the heading of the vehicle in degrees. Will be a value between 0
 and 360. A negative value indicates that the heading is not currently available.

speedKmHr (double) – Specifies GPS based speed of vehicle.
 */

import Foundation
import Mapbox

class Vehicle: NSObject, MGLAnnotation {
    var title: String?
    var routeTag: String
    var dirTag: String?
    dynamic var coordinate: CLLocationCoordinate2D
    var secsSinceReport: Int
    var predictable: Bool
    var heading: Double
    var speedKmHr: Double
    var leadingVehicleId: String?
    
    init(title: String?,
         routeTag: String,
         dirTag: String?,
         lat: CLLocationDegrees,
         lon: CLLocationDegrees,
         secsSinceReport: Int,
         predictable: Bool,
         heading: Double,
         speedKmHr: Double,
         leadingVehicleId: String?) {
        
        self.title = title
        self.routeTag = routeTag
        self.dirTag = dirTag
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.secsSinceReport = secsSinceReport
        self.predictable = predictable
        self.heading = heading
        self.speedKmHr = speedKmHr
        self.leadingVehicleId = leadingVehicleId
    }
}
