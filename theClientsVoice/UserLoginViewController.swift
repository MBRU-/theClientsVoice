//
//  UserLoginViewController.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 14.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//

import UIKit
import CoreData

class UserLoginViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var userNameEntryField: UITextField!
    @IBOutlet weak var passwordEntryField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    var fechedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    var storedPassword = ""
    var storedIsAdmin = false
    let theUser = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        theUser.logOff()
        userNameEntryField.backgroundColor = UIColor(red: CGFloat(0.95), green: CGFloat(0.95), blue: CGFloat(0.95), alpha: CGFloat(0.95))
        passwordEntryField.backgroundColor = UIColor(red: CGFloat(0.95), green: CGFloat(0.95), blue: CGFloat(0.95), alpha: CGFloat(0.95))
        passwordEntryField.clearButtonMode = UITextFieldViewMode.Always
        passwordEntryField.delegate = self
        
        fechedResultsController = getFetchedResultsController()
        fechedResultsController.delegate = self
        fechedResultsController.performFetch(nil)
        
        self.view.backgroundColor = UIColor(red: CGFloat(0.90), green: CGFloat(0.93), blue: CGFloat(0.95), alpha: CGFloat(0.95))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Segue control
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "loginToStartSegue" || identifier == "loginToStartSegue1" {
            //perform segue to startViewController if password check is successful
            return passwordCheck()
  
        }else {
            return false
        }
    }
    
    //Mark - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == passwordEntryField && passwordCheck() {
            passwordEntryField.resignFirstResponder()
            performSegueWithIdentifier("loginToStartSegue1", sender: nil)
            println("KB should dismiss")
            return true
        }
        else {
            return false
        }
    }
    
    
    //UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return fechedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fechedResultsController.sections![section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("myLoginCell") as UITableViewCell
        let myUser = fechedResultsController.objectAtIndexPath(indexPath) as UserModel
        
        cell.textLabel?.text = myUser.userName
        cell.backgroundColor = UIColor(red: CGFloat(0.95), green: CGFloat(0.95), blue: CGFloat(0.99), alpha: CGFloat(1.0))
        cell.layer.cornerRadius = 10.0
        
        return cell
        
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "User List"
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(40)
    }
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       let myUser = fechedResultsController.objectAtIndexPath(indexPath) as UserModel

        userNameEntryField.text = myUser.userName
        passwordEntryField.text = ""
        passwordEntryField.selected = true
        if myUser.isAdmin.boolValue == false {
            storedIsAdmin = false
        }
        else {
            storedIsAdmin = true
        }
        storedPassword = myUser.password
        hideKeyboard()
    }
    
    // Helpers
    
    func taskFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "UserModel")
        let sortDescriptor = NSSortDescriptor(key: "userName", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    func getFetchedResultsController() -> NSFetchedResultsController {
        fechedResultsController = NSFetchedResultsController(fetchRequest: taskFetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fechedResultsController
    }
    
    func passwordCheck () -> Bool {
        if storedPassword.uppercaseString == passwordEntryField.text.uppercaseString && !passwordEntryField.text.isEmpty{
            theUser.logIn(userName: userNameEntryField.text, password: storedPassword, isAdmin: storedIsAdmin, isLogedIn: true)
            return true
        }
        else {
            Alert.showAlertWithText(viewController: self, header: "Warning", message: "Please enter correct password")
            return false
        }
    }
    
    
    func hideKeyboard() {
        userNameEntryField.resignFirstResponder()
        passwordEntryField.resignFirstResponder()
    }
}
