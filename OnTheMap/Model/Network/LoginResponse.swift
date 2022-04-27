//
//  LoginResponse.swift
//  OnTheMap
//
//  Created by Ashrakat Sherif on 22/04/2022.
//

import Foundation

struct LoginResponse: Codable {
    let account: Account
    let session: Session
}

struct Account:Codable {
    let key:String?
    let registered: Bool
}

struct Session: Codable {
    let id: String?
    let expiration: String?
}

