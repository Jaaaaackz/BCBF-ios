//
//  Friend.swift
//  BCBF
//
//  Created by user216835 on 4/21/22.
//

import UIKit
//import FirebaseFirestoreSwift
import CoreData

enum Status:Int{
    case offline=0
    case online=1
}

enum CodingKeys:String,CodingKey{
    case id
    case nickname
    case appointment
    case statu
    case accountIcon
}

class Friend: NSObject,Codable {
    var id: String?
    var nickname: String?
    //var accountIcon:UIImage?
    var appointment:[String?]=[]
    var statu:Int?
}

extension Friend{
    var friendStatu:Status{
        get{
            return Status(rawValue:self.statu!)!
        }
        set{
            self.statu=newValue.rawValue
        }
    }
}
