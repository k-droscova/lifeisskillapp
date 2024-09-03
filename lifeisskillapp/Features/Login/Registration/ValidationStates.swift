//
//  ValidationStates.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 31.08.2024.
//

import Foundation
import SwiftUI

protocol ValidationState {
    var validationMessage: LocalizedStringKey? { get }
    var isValid: Bool { get }
}

/// Default implementation with initial and valid states
protocol BaseValidationState: ValidationState, Equatable {
    static var initial: Self { get }
    static var empty: Self { get }
    static var valid: Self { get }
}

extension BaseValidationState {
    var isValid: Bool { self == Self.valid }
    var validationMessage: LocalizedStringKey? {
        switch self {
        case Self.empty:
            return "register.validation.empty"
        default:
            return nil
        }
    }
}

// MARK: - implementation for different textfields

enum UsernameValidationState: BaseValidationState {
    case initial
    case valid
    case empty
    case short
    case alreadyTaken
    
    var validationMessage: LocalizedStringKey? {
        switch self {
        case .alreadyTaken:
            return "register.validation.username.taken"
        case .short:
            return LocalizedStringKey(String(format: NSLocalizedString("register.validation.username.short", comment: ""), String(Username.minLength)))
        default:
            return nil
        }
    }
}

enum EmailValidationState: BaseValidationState {
    case initial
    case valid
    case empty
    case invalidFormat
    case alreadyTaken
    
    var validationMessage: LocalizedStringKey? {
        switch self {
        case .invalidFormat:
            return "register.validation.email.format"
        case .alreadyTaken:
            return "register.validation.email.taken"
        default:
            return nil
        }
    }
}

enum PasswordValidationState: BaseValidationState {
    case initial
    case valid
    case empty
    case invalidFormat
    
    var validationMessage: LocalizedStringKey? {
        switch self {
        case .invalidFormat:
            return LocalizedStringKey(String(format: NSLocalizedString("register.validation.password.format", comment: ""), String(Password.minLenght)))
        default:
            return nil
        }
    }
}

enum ConfirmPasswordValidationState: BaseValidationState {
    case initial
    case valid
    case empty
    case mismatching
    
    var validationMessage: LocalizedStringKey? {
        switch self {
        case .mismatching:
            return "register.validation.password.mismatch"
        default:
            return nil
        }
    }
}
