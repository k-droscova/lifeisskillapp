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

protocol UserDataManaging where Self: HasNetworkMonitor {
    associatedtype DataType: UserData
    associatedtype DataContainer: DataProtocol
    
    var token: String? { get }
    func loadData() async throws
    func loadFromRepository() async // for offline loading
    func fetch() async throws // default implementation for online loading for all data managers
    func fetch(withToken token: String) async throws // for online loading
    func getAll() -> [DataType]
    func getById(id: String) -> DataType?
    func checkSum() -> String?
    func onLogout()
}

extension UserDataManaging {
    func fetch() async throws {
        guard let token else {
            throw BaseError(context: .api,
                            message: "Needs User Token To Fetch Data",
                            code: ErrorCodes.general(.missingToken),
                            logger: appDependencies.logger)
        }
        try await fetch(withToken: token) // Call the method with the token
    }
    
    func loadData() async throws {
        guard networkMonitor.onlineStatus else {
            await loadFromRepository()
            return
        }
        try await fetch()
    }
}
