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
    func fetch(withToken token: String) async throws // Method with token
    func getAll() -> [DataType]
    func getById(id: String) -> DataType?
}

extension UserDataManaging {
    func fetch(userToken: String?) async throws {
        guard let token = userToken else {
            throw BaseError(context: .api,
                            message: "Needs User Token To Fetch Data",
                            logger: appDependencies.logger)
        }
        try await fetch(withToken: token) // Call the method with the token
    }
}
