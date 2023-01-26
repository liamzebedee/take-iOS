//
//  Take.swift
//  take
//
//  Created by Liam Edwards-Playne on 24/1/2023.
//

import Foundation

struct Take: Codable, Identifiable {
    var id: Int?
    var description: String?
    var owner: String?
    var name: String?
    var refs: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case description
        case owner
        case name
        case refs
    }
}
