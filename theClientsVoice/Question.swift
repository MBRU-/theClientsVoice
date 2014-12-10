//
//  Question.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 09.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//

import Foundation

let kQuestionsKey = "questionsKey"
let kDefaultQuestionKey = "defaultQuestionKey"


struct QuestionMask {
    var question = ""
    var isDefault = false
    var isSelected = false
}


class Question {
    
    
    func addQuestion (question: NSString, isDefault: Bool) -> Bool {
        var storedQuestionDict = NSMutableDictionary()
        var storedDefaultQuestionDict = NSMutableDictionary()
        

        if question.length == 0 {
            return false
        }
        else if question.hasPrefix(" "){
            return false
        }
        else {
            
            var numberOfQestions = 0
            
            if let q = NSUserDefaults.standardUserDefaults().dictionaryForKey(kQuestionsKey) {
                storedQuestionDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kQuestionsKey) )!)
                storedDefaultQuestionDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kDefaultQuestionKey) )!)
                
                numberOfQestions = storedQuestionDict.count
                storedQuestionDict.setObject(question, forKey: "Q\(numberOfQestions)")
                storedDefaultQuestionDict.setObject(isDefault, forKey: "Q\(numberOfQestions)")
                
            }
            else {
                numberOfQestions = storedQuestionDict.count
                storedQuestionDict.setValue(question, forKey: "Q\(numberOfQestions)")
                storedDefaultQuestionDict.setValue(isDefault, forKey: "Q\(numberOfQestions)")
            }
            
            NSUserDefaults.standardUserDefaults().setObject(storedQuestionDict, forKey: kQuestionsKey)
            NSUserDefaults.standardUserDefaults().setObject(storedDefaultQuestionDict, forKey: kDefaultQuestionKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            return true
            
        }
    }
    
    func getQuestionList() -> [QuestionMask]? {

        var questions:[QuestionMask] = []
        var storedQuestionDict = NSMutableDictionary()
        var storedDefaultQuestionDict = NSMutableDictionary()

        
        if let q = NSUserDefaults.standardUserDefaults().dictionaryForKey(kQuestionsKey) {
            storedQuestionDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kQuestionsKey) )!)
            storedDefaultQuestionDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kDefaultQuestionKey) )!)
            
            var quest:QuestionMask = QuestionMask()
            
            for var i = 0; i < storedQuestionDict.count; i++ {
          println("Getting list count: \(i) \(storedQuestionDict.count)")
                if let ret = storedQuestionDict.objectForKey("Q\(i)") as? String {
                    quest.question = ret
                }
                else {
                    quest.question = "No Value Found"
                }

                if let ret = storedDefaultQuestionDict.objectForKey("Q\(i)") as? Bool {
                  quest.isDefault = ret
                }
                else {
                  quest.isDefault = false
                }

                questions.append(quest)
                
            }
            return questions
        }
        return nil
    }
    
    func deleteQuestionAtIndex (index: Int) -> Bool {
        var storedQuestionDict = NSMutableDictionary()
        var storedDefaultQuestionDict = NSMutableDictionary()

        println("Deleting index:\(index)")
        
        if let q = NSUserDefaults.standardUserDefaults().dictionaryForKey(kQuestionsKey) {
            storedQuestionDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kQuestionsKey) )!)
            storedDefaultQuestionDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kDefaultQuestionKey) )!)
            if storedQuestionDict.objectForKey("Q\(index)") != nil {
                storedQuestionDict.removeObjectForKey("Q\(index)")
                        println("Deleted Question index:\(index)")
            }
            if storedDefaultQuestionDict.objectForKey("Q\(index)") != nil {
                storedDefaultQuestionDict.removeObjectForKey("Q\(index)")
                        println("Deleted Defaults index:\(index)")
            }
            NSUserDefaults.standardUserDefaults().setObject(reOrderDictionary(storedQuestionDict), forKey: kQuestionsKey)
            NSUserDefaults.standardUserDefaults().setObject(reOrderDictionary(storedDefaultQuestionDict), forKey: kDefaultQuestionKey)
//            NSUserDefaults.standardUserDefaults().setObject(storedQuestionDict, forKey: kQuestionsKey)
//            NSUserDefaults.standardUserDefaults().setObject(storedDefaultQuestionDict, forKey: kDefaultQuestionKey)

            
            NSUserDefaults.standardUserDefaults().synchronize()
            return true
        }
        else {
            return false
        }
        
    }
    
    func updateQuestionAtIndex( index: Int, value: String, isDefault: Bool) {
        var storedQuestionDict = NSMutableDictionary()
        var storedDefaultQuestionDict = NSMutableDictionary()

        
        if let q = NSUserDefaults.standardUserDefaults().dictionaryForKey(kQuestionsKey) {
            storedQuestionDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kQuestionsKey) )!)
            storedDefaultQuestionDict.setDictionary((NSUserDefaults.standardUserDefaults().dictionaryForKey(kDefaultQuestionKey) )!)
            if storedQuestionDict.objectForKey("Q\(index)") != nil {
                storedQuestionDict.setValue(value, forKey: "Q\(index)")
            }
            if storedDefaultQuestionDict.objectForKey("Q\(index)") != nil {
                storedDefaultQuestionDict.setValue(isDefault, forKey: "Q\(index)")
            }
            NSUserDefaults.standardUserDefaults().setObject(storedQuestionDict, forKey: kQuestionsKey)
            NSUserDefaults.standardUserDefaults().setObject(storedDefaultQuestionDict, forKey: kDefaultQuestionKey)
            
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
        
    }
    
    //Helper functions
    private func reOrderDictionary (sourceDict: NSMutableDictionary) -> NSMutableDictionary {

        var tempDict = NSMutableDictionary()
        var i = 0
        var cnt = sourceDict.count
        var count = 0
        var str: String?
        
        while i <= cnt
        {
            str = sourceDict.objectForKey("Q\(i )") as? String
            if str != nil {
                tempDict.setObject(sourceDict.objectForKey("Q\(i )")!, forKey: "Q\(i)" )
                println("Adding Q\(i)")
            }
            else {
                for var n=i; n <= cnt; n++ {
                    str = sourceDict.objectForKey("Q\(n)") as? String
                    if str  != nil {
                        tempDict.setObject(sourceDict.objectForKey("Q\(n)")!, forKey: "Q\(i )")
                        sourceDict.removeObjectForKey("Q\(n)")
                        println("Found new number Q\(i  ) for Q\(n )")
                        break
                    }
                    
                }
                
            }
            i++
            
        }
        i++
        
        return tempDict
    }
    
}

