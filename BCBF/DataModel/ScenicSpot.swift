//
//  ScenicSpot.swift
//  BCBF
//
//  Created by user216835 on 5/9/22.
//

import UIKit


class ScenicSpot: NSObject,Codable {
    var name: String
    var lon:Double
    var lat:Double
    
    init(name:String,lon:Double,lat:Double){
        self.name=name
        self.lon=lon
        self.lat=lat
    }
}
