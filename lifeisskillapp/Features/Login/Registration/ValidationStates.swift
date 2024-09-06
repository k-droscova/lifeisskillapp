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
            "register.validation.empty"
        default:
            nil
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
            "register.validation.username.taken"
        case .short:
            LocalizedStringKey(String(format: NSLocalizedString("register.validation.username.short", comment: ""), String(Username.minLength)))
        default:
            nil
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
            "register.validation.email.format"
        case .alreadyTaken:
            "register.validation.email.taken"
        default:
            nil
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
            LocalizedStringKey(String(format: NSLocalizedString("register.validation.password.format", comment: ""), String(Password.minLenght)))
        default:
            nil
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
            "register.validation.password.mismatch"
        default:
            nil
        }
    }
}

enum PhoneNumberValidationState: BaseValidationState {
    case initial
    case valid
    case empty
    case invalidFormat
    
    var validationMessage: LocalizedStringKey? {
        switch self {
        case .invalidFormat:
            "register.validation.phone.invalidFormat"
        default:
            nil
        }
    }
}

enum DateValidationState: BaseValidationState {
    case initial
    case valid
    case empty
    case inFuture
    
    var validationMessage: LocalizedStringKey? {
        switch self {
        case .inFuture:
            "register.validation.date.inFuture"
        default:
            nil
        }
    }
}

// For fields that do not have more requirements other than they shouldn't be empty
enum BasicValidationState: BaseValidationState {
    case initial
    case valid
    case empty
    
    var validationMessage: LocalizedStringKey? {
        switch self {
        case .empty:
            "register.validation.empty"
        default:
            nil
        }
    }
}
