//
//  mapSetting.swift
//  BCBF
//
//  Created by user216835 on 5/16/22.
//

import UIKit
import MapKit


class mapSetting: NSObject {
    var MomentShow: Bool
    var ScenicSpotShow:Bool
    var MapType:MKMapType
    
    init(MomentShow:Bool,ScenicSpotShow:Bool,MapType:MKMapType){
        self.MomentShow=MomentShow
        self.ScenicSpotShow=ScenicSpotShow
        self.MapType=MapType
    }
}
