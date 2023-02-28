//
//  BudgetMO+CoreDataProperties.swift
//  Einance
//
//  Created by YanunYang on 2023/2/27.
//
//

import Foundation
import CoreData


extension BudgetMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BudgetMO> {
        return NSFetchRequest<BudgetMO>(entityName: "BudgetMO")
    }

    @NSManaged public var uuid: UUID
    @NSManaged public var start: Date
    @NSManaged public var amount: NSDecimalNumber
    @NSManaged public var balance: NSDecimalNumber
    @NSManaged public var cost: NSDecimalNumber
    @NSManaged public var cards: Set<CardMO>

}

// MARK: Generated accessors for cards
extension BudgetMO {

    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: CardMO)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: CardMO)

    @objc(addCards:)
    @NSManaged public func addToCards(_ values: Set<CardMO>)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: Set<CardMO>)

}

extension BudgetMO : Identifiable {}

extension BudgetMO {
    
    func CreateBudget() -> Budget {
         
    }
}
