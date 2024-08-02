//
//  UserDataManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.07.2024.
//

import Foundation

protocol UserData: Codable, Identifiable {
    var id: String { get }
}

protocol UserDataManagerFlowDelegate: NSObject {
    func onUpdate()
}

protocol UserDataManaging {
    associatedtype DataType: UserData
    associatedtype DataContainer: DataProtocol
    
    var data: DataContainer? { get set }
    var token: String? { get }
    func fetch() async throws
    func fetch(withToken token: String) async throws
    func getAll() -> [DataType]
    func getById(id: String) -> DataType?
}

extension UserDataManaging {
    func fetch() async throws {
        guard let token else {
            throw BaseError(context: .api,
                            message: "Needs User Token To Fetch Data",
                            logger: appDependencies.logger)
        }
        try await fetch(withToken: token) // Call the method with the token
    }
}
