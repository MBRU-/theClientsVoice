//
//  UserAdminViewController.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 11.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//
import UIKit
import CoreData

class UserAdminViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate  {
    let kAdd = "Add"
    let kUpdate = "Update"
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var clientCenterNameTextField: UITextField!
    @IBOutlet weak var userNameEntryField: UITextField!
    @IBOutlet weak var passwordEntryField: UITextField!
    @IBOutlet weak var verifyPasswordEntryField: UITextField!
    @IBOutlet weak var isAdminUserControl: UISegmentedControl!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var centerAdminEmailEntryField: UITextField!
    @IBOutlet weak var centerAdminEmailSendYesNo: UISegmentedControl!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    var fechedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let txt = NSUserDefaults.standardUserDefaults().objectForKey(kClientCenterTitelKey) as? String {
            clientCenterNameTextField.text = txt
        }
        else {
            clientCenterNameTextField.text = "Client Center"
            
        }
        if let txt = NSUserDefaults.standardUserDefaults().objectForKey(kCenterAdminEmailKey) as? String {
            centerAdminEmailEntryField.text = txt
        }
        else {
            centerAdminEmailEntryField.text = "no valid email"
        }
        centerAdminEmailSendYesNo.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().boolForKey(kCenterAdminEmailYesNo) ? 0 : 1
        
        userNameEntryField.backgroundColor = UIColor(red: CGFloat(0.95), green: CGFloat(0.95), blue: CGFloat(0.95), alpha: CGFloat(0.95))
        passwordEntryField.backgroundColor = UIColor(red: CGFloat(0.95), green: CGFloat(0.95), blue: CGFloat(0.95), alpha: CGFloat(0.95))
        verifyPasswordEntryField.backgroundColor = UIColor(red: CGFloat(0.95), green: CGFloat(0.95), blue: CGFloat(0.95), alpha: CGFloat(0.95))
        
        fechedResultsController = getFetchedResultsController()
        fechedResultsController.delegate = self
        fechedResultsController.performFetch(nil)
        tableView.backgroundColor = UIColor.lightTextColor()
        isAdminUserControl.selectedSegmentIndex = 1
        addButton.enabled = true
        appVersionLabel.text = kAppVersion
        clientCenterNameTextField.delegate = self
        userNameEntryField.delegate = self
        passwordEntryField.delegate = self
        verifyPasswordEntryField.delegate = self
        centerAdminEmailEntryField.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fechedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fechedResultsController.sections![section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("myUserCell") as UITableViewCell
        let theUser = fechedResultsController.objectAtIndexPath(indexPath) as UserModel
        
        cell.textLabel?.text = theUser.userName
        cell.backgroundColor = UIColor(red: CGFloat(0.95), green: CGFloat(0.95), blue: CGFloat(0.95), alpha: CGFloat(0.95))
        cell.layer.cornerRadius = 10.0
        
        return cell
        
    }
    
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var theUser = fechedResultsController.objectAtIndexPath(indexPath) as UserModel
        if theUser.userName.uppercaseString == "ADMIN" {    //we don't want to change the ADMIN credentials
            userNameEntryField.enabled = false
            isAdminUserControl.enabled = false
        }
        else {
            userNameEntryField.enabled = true
            isAdminUserControl.enabled = true
            
        }
        
        userNameEntryField.text = theUser.userName
        passwordEntryField.text = theUser.password
        if theUser.isAdmin.boolValue == true {
            isAdminUserControl.selectedSegmentIndex = 0
        }
        else {
            isAdminUserControl.selectedSegmentIndex = 1
        }
        
        addButton.title = kUpdate
        hideKeyboard()
    }
    
    //Mark - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //NSFechedResultsControllerDelegate
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        
        return "Delete?"
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let theUser = fechedResultsController.objectAtIndexPath(indexPath) as UserModel
            if theUser.userName.uppercaseString != "ADMIN" {        //ADMIN can not be deleted
                let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
                let managedObjectContext = appDelegate.managedObjectContext
                let entityDescription = NSEntityDescription.entityForName("UserModel", inManagedObjectContext: managedObjectContext!)
                let objectToDelete = fechedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
                managedObjectContext?.deleteObject(objectToDelete)
                println("deleted")
            }
            else {
                tableView.reloadData()
            }
            
            addButton.title = kAdd
        }
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
    }
    
    func addRecord() {
        if !userNameEntryField.text.isEmpty && !passwordEntryField.text.isEmpty {
            if passwordCheck() == true {
                let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
                let managedObjectContext = appDelegate.managedObjectContext
                let entityDescription = NSEntityDescription.entityForName("UserModel", inManagedObjectContext: managedObjectContext!)
                
                let theUser = UserModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
                theUser.userName = userNameEntryField.text
                theUser.password =  passwordEntryField.text
                theUser.isLogedin = NSNumber(bool: false)
                if isAdminUserControl.selectedSegmentIndex == 0 {
                    theUser.isAdmin = NSNumber(bool: true)
                }
                else {
                    theUser.isAdmin = NSNumber(bool: false)
                }
                
                appDelegate.saveContext()
                userNameEntryField.text = ""
                passwordEntryField.text = ""
                verifyPasswordEntryField.text = ""
                isAdminUserControl.selectedSegmentIndex = 1
                addButton.title = kAdd
                hideKeyboard()
            }
        }
        else {
            Alert.showAlertWithText(viewController: self, header: "Warning", message: "User Name and/or Password can not be left blank")
        }
    }
    
    
    func updateRecord() {
        if !userNameEntryField.text.isEmpty && !passwordEntryField.text.isEmpty {
            if passwordCheck() == true {
                let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
                let indexPath = self.tableView.indexPathForSelectedRow()
                let theUser = fechedResultsController.objectAtIndexPath(indexPath!) as UserModel
                theUser.userName = userNameEntryField.text
                theUser.password =  passwordEntryField.text
                if isAdminUserControl.selectedSegmentIndex == 0 {
                    theUser.isAdmin = NSNumber(bool: true)
                }
                else {
                    theUser.isAdmin = NSNumber(bool: false)
                }
                
                appDelegate.saveContext()
                userNameEntryField.text = ""
                passwordEntryField.text = ""
                verifyPasswordEntryField.text = ""
                isAdminUserControl.selectedSegmentIndex = 1
                addButton.title = kAdd
                hideKeyboard()
            }
        }
        else {
            Alert.showAlertWithText(viewController: self, header: "Warning", message: "User Name or Password can not be left blank")
        }
        
    }
    
    
    @IBAction func addUserButtonPressed(sender: UIBarButtonItem) {
        if sender.title == kAdd {
            addRecord()
        }
        else if sender.title == kUpdate {
            updateRecord()
            
        }
    }
    
    @IBAction func clearEntryFieldsButtonPressed(sender: UIButton) {
        userNameEntryField.text = ""
        userNameEntryField.enabled = true
        isAdminUserControl.enabled = true
        passwordEntryField.text = ""
        verifyPasswordEntryField.text = ""
        isAdminUserControl.selectedSegmentIndex = 1
        addButton.title = kAdd
        tableView.selectRowAtIndexPath( nil  , animated: true, scrollPosition: UITableViewScrollPosition.None)
        
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        if centerAdminEmailSendYesNo.selectedSegmentIndex == 0 {
            NSUserDefaults.standardUserDefaults().setBool( true , forKey: kCenterAdminEmailYesNo)
        }
        else {
            NSUserDefaults.standardUserDefaults().setBool( false , forKey: kCenterAdminEmailYesNo)
        }
        
        NSUserDefaults.standardUserDefaults().setObject(clientCenterNameTextField.text, forKey: kClientCenterTitelKey)
        NSUserDefaults.standardUserDefaults().setObject(centerAdminEmailEntryField.text, forKey: kCenterAdminEmailKey)
        //User Initialization complete
        println("DONE called")
        
        NSUserDefaults.standardUserDefaults().setBool( true , forKey: kLoadedOnceKey)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Helper
    
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
        if verifyPasswordEntryField.text.uppercaseString == passwordEntryField.text.uppercaseString || passwordEntryField.text.isEmpty {
            return true
        }
        else {
            Alert.showAlertWithText(viewController: self, header: "Warning", message: "Password not identical, please try again.")
            return false
        }
    }
    
    
    func hideKeyboard() {
        
        userNameEntryField.resignFirstResponder()
        passwordEntryField.resignFirstResponder()
        verifyPasswordEntryField.resignFirstResponder()
        
    }
    
}
