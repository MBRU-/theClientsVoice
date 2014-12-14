//
//  QuestionAdminViewController.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 12.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//

import UIKit
import CoreData

class QuestionAdminViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, NSFetchedResultsControllerDelegate  {
    
    @IBOutlet weak var addOrUpdateButton: UIBarButtonItem!
    
    @IBOutlet weak var questionTextField: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var isDefaultQuestionControl: UISegmentedControl!

    var swapState = false
    let popUp = PopUp()
    var maxIndex = 0
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    var fechedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        fechedResultsController = getFetchedResultsController()
        fechedResultsController.delegate = self
        fechedResultsController.performFetch(nil)
        tableView.backgroundColor = UIColor.lightTextColor()
        
        questionTextField.backgroundColor = UIColor(red: CGFloat(0.95), green: CGFloat(0.95), blue: CGFloat(0.95), alpha: CGFloat(0.95))
        questionTextField.layer.cornerRadius = 10.0
        isDefaultQuestionControl.selectedSegmentIndex = 1

        addOrUpdateButton.title = "Add"
    }
    
    override func viewDidAppear(animated: Bool) {
        
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
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("myAdminCell") as UITableViewCell
        let theQuestion:QModel = fechedResultsController.objectAtIndexPath(indexPath) as QModel
        
        if maxIndex < theQuestion.index as Int {
            maxIndex = theQuestion.index as Int
        }
        
        cell.textLabel?.text = theQuestion.question
        cell.backgroundColor = UIColor(red: CGFloat(0.95), green: CGFloat(0.95), blue: CGFloat(0.95), alpha: CGFloat(0.95))
        cell.layer.cornerRadius = 10.0
        if theQuestion.isDefault == false {
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.backgroundColor = UIColor(red: CGFloat(0.98), green: CGFloat(0.98), blue: CGFloat(0.90), alpha: CGFloat(1.0))
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell.backgroundColor = UIColor(red: CGFloat(0.80), green: CGFloat(0.95), blue: CGFloat(0.80), alpha: CGFloat(0.95))
            
        }

        
        return cell
        
    }
    
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var theQuestion: QModel = fechedResultsController.objectAtIndexPath(indexPath) as QModel
        questionTextField.text = theQuestion.question
        if theQuestion.isDefault == true {
            isDefaultQuestionControl.selectedSegmentIndex = 0
        }
        else {
            isDefaultQuestionControl.selectedSegmentIndex = 1
        }
        questionTextField.resignFirstResponder()
       
        addOrUpdateButton.title = "Update"
        
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
            let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
            let managedObjectContext = appDelegate.managedObjectContext
            let entityDescription = NSEntityDescription.entityForName("QModel", inManagedObjectContext: managedObjectContext!)
            let objectToDelete = fechedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
            
            managedObjectContext?.deleteObject(objectToDelete)
        }
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
    }
    
    @IBAction func addQuestionButtonPressed(sender: UIBarButtonItem) {
        
        if sender.title == "Add" {
            addRecord()
        }
        else if sender.title == "Update" {
            updateRecord()
            addOrUpdateButton.title = "Add"
        }
        
     }

    
    @IBAction func updateQuestionRecordButtonPressed(sender: UIBarButtonItem) {
        updateRecord()
        
    }
    
    
    @IBAction func clearQuestionFieldsButtonPressed(sender: UIBarButtonItem) {
        
        clearIt()

    }
    
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sortOrderControlTapped(sender: UIBarButtonItem) {
       
        if let indexPath = (tableView.indexPathsForSelectedRows() as? [NSIndexPath]){
        
            if swapState == false {
                tableView.allowsMultipleSelection = true
                swapState = true
                popUp.setupContainerView(self.view)
                popUp.setupContainerContent()
                
            }
            else {
                
                if  indexPath.count > 1 && indexPath.count <= 2  {
                    
                    var temp = 0
                    let theQuestion: QModel = fechedResultsController.objectAtIndexPath(indexPath[0]) as QModel
                    let theQuestion2: QModel = fechedResultsController.objectAtIndexPath(indexPath[1]) as QModel
                    temp = theQuestion2.index as Int
                    theQuestion2.index = theQuestion.index
                    theQuestion.index = temp as Int
                    
                    (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
                    tableView.allowsMultipleSelection = false
                    popUp.removePopUp()
                    swapState = false
                    clearIt()
                }
                else {
                    if indexPath.count > 2 {
                        Alert.showAlertWithText(viewController: self, header: "ooops", message: "Please select only two rows")
                    }
                    else {
                        Alert.showAlertWithText(viewController: self, header: "ooops", message: "you need to select a second Row")
                    }

                }
                
            }
        
        }
        else {
            Alert.showAlertWithText(viewController: self, header: "ooops", message: "Please select a row first")
        }
    
    }
    
    
    
    // Helper
    
    func taskFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "QModel")
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
        
    }
    
    func getFetchedResultsController() -> NSFetchedResultsController {
        
        fechedResultsController = NSFetchedResultsController(fetchRequest: taskFetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fechedResultsController
    }
    
 
    func clearIt() {
        questionTextField.text = ""
        isDefaultQuestionControl.selectedSegmentIndex = 1
        tableView.selectRowAtIndexPath( nil  , animated: true, scrollPosition: UITableViewScrollPosition.None)
        addOrUpdateButton.title = "Add"
        if swapState == true {
            popUp.removePopUp()
            swapState = false
        }

    }

    func addRecord() {
        if !questionTextField.text.isEmpty {
            let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
            let managedObjectContext = appDelegate.managedObjectContext
            let entityDescription = NSEntityDescription.entityForName("QModel", inManagedObjectContext: managedObjectContext!)
            
            let theQuestion = QModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
            tableView.numberOfRowsInSection(0)
            
            maxIndex++
            theQuestion.index = maxIndex as Int
            theQuestion.question = questionTextField.text
            theQuestion.isDefault = false
            if isDefaultQuestionControl.selectedSegmentIndex == 0 {
                theQuestion.isDefault = true
            }
            else {
                theQuestion.isDefault = false
            }
            
            appDelegate.saveContext()
            
            questionTextField.text = ""
            questionTextField.resignFirstResponder()
            isDefaultQuestionControl.selectedSegmentIndex = 1
            
        }
        else {
            Alert.showAlertWithText(viewController: self, header: "Warning", message: "Question field can not be empty")
        }

    }
    
    
    func updateRecord() {
        if !questionTextField.text.isEmpty {
            
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let theQuestion: QModel = fechedResultsController.objectAtIndexPath(indexPath) as QModel
                
                theQuestion.question = questionTextField.text
                if isDefaultQuestionControl.selectedSegmentIndex == 0 {
                    theQuestion.isDefault = true
                }
                else {
                    theQuestion.isDefault = false
                }
                
                (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
                
                questionTextField.text = ""
                questionTextField.resignFirstResponder()
                isDefaultQuestionControl.selectedSegmentIndex = 1
            }
            else {
                println("ooops")
            }
            
        }
        else {
            Alert.showAlertWithText(viewController: self, header: "Warning", message: "Question field can not be empty")
        }

    }
}
