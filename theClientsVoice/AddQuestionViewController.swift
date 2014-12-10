//
//  AddQuestionViewController.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 09.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//

import UIKit

class AddQuestionViewController: UIViewController {

    @IBOutlet weak var addQuestionTextField: UITextView!
    
    @IBOutlet weak var isDefaultQuestionControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        addQuestionTextField.backgroundColor = UIColor(red: CGFloat(0.95), green: CGFloat(0.95), blue: CGFloat(0.95), alpha: CGFloat(0.95))
        addQuestionTextField.layer.cornerRadius = 10.0
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        addQuestionTextField.resignFirstResponder()
        self.dismissViewControllerAnimated(true , completion: nil)
    }

    @IBAction func saveQuestionButtonPressed(sender: UIBarButtonItem) {
        var defaultQuestion = false
        if isDefaultQuestionControl.selectedSegmentIndex == 0 {
           defaultQuestion = true
        }
        else {
           defaultQuestion = false
        }
        
        let q = Question()
        
        if addQuestionTextField.text.isEmpty{
            
        }else {
            if q.addQuestion(addQuestionTextField.text, isDefault: defaultQuestion){
                println("SUCCESS")
            }
            else {
                println("FAILURE")
            }

        }
            addQuestionTextField.resignFirstResponder()
            addQuestionTextField.text = ""
            isDefaultQuestionControl.selectedSegmentIndex = 0
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
