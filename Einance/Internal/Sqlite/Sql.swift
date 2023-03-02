import SwiftUI
import SQLite

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
        let path = "file:///Users/yanun/Desktop/Project/Xcode/database.sqlite"
        print("[DEBUG] database file path: \(path)")
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
    
    static private func mockFilePath(_ filename: String) -> URL {
        return try! FileManager.default.url(for: .userDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            .appendingPathComponent("yanun/Desktop/Project/Xcode/\(filename).sqlite")
    }
}

extension Connection {
    func Init() {
        do {
            
            try Record.migrate(self)
            try Card.migrate(self)
            try Budget.migrate(self)
            
        } catch {
            print("[ERROR] migrate tables failed, err: \(error)")
        }
    }
}
