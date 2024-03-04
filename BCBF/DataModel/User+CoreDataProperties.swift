//
//  User+CoreDataProperties.swift
//  BCBF
//
//  Created by user216835 on 5/6/22.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var username: String?
    @NSManaged public var nickname: String?
    @NSManaged public var whatsUp: String?
    @NSManaged public var nightRecords: NightLocation?

}

extension User : Identifiable {

}
