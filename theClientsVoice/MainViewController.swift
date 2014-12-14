//
//  mainViewController.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 09.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

            
        @IBOutlet weak var questionBackButton: UIBarButtonItem!
        @IBOutlet weak var questionNextButton: UIBarButtonItem!
        
        @IBOutlet weak var ratingBarSegmentedControl: UISegmentedControl!
        @IBOutlet weak var questionTextLabel: UILabel!
        @IBOutlet weak var questionsTitelTextLabel: UILabel!
        @IBOutlet weak var optionalCommentTextField: UITextField!
        @IBOutlet weak var questionNextButtonLow: UIButton!
        
        @IBOutlet weak var startTextView: UITextView!
        @IBOutlet weak var startSurveyButton: UIButton!
        
        var questions: [String] = []
    
        let nextButton = ["Next", "Submit"]
        
        var nrOfQuestions = 0
        var qCount = 0
        var selectedSegmentIndex = 0
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
println("Questions \(questions)")
            nrOfQuestions = questions.count
            setupScreen(qCount)
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        @IBAction func startSurveyButtonPressed(sender: UIButton) {
            startSurveyButton.hidden = true
            startTextView.hidden = true
            questionNextButton.title = nextButton[0]
        }
        
        @IBAction func questionBackButtonPressed(sender: UIBarButtonItem) {
            if qCount >  0 {
                qCount--
                setupScreen(qCount)
            }
        }
        
        @IBAction func questionNextButtonLowPressed(sender: UIButton) {
            nextButtonPressed()
        }
        
        
        @IBAction func QuestionNextButtonPressed(sender: UIBarButtonItem) {
            nextButtonPressed()
        }
        
        @IBAction func ratingBarPressed(sender: UISegmentedControl) {
            optionalCommentTextField.resignFirstResponder()
            selectedSegmentIndex = sender.selectedSegmentIndex+1
            questionNextButtonLow.hidden = false
            
        }
        
        // Helper Functions
        
        func nextButtonPressed() {
            optionalCommentTextField.resignFirstResponder()
            if selectedSegmentIndex == 0 {
                self.showAlertWithText(header: "Alert", message: "Please rate between 1 ... 10 first.")
            } else if qCount < (nrOfQuestions-1) {
                qCount++
                setupScreen(qCount)
                selectedSegmentIndex = 0
                
            }  else if qCount >= nrOfQuestions-1 {
                self.showAlertWithText(header: "Thank you!", message: "Have a save return.")
                qCount = 0
                selectedSegmentIndex = 0
                setupScreen(qCount)
//                startSurveyButton.hidden = false
//                startTextView.hidden = false
                
            }
        }
        
        func setupScreen( count: Int) {
            println("Count \(count )")
            
            questionNextButtonLow.hidden = true
            questionNextButton.title = nextButton[0]
            questionNextButtonLow.setTitle(nextButton[0], forState: UIControlState.Normal)
            if count == 0 {
                questionBackButton.enabled = false
            }
            if count > 0 && count <= (nrOfQuestions-1) {
                questionBackButton.enabled = true
            }
            if count == (nrOfQuestions-1) {
                questionNextButton.title = nextButton[1]
                
                questionNextButtonLow.setTitle(nextButton[1], forState: UIControlState.Normal)
            }
            
            optionalCommentTextField.text = ""
            ratingBarSegmentedControl.selectedSegmentIndex =  UISegmentedControlNoSegment
            questionTextLabel.text = questions[count]
            questionsTitelTextLabel.text = "Question \(count+1) of \(nrOfQuestions)"
            
            optionalCommentTextField.resignFirstResponder()
            
        }
        
    func showAlertWithText (header: String = "Warning", message: String) {
        var alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
}

