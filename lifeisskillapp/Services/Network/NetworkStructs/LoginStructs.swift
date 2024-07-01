//
//  LoginStructs.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//
import Foundation

struct LoginRequest: Encodable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let data: LoginResponseData
}

struct LoginResponseData: Codable {
    let accessToken: String // corresponds to API key
}

extension LoginResponse {
    static let mockReponse = LoginResponse(data: LoginResponseData(accessToken: LoginViewModel.Constants.myAPIKey))
}

