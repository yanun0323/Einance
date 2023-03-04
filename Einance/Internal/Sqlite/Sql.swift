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
#if DEBUG
        print("[DEBUG] database file path: \(filePath("database").absoluteString)")
#endif
        var conn = try! Connection()
        if !isMock {
            conn = try! Connection(filePath("database").absoluteString)
        }
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
            try Record.migrate(self)
            try Card.migrate(self)
            try Budget.migrate(self)
        }
    }
}
