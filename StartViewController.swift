//
//  StartViewController.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 03.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//

import UIKit
import CoreData

class StartViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var clientNameEntryTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    var fechedResultsController:NSFetchedResultsController = NSFetchedResultsController()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        fechedResultsController = getFetchedResultsController()
        fechedResultsController.delegate = self
        fechedResultsController.performFetch(nil)
//        tableView.backgroundColor = UIColor.lightTextColor()

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
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("myCell") as UITableViewCell
        let theQuestion:QModel = fechedResultsController.objectAtIndexPath(indexPath) as QModel
        
        cell.textLabel?.text = theQuestion.question
        cell.layer.cornerRadius = 10.0
        
        if theQuestion.isDefault == false {
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.backgroundColor = UIColor(red: CGFloat(0.98), green: CGFloat(0.98), blue: CGFloat(0.90), alpha: CGFloat(1.0))
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell.backgroundColor = UIColor(red: CGFloat(0.80), green: CGFloat(0.95), blue: CGFloat(0.80), alpha: CGFloat(1.0))
            
        }

        
        return cell
    }
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView.cellForRowAtIndexPath(indexPath)?.accessoryType == UITableViewCellAccessoryType.Checkmark {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
            tableView.cellForRowAtIndexPath(indexPath)?.backgroundColor = UIColor(red: CGFloat(0.98), green: CGFloat(0.98), blue: CGFloat(0.90), alpha: CGFloat(1.0))
        }
        else {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
            tableView.cellForRowAtIndexPath(indexPath)?.backgroundColor = UIColor(red: CGFloat(0.80), green: CGFloat(0.95), blue: CGFloat(0.80), alpha: CGFloat(0.95))
            
        }
        clientNameEntryTextField.resignFirstResponder()
    }

    
    // Helper
    
    func taskFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "QModel")
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        //        let completedDescriptor = NSSortDescriptor(key: "completed", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
        
    }
    
    func getFetchedResultsController() -> NSFetchedResultsController {
        
        fechedResultsController = NSFetchedResultsController(fetchRequest: taskFetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fechedResultsController
    }
    
    
}
