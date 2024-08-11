//
//  CheckSum.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

class RealmCheckSumData: Object {
    @objc dynamic var checkSumID: String = "checksum" // Single instance identified by a constant ID
    @objc dynamic var userPoints: String = ""
    @objc dynamic var rank: String = ""
    @objc dynamic var messages: String = ""
    @objc dynamic var events: String = ""
    @objc dynamic var points: String = ""
    
    override static func primaryKey() -> String? {
        "checkSumID"
    }
    
    override required init() {
        super.init()
    }
    // Internal initializer to create RealmCheckSumData from CheckSumData
    internal init(from checkSumData: CheckSumData) {
        super.init()
        self.userPoints = checkSumData.userPoints
        self.rank = checkSumData.rank
        self.messages = checkSumData.messages
        self.events = checkSumData.events
        self.points = checkSumData.points
    }
    
    func toCheckSumData() -> CheckSumData? {
        return CheckSumData(from: self)
    }
}
