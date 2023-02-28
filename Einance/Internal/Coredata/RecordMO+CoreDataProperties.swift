//
//  RecordMO+CoreDataProperties.swift
//  Einance
//
//  Created by YanunYang on 2023/2/27.
//
//

import Foundation
import CoreData


extension RecordMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecordMO> {
        return NSFetchRequest<RecordMO>(entityName: "RecordMO")
    }

    @NSManaged public var uuid: UUID
    @NSManaged public var date: Date
    @NSManaged public var cost: NSDecimalNumber
    @NSManaged public var memo: String
    @NSManaged public var card: CardMO?

}

extension RecordMO : Identifiable {}
