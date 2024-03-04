//
//  DatabaseProtocol.swift
//  BCBF
//
//  Created by user216835 on 5/6/22.
//

import Foundation

enum DatabaseChange{
    case add
    case remove
    case update
}
enum ListenerType{
    case user
    case nightLocation
    case all
}

protocol DatabaseListener:AnyObject{
    var listenerType:ListenerType{get set}
    func onUserChange(change:DatabaseChange,userNightLocation:[NightLocation])
    func onNightLocationChange(change:DatabaseChange,userNightLocation:[NightLocation])
}

protocol DatabaseProtocol: AnyObject{
    func cleanup()
    
    func addListener(listener:DatabaseListener)
    func removeListener(listener:DatabaseListener)
    
    func addNightLocation(times:Int32, latitude:Double,longitude:Double)->NightLocation
    func deleteNightLocation(nightLocation:NightLocation)
    
    var defaultUser:User{get}
    
    func addUser(userName:String,nickName:String,whatsUp:String)->User
    func deleteUser(user:User)
    func addNightLocationToUser(nightLocation:NightLocation,user:User)
    func removeNightLocationFromUser(nightLocation:NightLocation,user:User)
}
