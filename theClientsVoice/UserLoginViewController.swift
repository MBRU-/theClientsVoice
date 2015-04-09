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
    @IBOutlet weak var userAutoLoginSegControl: UISegmentedControl!
    
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
        userAutoLoginSegControl.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().boolForKey(kAutoLoginKey) ? 0 : 1
        
        fechedResultsController = getFetchedResultsController()
        fechedResultsController.delegate = self
        fechedResultsController.performFetch(nil)
        
        self.view.backgroundColor = UIColor(red: CGFloat(0.90), green: CGFloat(0.93), blue: CGFloat(0.95), alpha: CGFloat(0.95))
        
        //Mark: for the first time the app is started, a transfer to UserAdminControler is performed
        if (NSUserDefaults.standardUserDefaults().boolForKey(kLoadedOnceKey) == false) && passwordCheck(autoLogon: false){
            performSegueWithIdentifier("initUserSegue", sender: self)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if NSUserDefaults.standardUserDefaults().boolForKey(kAutoLoginKey) == true {
            passwordCheck(autoLogon: true)
            performSegueWithIdentifier("loginToStartSegue1", sender: self)
        }
        else {
            fechedResultsController.performFetch(nil)
            tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        //Remember Auto Login decision
        if userAutoLoginSegControl.selectedSegmentIndex == 0 {
            NSUserDefaults.standardUserDefaults().setBool( true , forKey: kAutoLoginKey)
        }
        else {
            NSUserDefaults.standardUserDefaults().setBool( false , forKey: kAutoLoginKey)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Segue control
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "loginToStartSegue" || identifier == "loginToStartSegue1" {
            //perform segue to startViewController if password check is successful
            return passwordCheck(autoLogon: false)
            
        }else {
            return false
        }
    }
    
    //Mark - UITextFieldDelegate - activate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == passwordEntryField && passwordCheck(autoLogon: false) {
            passwordEntryField.resignFirstResponder()
            performSegueWithIdentifier("loginToStartSegue1", sender: nil)
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
    
    func passwordCheck (#autoLogon: Bool) -> Bool {
        
        //Mark: If the app is started for the first time, we will siently login as Admin user and transfer to UserAdmin to create user and defince Center Name, etc.
        if NSUserDefaults.standardUserDefaults().boolForKey(kLoadedOnceKey) == false {
            theUser.logIn(userName: "Admin", password: "Admin", isAdmin: true, isLogedIn: true)
            return true
        }
        
        if autoLogon == true {
            let uName =  NSUserDefaults.standardUserDefaults().objectForKey(kAutoUserNameKey) as String
            let uPassword = NSUserDefaults.standardUserDefaults().objectForKey(kAutoPasswordKey) as String
            let uIsAdmin = NSUserDefaults.standardUserDefaults().boolForKey(kAutoIsAdminKey) as Bool
            theUser.logIn(userName: uName, password: uPassword, isAdmin: uIsAdmin, isLogedIn: true)
            return true
        }
        else if storedPassword.uppercaseString == passwordEntryField.text.uppercaseString && !passwordEntryField.text.isEmpty{
            theUser.logIn(userName: userNameEntryField.text, password: storedPassword, isAdmin: storedIsAdmin, isLogedIn: true)
            NSUserDefaults.standardUserDefaults().setObject(userNameEntryField.text, forKey: kAutoUserNameKey)
            NSUserDefaults.standardUserDefaults().setObject(storedPassword, forKey: kAutoPasswordKey)
            NSUserDefaults.standardUserDefaults().setBool(storedIsAdmin, forKey: kAutoIsAdminKey)
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
