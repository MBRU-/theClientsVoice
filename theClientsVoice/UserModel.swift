//
//  UserModel.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 11.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//

import Foundation
import CoreData

@objc(UserModel)

class UserModel: NSManagedObject {

    @NSManaged var userName: String
    @NSManaged var password: String
    @NSManaged var isAdmin: NSNumber
    @NSManaged var isLogedin: NSNumber

}
