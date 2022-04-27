//
//  PostLocation.swift
//  OnTheMap
//
//  Created by Ashrakat Sherif on 22/04/2022.
//

import Foundation

struct PostLocation: Codable {
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
}
