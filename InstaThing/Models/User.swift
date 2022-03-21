//
//  User.swift
//  InstaThing
//
//  Created by Ahmadreza on 3/13/22.
//

import Foundation

struct UsersRequestData: Codable {
        
    var users: [Account]?
    var has_more: Bool?
}

struct Account: Codable {
    
    var position: Int?
    var user: SubUser?
}

struct SubUser: Codable {
    
    var username: String?
    var full_name: String?
    var profile_pic_url: String?
}
