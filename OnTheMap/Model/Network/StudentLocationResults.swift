//
//  StudentLocationResults.swift
//  OnTheMap
//
//  Created by Ashrakat Sherif on 22/04/2022.
//

import Foundation

struct StudentLocationResults:Codable {
    let results: [StudentLocation]
    
    init(results: [StudentLocation]){
        self.results = results
    }
}
