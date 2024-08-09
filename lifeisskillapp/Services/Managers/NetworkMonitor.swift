//
//  NetworkManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 08.08.2024.
//

import Foundation
import Network
import Combine

protocol NetworkManagerFlowDelegate: AnyObject {
    func onNoInternetConnection()
}

protocol HasNetworkMonitor {
    var networkMonitor: NetworkMonitoring { get }
}

protocol NetworkMonitoring: AnyObject {
    var delegate: NetworkManagerFlowDelegate? { get set }
    var isOnline: Bool { get }
    var onlineStatusPublisher: AnyPublisher<Bool, Never> { get }
    func startMonitoring()
    func stopMonitoring()
}

public final class NetworkMonitor: BaseClass, NetworkMonitoring {
    typealias Dependencies = HasLoggerServicing
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private var monitor: NWPathMonitor
    private let queue: DispatchQueue
    private var onlineStatusSubject = CurrentValueSubject<Bool, Never>(true)
    
    // MARK: - Public Properties
    
    weak var delegate: NetworkManagerFlowDelegate?
    @Published private(set) var isOnline: Bool = true
    var onlineStatusPublisher: AnyPublisher<Bool, Never> {
        onlineStatusSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.monitor = NWPathMonitor()
        self.queue = DispatchQueue(label: "NetworkMonitor")
        super.init()
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public Interface
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.handleNetworkChange(path: path)
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    // MARK: - Private Helpers
    
    private func handleNetworkChange(path: NWPath) {
        let status = path.status == .satisfied
        updateOnlineStatus(status: status)
        guard !status else { return }
        delegate?.onNoInternetConnection()
    }
    
    private func updateOnlineStatus(status: Bool) {
        Task { @MainActor in
            self.isOnline = status
            self.onlineStatusSubject.send(status)
        }
    }
}
