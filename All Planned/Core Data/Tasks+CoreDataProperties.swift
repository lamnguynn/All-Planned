//
//  Tasks+CoreDataProperties.swift
//  All Planned
//
//  Created by Lam Nguyen on 2/1/21.
//
//

import Foundation
import CoreData


extension Tasks {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tasks> {
        return NSFetchRequest<Tasks>(entityName: "Tasks")
    }

    @NSManaged public var day: String?
    @NSManaged public var subject: String?
    @NSManaged public var dayDate: String?

}

extension Tasks : Identifiable {

}
