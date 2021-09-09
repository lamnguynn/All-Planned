//
//  Note+CoreDataProperties.swift
//  All Planned
//
//  Created by Lam Nguyen on 1/31/21.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var noteText: String?
    @NSManaged public var taskName: String?

}

extension Note : Identifiable {

}
