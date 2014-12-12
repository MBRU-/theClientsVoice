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
    
    
    
    @IBOutlet weak var questionTextField: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var isDefaultQuestionControl: UISegmentedControl!
    @IBOutlet weak var sortOrderControl: UISegmentedControl!
    
    @IBOutlet weak var updateQuestionButton: UIButton!
    
    
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
        sortOrderControl.selectedSegmentIndex = UISegmentedControlNoSegment
        sortOrderControl.momentary = true

        
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
        
        cell.textLabel?.text = theQuestion.question
        cell.backgroundColor = UIColor(red: CGFloat(0.95), green: CGFloat(0.95), blue: CGFloat(0.95), alpha: CGFloat(0.95))
        cell.layer.cornerRadius = 10.0
        
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
        //        clientNameEntryTextField.resignFirstResponder()
        
        updateQuestionButton.hidden = false
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
            println("deleted")
            updateQuestionButton.hidden = true
        }
        
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
    }
    
    @IBAction func addQuestionButtonPressed(sender: UIBarButtonItem) {
        
        if !questionTextField.text.isEmpty {
            let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
            let managedObjectContext = appDelegate.managedObjectContext
            let entityDescription = NSEntityDescription.entityForName("QModel", inManagedObjectContext: managedObjectContext!)

            let theQuestion = QModel(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
            
            println("run until here")
            
            theQuestion.question = questionTextField.text
            theQuestion.isDefault = false
            theQuestion.index = fechedResultsController.sections![0].numberOfObjects
            if isDefaultQuestionControl.selectedSegmentIndex == 0 {
                theQuestion.isDefault = true
            }
            else {
                theQuestion.isDefault = false
            }
            
            appDelegate.saveContext()
            
            questionTextField.text = ""
            isDefaultQuestionControl.selectedSegmentIndex = 1
            updateQuestionButton.hidden = true
            
        }
        else {
            Alert.showAlertWithText(viewController: self, header: "Warning", message: "Question field can not be empty")
        }
    }

    
    @IBAction func updateQuestionRecordButtonPressed(sender: UIButton) {
        
        if !questionTextField.text.isEmpty {
            let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
            let indexPath = self.tableView.indexPathForSelectedRow()
            let theQuestion: QModel = fechedResultsController.objectAtIndexPath(indexPath!) as QModel
            theQuestion.question = questionTextField.text
            if isDefaultQuestionControl.selectedSegmentIndex == 0 {
                theQuestion.isDefault = true
            }
            else {
                theQuestion.isDefault = false
            }
            
            appDelegate.saveContext()
            questionTextField.text = ""
            isDefaultQuestionControl.selectedSegmentIndex = 1
            updateQuestionButton.hidden = true
            
        }
        else {
            Alert.showAlertWithText(viewController: self, header: "Warning", message: "Question field can not be empty")
        }
        
    }
    
    
    @IBAction func clearQuestionFieldsButtonPressed(sender: UIButton) {
        
        questionTextField.text = ""
        isDefaultQuestionControl.selectedSegmentIndex = 1
        updateQuestionButton.hidden = true
        tableView.selectRowAtIndexPath( nil  , animated: true, scrollPosition: UITableViewScrollPosition.None)
    }
    
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Helper
    
    func taskFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "QModel")
        let sortDescriptor = NSSortDescriptor(key: "question", ascending: true)
        //        let completedDescriptor = NSSortDescriptor(key: "completed", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
        
    }
    
    func getFetchedResultsController() -> NSFetchedResultsController {
        
        fechedResultsController = NSFetchedResultsController(fetchRequest: taskFetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fechedResultsController
    }
    
    
    @IBAction func sortOrderControlTapped(sender: UISegmentedControl) {
        
    }
    
    
}
