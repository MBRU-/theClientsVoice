//
//  UserAdminViewController.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 11.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//
import UIKit
import CoreData

class UserAdminViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var userNameEntryField: UITextField!
    @IBOutlet weak var passwordEntryField: UITextField!
    @IBOutlet weak var verifyPasswordEntryField: UITextField!
    @IBOutlet weak var isAdminUserControl: UISegmentedControl!
    @IBOutlet weak var updateUserButton: UIButton!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    var fechedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameEntryField.backgroundColor = UIColor(red: CGFloat(0.95), green: CGFloat(0.95), blue: CGFloat(0.95), alpha: CGFloat(0.95))
        passwordEntryField.backgroundColor = UIColor(red: CGFloat(0.95), green: CGFloat(0.95), blue: CGFloat(0.95), alpha: CGFloat(0.95))
        verifyPasswordEntryField.backgroundColor = UIColor(red: CGFloat(0.95), green: CGFloat(0.95), blue: CGFloat(0.95), alpha: CGFloat(0.95))
        
        fechedResultsController = getFetchedResultsController()
        fechedResultsController.delegate = self
        fechedResultsController.performFetch(nil)
        tableView.backgroundColor = UIColor.lightTextColor()
        isAdminUserControl.selectedSegmentIndex = 1
        updateUserButton.hidden = true
        
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
        if theUser.userName.uppercaseString == "ADMIN" {
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
        //        clientNameEntryTextField.resignFirstResponder()
        updateUserButton.hidden = false
        hideKeyboard()
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
            if theUser.userName.uppercaseString != "ADMIN" {
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
                
            updateUserButton.hidden = true
        }


        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
    }
    
    @IBAction func addUserButtonPressed(sender: UIBarButtonItem) {
        
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
                var request = NSFetchRequest(entityName: "UserModel")
                
                var error:NSError? = nil
                var result: NSArray = managedObjectContext!.executeFetchRequest(request, error: &error)!
                
                if let err = error {
                    println("error: \(error)")
                }
                else {
                    println("no error")
                }
                
                userNameEntryField.text = ""
                passwordEntryField.text = ""
                verifyPasswordEntryField.text = ""
                isAdminUserControl.selectedSegmentIndex = 1
                updateUserButton.hidden = true
                hideKeyboard()
            }
        }
        else {
           Alert.showAlertWithText(viewController: self, header: "Warning", message: "User Name or Password can not be left blank")
        }
    }
    
    @IBAction func updateRecordButtonPredded(sender: UIButton) {
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
                updateUserButton.hidden = true
                hideKeyboard()
            }
        }
        else {
            Alert.showAlertWithText(viewController: self, header: "Warning", message: "User Name or Password can not be left blank")
        }
        
    }
    
    @IBAction func clearEntryFieldsButtonPressed(sender: UIButton) {
        userNameEntryField.text = ""
        userNameEntryField.enabled = true

        passwordEntryField.text = ""
        verifyPasswordEntryField.text = ""
        isAdminUserControl.selectedSegmentIndex = 1
        updateUserButton.hidden = true
        tableView.selectRowAtIndexPath( nil  , animated: true, scrollPosition: UITableViewScrollPosition.None)

    }
    
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
// Helper
    
    func taskFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "UserModel")
        let sortDescriptor = NSSortDescriptor(key: "userName", ascending: true)
//        let completedDescriptor = NSSortDescriptor(key: "completed", ascending: true)
        
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
