//
//  GetUserDataResponse.swift
//  OnTheMap
//
//  Created by Ashrakat Sherif on 22/04/2022.
//

import Foundation

struct GetUserDataResponse: Codable {
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
