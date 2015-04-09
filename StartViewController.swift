//
//  StartViewController.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 03.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//


import UIKit
import CoreData

class StartViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var clientNameEntryTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var UserAdminBarButton: UIBarButtonItem!
    @IBOutlet weak var QuestionAdminBarButton: UIBarButtonItem!
    @IBOutlet weak var commentsOnSwitch: UISwitch!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    var fechedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentsOnSwitch.setOn(true, animated: true)
        UserAdminBarButton.enabled = User.isAdmin()
        QuestionAdminBarButton.enabled = User.isAdmin()
        fechedResultsController = getFetchedResultsController()
        fechedResultsController.delegate = self
        clientNameEntryTextField.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        fechedResultsController.performFetch(nil)
        tableView.reloadData()
        if let txt = NSUserDefaults.standardUserDefaults().objectForKey(kClientCenterTitelKey) as? String {
            navigationBar.topItem?.title = txt + " CSAT"
        }
        else {
            navigationBar.topItem?.title = "Client Center CSAT"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //called before transition to MainViewController
    //this is the place to set proprties in the destination view controller e.g. clientName
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "startQuestionaireSeque" {
            let detailVC: MainViewController = segue.destinationViewController as MainViewController
            detailVC.questions = getSelectedQuestionsFromTableView()
            detailVC.commentsTurnedOn = commentsOnSwitch.on
            if clientNameEntryTextField.text.isEmpty {
                detailVC.clientName = "Unknown Client Name"
            }
            else {
                detailVC.clientName = clientNameEntryTextField.text
            }
        }
    }
    
    // Segue control
    // before we start to segue to mainVievController we need to have at least one question selected
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "startQuestionaireSeque" {
            if getSelectedQuestionsFromTableView().count == 0 {
                Alert.showAlertWithText(viewController: self, header: "Alert", message: "Please select at least one question.")
                return false
            }
            else {
                return true
            }
        }
        else if identifier == "logoutUserSegue" { //calling UserLoginViewController
            
            println("Calling logoutUserSegue")
            
            //Disable AutoLogin feature
            NSUserDefaults.standardUserDefaults().setBool( false , forKey: kAutoLoginKey)
            return true
        }
        return true
    }
    
    
    //Mark - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == clientNameEntryTextField  {
            clientNameEntryTextField.resignFirstResponder()
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
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("myCell") as UITableViewCell
        let theQuestion:QModel = fechedResultsController.objectAtIndexPath(indexPath) as QModel
        
        cell.textLabel?.text = theQuestion.question
        cell.layer.cornerRadius = 10.0
        
        if theQuestion.isDefault.boolValue == false {
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
    
    //Custom Button Action
    
    @IBAction func defaultNavBarItemButtonPressed(sender: UIBarButtonItem) {
        tableView.reloadData()
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
    
    //remark: this only works as long as all selected questions are visible in the view
    func getSelectedQuestionsFromTableView() -> [String] {
        let cells = tableView.visibleCells() as [UITableViewCell]
        var selectedQuestions:[String] = []
        for theCell in cells {
            if theCell.accessoryType == UITableViewCellAccessoryType.Checkmark   {
                if let textLabel = theCell.textLabel?.text! {
                    selectedQuestions.append(textLabel)
                }
                
            }
        }
        
        return selectedQuestions
    }
    
}
