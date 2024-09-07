//
//  ProfileViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.09.2024.
//

import Foundation
import UIKit
import CoreImage.CIFilterBuiltins

protocol ProfileViewModeling: BaseClass, ObservableObject {
    associatedtype settingBarVM: SettingsBarViewModeling
    var settingsViewModel: settingBarVM { get }
    
    var isLoading: Bool { get }
    var isFullyRegistered: Bool { get }
    var username: String { get }
    var userGender: UserGender { get }
    var email: String { get }
    var mainCategory: String { get }
    var name: String { get }
    var phoneNumber: String { get }
    var postalCode: String { get }
    var birthday: String { get }
    var age: Int { get }
    var isMinor: Bool { get }
    var parentName: String { get }
    var parentEmail: String { get }
    var parentPhone: String { get }
    var parentRelation: String { get }
    
    func inviteFriend()
    func startRegistration()
    func navigateBack()
}

final class ProfileViewModel<settingBarVM: SettingsBarViewModeling>: BaseClass, ObservableObject, ProfileViewModeling {
    typealias Dependencies = HasLoggers & HasNetworkMonitor & HasRealm & SettingsBarViewModel.Dependencies & HasUserCategoryManager
    
    // MARK: - Private properties
    
    private weak var delegate: ProfileFlowDelegate?
    private let logger: LoggerServicing
    private let networkMonitor: NetworkMonitoring
    private var isOnline: Bool { networkMonitor.onlineStatus }
    private let userManager: UserManaging
    private let userCategoryManager: any UserCategoryManaging
    private var loggedInUser: LoggedInUser? { userManager.loggedInUser }
    
    // MARK: - Public properties
    
    var settingsViewModel: settingBarVM
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isFullyRegistered: Bool = false
    @Published private(set) var username: String = ""
    @Published private(set) var userGender: UserGender = .male
    @Published private(set) var email: String = ""
    @Published private(set) var mainCategory: String = ""
    @Published private(set) var name: String = ""
    @Published private(set) var phoneNumber: String = ""
    @Published private(set) var postalCode: String = ""
    @Published private(set) var birthday: String = ""
    @Published private(set) var age: Int = 0
    @Published private(set) var isMinor: Bool = false
    @Published private(set) var parentName: String = ""
    @Published private(set) var parentEmail: String = ""
    @Published private(set) var parentPhone: String = ""
    @Published private(set) var parentRelation: String = ""
    
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies,
         delegate: ProfileFlowDelegate? = nil,
         settingsDelegate: SettingsBarFlowDelegate?
    ) {
        self.logger = dependencies.logger
        self.networkMonitor = dependencies.networkMonitor
        self.delegate = delegate
        self.userManager = dependencies.userManager
        self.userCategoryManager = dependencies.userCategoryManager
        self.settingsViewModel = settingBarVM.init(
            dependencies: dependencies,
            delegate: settingsDelegate
        )
        self.settingsViewModel.hideProfileNavigationOption()
        
        super.init()
        self.loadData()
    }
    
    // MARK: - Public interface
    
    func inviteFriend() {
        Task { @MainActor [weak self] in
            self?.isLoading = true
            defer { self?.isLoading = false }
            guard let qrString = await self?.qrString(),
                  let image = self?.generateQRCode(from: qrString) else {
                self?.delegate?.generateQRDidFail()
                return
            }
            self?.delegate?.generateQR(content: image)
        }
    }
    
    func navigateBack() {
        delegate?.returnToHomeScreen()
    }
    
    func startRegistration() {
        delegate?.startRegistration()
    }
    
    // MARK: - Private Helpers
    
    private func qrString() async -> String? {
        guard let user = userManager.loggedInUser else { return nil }
        
        // 1. Base64 encode the userId and make it URL-safe
        let base64UserId = user.userId.data(using: .utf8)?
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        // 2. Get the signature (online mode) or use the user's token (offline mode)
        let isOffline = !isOnline
        let key3Value = isOffline ? "true" : "false"
        guard let key2Value = await key2value() else { return nil }
        let key4Value = "Life is Skill"
        
        // 3. Percent encode values and manually encode curly braces
        let ref = "ref"  // Replace with the actual reference
        let encodedUserNick = user.nick.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBase64UserId = base64UserId ?? ""
        let encodedKey2Value = key2Value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedKey3Value = key3Value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedKey4Value = key4Value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // 4. Manually add encoded curly braces around the values
        let qrCodeString =
             """
             \(APIUrl.qrUrl)/ref/task=%7B\(ref)%7D&key=%7B\(encodedUserNick)%7D&key1=%7B\(encodedBase64UserId)%7D&key2=%7B\(encodedKey2Value)%7D&key3=%7B\(encodedKey3Value)%7D&game=%7B\(encodedKey4Value)%7D
             """
        
        print("QR: \(qrCodeString)")
        return qrCodeString
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
    
    private func loadData() {
        guard let user = loggedInUser,
              let mainCat = userCategoryManager.getMainCategory()
        else {
            delegate?.loadUserDataDidFail()
            return
        }
        username = user.nick
        email = user.email
        userGender = user.sex
        mainCategory = mainCat.description
        isFullyRegistered = user.fullActivation
        guard isFullyRegistered else {
            return
        }
        loadUserData()
        guard isMinor else {
            return
        }
        loadParentData()
    }
    
    private func loadUserData() {
        guard let user = loggedInUser else {
            return
        }
        
        name = "\(user.name ?? "") \(user.surname ?? "")".trimmingCharacters(in: .whitespaces)
        phoneNumber = user.mobil ?? ""
        postalCode = user.postalCode ?? ""
        age = user.age
        isMinor = age < User.ageWhenConsideredNotMinor
        birthday = user.birthday.map { Formatters.date.string(from: $0) } ?? ""
    }
    
    private func loadParentData() {
        guard let user = loggedInUser else {
            return
        }
        parentName = "\(user.nameParent ?? "") \(user.surnameParent ?? "")".trimmingCharacters(in: .whitespaces)
        parentEmail = user.emailParent ?? ""
        parentPhone = user.mobilParent ?? ""
        parentRelation = user.relation ?? ""
    }
    
    
    private func getSignature() async throws -> String {
        guard let signature = await userManager.signature() else {
            throw BaseError(
                context: .system,
                message: "Unable to fetch signature for user",
                logger: logger
            )
        }
        return signature
    }
    
    private func key2value() async -> String? {
        guard isOnline else {
            return loggedInUser?.token
        }
        do {
            return try await getSignature()
        } catch {
            return nil
        }
    }
}
