//
//  NightLocation+CoreDataProperties.swift
//  BCBF
//
//  Created by user216835 on 5/6/22.
//
//

import Foundation
import CoreData


extension NightLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NightLocation> {
        return NSFetchRequest<NightLocation>(entityName: "NightLocation")
    }

    @NSManaged public var times: Int32
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var user: NSSet?

}

// MARK: Generated accessors for user
extension NightLocation {

    @objc(addUserObject:)
    @NSManaged public func addToUser(_ value: User)

    @objc(removeUserObject:)
    @NSManaged public func removeFromUser(_ value: User)

    @objc(addUser:)
    @NSManaged public func addToUser(_ values: NSSet)

    @objc(removeUser:)
    @NSManaged public func removeFromUser(_ values: NSSet)

}

extension NightLocation : Identifiable {

}
