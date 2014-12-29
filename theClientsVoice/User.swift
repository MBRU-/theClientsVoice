//
//  User.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 14.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//

import Foundation

struct UserCredential {
    var userName = " noUser"
    var password: String = " nil"
    var isAdmin: Bool = false
    var isLogedin: Bool = false
}

private var userCredentials: UserCredential = UserCredential()


class User {


    //Class Methods
    class func credentials() -> UserCredential {
        return userCredentials
    }
    
    class func isAdmin () -> Bool {
        return userCredentials.isAdmin
    }
    
    class func verifyPassword (password: NSString) -> Bool {
        if userCredentials.password.uppercaseString == password.uppercaseString {
            return true
        }
        else {
            return false
        }
    }
    
    class func isLogedin() -> Bool {
        return userCredentials.isLogedin
    }
    
    func logIn(#userName: String, password: String, isAdmin: Bool, isLogedIn: Bool) {
        userCredentials.userName = userName
        userCredentials.password = password
        userCredentials.isAdmin = isAdmin
        userCredentials.isLogedin = isLogedIn
    }
    
    func logOff() {
        userCredentials.userName = " noUser"
        userCredentials.password = " nil"
        userCredentials.isAdmin = false
        userCredentials.isLogedin = false
    }
    
}
