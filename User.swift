//
//  User.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 09.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//

import Foundation

let kUserCredentialsKey = "userCredentials"
let kUserIsAdminKey = "UserIsAdmin"


struct UserCredential {
    var userName = " noUser"
    var password: NSString = " nil"
    var isAdmin: Bool = false
    var isLogedin: Bool = false
}

private var userCredentials: UserCredential = UserCredential()


class User {
    
    private var storedUserDict = NSMutableDictionary()
    private var storedIsAdminDict = NSMutableDictionary()
    
    
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
    
    
    //Instance Methods
    
    func login (userName: String, password: NSString) -> Bool {
        
        if let q = NSUserDefaults.standardUserDefaults().dictionaryForKey(kUserCredentialsKey) {
            storedUserDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kUserCredentialsKey) )!)
            storedIsAdminDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kUserIsAdminKey) )!)
            
            if storedUserDict.objectForKey(userName) != nil {
                if storedUserDict.objectForKey(userName)?.uppercaseString == password.uppercaseString {
                    userCredentials.userName = userName
                    userCredentials.password = password.uppercaseString
                    userCredentials.isLogedin = true
                    if storedIsAdminDict.objectForKey(userName) != nil {
                        userCredentials.isAdmin = storedIsAdminDict.objectForKey(userName) as Bool
                        
                    }
                    else {
                        userCredentials.isAdmin = false
                    }
                    return true
                }
                else {
                    return false
                }
            }
            
        }
        return false
    }
    
    func logout() {
        userCredentials.userName = " noUser"
        userCredentials.password = " nil"
        userCredentials.isAdmin = false
        userCredentials.isLogedin = false
    }
    
    func addAccount (newName: NSString, password: NSString, isAdmin: Bool) -> Bool {
        
        if newName.length == 0 || password.length == 0 {
            return false
        }
        else if newName.hasPrefix(" ") || password.hasPrefix(" "){
            return false
        }
        else {
            if let q = NSUserDefaults.standardUserDefaults().dictionaryForKey(kUserCredentialsKey) {
                storedUserDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kUserCredentialsKey) )!)
                storedIsAdminDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kUserIsAdminKey) )!)
                
                if storedUserDict.objectForKey(newName) == nil {
                    
                    storedUserDict.setObject(password.uppercaseString, forKey: newName)
                    storedIsAdminDict.setObject(isAdmin, forKey: newName)
                }
                else {
                    return false //User already exists
                }
            }
            else {
                storedUserDict.setObject(password.uppercaseString, forKey: newName)           }
            storedIsAdminDict.setObject(isAdmin, forKey: newName)
            
            NSUserDefaults.standardUserDefaults().setObject(storedUserDict, forKey: kUserCredentialsKey)
            NSUserDefaults.standardUserDefaults().setObject(storedIsAdminDict, forKey: kUserIsAdminKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            return true
            
        }
    }
    
    
    func deleteAccount( name: String) {
        if let q = NSUserDefaults.standardUserDefaults().dictionaryForKey(kUserCredentialsKey) {
            storedUserDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kUserCredentialsKey) )!)
            storedIsAdminDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kUserIsAdminKey) )!)
            if storedUserDict.objectForKey(name) != nil {
                storedUserDict.removeObjectForKey(name)
            }
            if storedIsAdminDict.objectForKey(name) != nil {
                storedIsAdminDict.removeObjectForKey(name)
            }
            
            NSUserDefaults.standardUserDefaults().setObject(storedUserDict, forKey: kUserCredentialsKey)
            NSUserDefaults.standardUserDefaults().setObject(storedIsAdminDict, forKey: kUserIsAdminKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
    }
    
    func changePasswordForUser(name: NSString, password: NSString) -> Bool {
        
        if let q = NSUserDefaults.standardUserDefaults().dictionaryForKey(kUserCredentialsKey) {
            storedUserDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kUserCredentialsKey) )!)
            
            if storedUserDict.objectForKey(name) != nil {
                storedUserDict.setValue(password.uppercaseString, forKey: name)
                NSUserDefaults.standardUserDefaults().setObject(storedUserDict, forKey: kUserCredentialsKey)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                return true
            }
            else {
                return false
            }
            
        }
        return false
    }
    
    func changeAdminForUser(name: NSString, isAdmin: Bool) -> Bool {
        
        if let q = NSUserDefaults.standardUserDefaults().dictionaryForKey(kUserCredentialsKey) {
            storedUserDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kUserCredentialsKey) )!)
            storedIsAdminDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kUserIsAdminKey) )!)
            
            if storedUserDict.objectForKey(name) != nil {
                if storedIsAdminDict.objectForKey(name) != nil {
                    storedIsAdminDict.setValue(isAdmin, forKey: name)
                    NSUserDefaults.standardUserDefaults().setObject(storedIsAdminDict, forKey: kUserIsAdminKey)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    println("isAdmin changed")
                    return true
                }
                else {
                    return false
                }
            }
            else {
                return false
            }
            
        }
        return false
    }
    
}
