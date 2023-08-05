import SwiftUI
import Ditto

extension CGFloat {
    static let buttonHeight = CGFloat(40)
    static let buttonRadius = CGFloat(7)
    static let deviceMargin = CGFloat(10)
    static let barHeight = CGFloat(16)
    static let cardRadius = CGSize.card.height*0.1
}
 
extension CGSize {
    static let device = System.screen
    static let statusbar = CGSize(width: device.width, height: 60)
    static let container = CGSize(width: device.width, height: device.height - statusbar.height - homebar.height - header.height)
    static let header = CGSize(width: device.width, height: .buttonHeight)
    static let homebar = CGSize(width: device.width, height: 35)
    static let dashboard = CGSize(width: container.width, height: 80)
    static let collection = CGSize(width: container.width, height: container.width*0.66)
    static let list = CGSize(width: container.width, height: container.height - dashboard.height - collection.height)
    static let card = collection.x(0.9)
}
