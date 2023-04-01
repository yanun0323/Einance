import SwiftUI
import SQLite
import UIComponent

struct Sql {
    static private var db: Connection? = nil
}

extension Sql {
    static func GetDriver() -> Connection {
        if let conn = db {
            return conn
        }
        return self.Init(isMock: true)
    }
    
    static func Init(isMock: Bool) -> Connection {
        var dbName = "development"
        if !isMock {
            dbName = "production"
        }
        let conn = try! Connection(filePath(dbName).absoluteString)
        conn.busyTimeout = 5
        conn.Init()
        
        db = conn
        return db!
    }
    
    static private func filePath(_ filename: String) -> URL {
        return try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(filename).sqlite")
    }
}

extension Connection {
    func Init() {
        System.Catch("migrate tables") {
            try Tag.migrate(self)
            try Record.migrate(self)
            try Card.migrate(self)
            try Budget.migrate(self)
        }
    }
}


