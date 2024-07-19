//
//  UserDataManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.07.2024.
//

import Foundation

protocol UserData: Codable {
    var id: String { get }
}

protocol UserDataManagerFlowDelegate: NSObject {
    func onUpdate()
}

protocol UserDataManaging {
    associatedtype DataType: UserData
    associatedtype DataContainer: DataProtocol
    
    var data: DataContainer? { get set }
    func fetch(userToken: String?) async throws
    func getAll() -> [DataType]
    func getById(id: String) -> DataType?
}



