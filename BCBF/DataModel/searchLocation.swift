//
//  searchLocation.swift
//  BCBF
//
//  Created by user216835 on 5/21/22.
//

import UIKit


class searchLocation: NSObject,Codable {
    var name: String
    var city:String
    
    init(name:String,city:String){
        self.name=name
        self.city=city
        
    }
}
