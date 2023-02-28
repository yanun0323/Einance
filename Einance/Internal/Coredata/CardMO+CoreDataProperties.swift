//
//  CardMO+CoreDataProperties.swift
//  Einance
//
//  Created by YanunYang on 2023/2/27.
//
//

import Foundation
import CoreData


extension CardMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardMO> {
        return NSFetchRequest<CardMO>(entityName: "CardMO")
    }

    @NSManaged public var uuid: UUID
    @NSManaged public var name: String
    @NSManaged public var amount: NSDecimalNumber
    @NSManaged public var display: Int16
    @NSManaged public var color: NSObject
    @NSManaged public var fixed: Bool
    @NSManaged public var index: Int64
    @NSManaged public var budget: BudgetMO?
    @NSManaged public var records: Set<RecordMO>

}

// MARK: Generated accessors for records
extension CardMO {

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: CardMO)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: CardMO)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: Set<RecordMO>)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: Set<RecordMO>)

}

extension CardMO : Identifiable {}
