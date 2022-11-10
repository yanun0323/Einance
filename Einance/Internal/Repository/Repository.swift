//
//  Repository.swift
//  Einance
//
//  Created by YanunYang on 2022/11/10.
//

import Foundation

protocol Repository: DataRepository {}

protocol DataRepository {
    func GetBudget() -> Budget
    func GetCurrentCard() -> Card
}
