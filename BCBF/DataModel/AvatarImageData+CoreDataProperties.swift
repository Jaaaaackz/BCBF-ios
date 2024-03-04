//
//  AvatarImageData+CoreDataProperties.swift
//  BCBF
//
//  Created by user216835 on 5/16/22.
//
//

import Foundation
import CoreData


extension AvatarImageData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AvatarImageData> {
        return NSFetchRequest<AvatarImageData>(entityName: "AvatarImageData")
    }

    @NSManaged public var filename: String?

}

extension AvatarImageData : Identifiable {

}
