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
    func onInvalidToken()
}

protocol UserDataManaging {
    associatedtype DataType: UserData
    associatedtype DataContainer: DataProtocol
    
    var delegate: UserDataManagerFlowDelegate? { get set }
    var data: DataContainer? { get set }
    var token: String? { get }
    func loadFromRepository() // for offline loading
    func fetch() async throws // default implementation for online loading for all data managers
    func fetch(withToken token: String) async throws // for online loading
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
