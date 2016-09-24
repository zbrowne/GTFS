//
//  gtfsFeed.swift
//  GTFS
//
//  Created by Zachary Browne on 9/23/16.
//  Copyright © 2016 zbrowne. All rights reserved.
//

import UIKit

class BikeRow:NSObject {
    var date:NSDate! = NSDate()
    var northBound:Int! = nil
    var southBound:Int! = nil
    override init(){}
    init(date:NSDate,northBound:Int,southBound:Int){
        self.date = date
        self.northBound = northBound
        self.southBound = southBound
    }
}


class BikeModel: NSObject {
    var data:[BikeRow] = []
    var maxSouthBound = 0
    var maxNorthBound = 0
    func addRow(row:BikeRow){
        data += [row]
        if row.northBound > maxNorthBound{
            maxNorthBound = row.northBound
        }
        if row.southBound > maxSouthBound{
            maxSouthBound = row.southBound
        }
        
    }
}
