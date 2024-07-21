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
    func fetch(credentials: LoginCredentials?, userToken: String?) async throws
    func getAll() -> [DataType]
    func getById(id: String) -> DataType?
}

extension UserDataManaging {
    func fetch(userToken: String?) async throws {
        try await fetch(credentials: nil, userToken: userToken)
    }
    func fetch(credentials: LoginCredentials?) async throws {
        try await fetch(credentials: credentials, userToken: "")
    }
}



