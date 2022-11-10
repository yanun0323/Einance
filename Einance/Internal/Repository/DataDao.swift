//
//  DataDao.swift
//  Einance
//
//  Created by YanunYang on 2022/11/11.
//

import Foundation

protocol DataDao {}

extension DataDao where Self: DataRepository {
    func GetBudget() -> Budget {
        return .preview
    }
    
    func GetCurrentCard() -> Card {
        return .preview
    }
}
