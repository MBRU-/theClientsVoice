//
//  StartViewController.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 03.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//

import UIKit

class StartViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    let q = Question()
    var questions:[QuestionMask]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        questions = q.getQuestionList()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let cnt = questions?.count {
            println("Count: \(questions!.count)")
            return questions!.count
        }
        else {
            return 0
        }
        

        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: QCell = tableView.dequeueReusableCellWithIdentifier("myCell") as QCell
        
        cell.questionCellTextLabel.text = questions![indexPath.row].question
        if questions![indexPath.row].isDefault  {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell.backgroundColor = UIColor.greenColor()
            println("TRUE")
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.backgroundColor = UIColor.whiteColor()
            println("FALSE")
        }
        
        return cell
    }
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView.cellForRowAtIndexPath(indexPath)?.accessoryType == UITableViewCellAccessoryType.Checkmark {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
            tableView.cellForRowAtIndexPath(indexPath)?.backgroundColor = UIColor.whiteColor()
        }
        else {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
            tableView.cellForRowAtIndexPath(indexPath)?.backgroundColor = UIColor.greenColor()
            
        }
    }
    

   
}
