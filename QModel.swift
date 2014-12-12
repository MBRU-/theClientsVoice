//
//  QModel.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 12.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//

import Foundation
import CoreData

@objc(QModel)

class QModel: NSManagedObject {

    @NSManaged var index: NSNumber
    @NSManaged var isDefault: NSNumber
    @NSManaged var question: String

}
