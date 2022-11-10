//
//  MockDao.swift
//  Einance
//
//  Created by YanunYang on 2022/11/10.
//

import Foundation

struct MockDao {
    private var budget: Budget = .preview
    private var current: Card = .preview
}

extension MockDao: Repository {
    func GetBudget() -> Budget {
        return budget
    }
    
    func GetCurrentCard() -> Card {
        return current
    }
}
