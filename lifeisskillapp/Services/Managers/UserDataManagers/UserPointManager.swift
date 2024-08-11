//
//  UserPointManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 16.07.2024.
//

import Foundation
import Combine

protocol UserPointManagerFlowDelegate: UserDataManagerFlowDelegate {
}

protocol HasUserPointManager {
    var userPointManager: any UserPointManaging { get }
}

protocol UserPointManaging: UserDataManaging where DataType == UserPoint, DataContainer == UserPointData {
    var delegate: UserPointManagerFlowDelegate? { get set }
    func getPoints(byCategory categoryId: String) -> [UserPoint]
    func getTotalPoints(byCategory categoryId: String) -> Int
}

public final class UserPointManager: BaseClass, UserPointManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasPersistentUserDataStoraging & HasUserLoginManager
    
    // MARK: - Private Properties
    
    private var storage: PersistentUserDataStoraging
    private let logger: LoggerServicing
    private let dataManager: UserLoginDataManaging
    private let userDataAPIService: UserDataAPIServicing
    private var cancellables = Set<AnyCancellable>()
    private var checkSum: String?
    
    // MARK: - Public Properties
    
    /*
     TODO: need to resolve whether it is necessary to be declared public or can be set during init (which class will be responsible for onUpdate)
     Now it can be set from anywhere, needs to be handled with caution.
     */
    weak var delegate: UserPointManagerFlowDelegate?
    
    var data: UserPointData? {
        get {
            storage.userPointData
        }
        set {
            storage.userPointData = newValue
        }
    }
    
    var token: String? {
        get { dataManager.token }
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.storage = dependencies.storage
        self.logger = dependencies.logger
        self.dataManager = dependencies.userLoginManager
        self.userDataAPIService = dependencies.userDataAPI
        self.checkSum = storage.checkSumData?.userPoints
        
        super.init()
        self.load()
        self.setupBindings()
    }
    
    // MARK: - deinit
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Public Interface
    
    func fetch(withToken token: String) async throws {
        logger.log(message: "Loading user points")
        do {
            let response = try await userDataAPIService.getUserPoints(baseURL: APIUrl.baseURL, userToken: token)
            data = response.data
            delegate?.onUpdate()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to load user points",
                logger: logger
            )
        }
    }
    
    func getById(id: String) -> UserPoint? {
        data?.data.first { $0.id == id }
    }
    
    func getAll() -> [UserPoint] {
        data?.data ?? []
    }
    
    func getPoints(byCategory categoryId: String) -> [UserPoint] {
        data?.data.filter { $0.pointCategory.contains(categoryId) } ?? []
    }
    
    func getTotalPoints(byCategory categoryId: String) -> Int {
        // returns total for user points that are valid
        return getPoints(byCategory: categoryId)
            .filter { $0.doesPointCount }
            .reduce(0) { $0 + $1.pointValue }
    }
    
    // MARK: - Private Helpers
    
    private func load() {
        Task { @MainActor [weak self] in
            await self?.storage.loadFromRepository(for: .userPoints)
        }
    }
    
    private func setupBindings() {
        storage.checkSumDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] checkSumData in
                self?.update(newCheckSum: checkSumData?.userPoints)
            }
            .store(in: &cancellables)
    }
    
    private func update(newCheckSum: String?) {
        self.checkSum = newCheckSum
        guard let newCheckSum else { return }
        Task { @MainActor [weak self] in
            try await self?.fetch()
        }
    }
}
