//
//  RealmSponsorData.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.08.2024.
//

import Foundation
import RealmSwift

class RealmSponsorData: Object {
    @objc dynamic var sponsorID: String = ""
    @objc dynamic var imageData: Data? = nil
    
    override static func primaryKey() -> String? {
        "sponsorID"
    }
    
    // Convenience initializer to create a RealmSponsorData object
    convenience init(sponsorID: String, imageData: Data) {
        self.init()
        self.sponsorID = sponsorID
        self.imageData = imageData
    }
}
