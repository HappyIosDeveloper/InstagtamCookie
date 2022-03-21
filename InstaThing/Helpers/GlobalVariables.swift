//
//  GlobalVariables.swift
//  InstaThing
//
//  Created by Ahmadreza on 3/14/22.
//

import UIKit

let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.3 Safari/605.1.15"
var cookie: String = UserDefaults.standard.string(forKey: "cookie") ?? "" {
    didSet {
        UserDefaults.standard.set(cookie, forKey: "cookie")
    }
}
var usernames: [String] = UserDefaults.standard.array(forKey: "usernames") as? [String] ?? [] {
    didSet {
        UserDefaults.standard.set(usernames, forKey: "usernames")
    }
}
var localAccounts: [Account] {
    get {
        var accounts: [Account] = []
        for name in usernames {
            do {
                if let data = UserDefaults.standard.data(forKey: name) {
                let account = try JSONDecoder().decode(Account.self, from: data)
                    accounts.append(account)
                } else {
                    print("there is no", name)
                }
            } catch {
                print("falied to get", name)
            }
        }
        return accounts
    }
}
enum StrigKeys: String {
    
    case block
    case unknown
    case challenge
    
    func getNotificationName()-> Notification.Name {
        return Notification.Name(rawValue)
    }
}
