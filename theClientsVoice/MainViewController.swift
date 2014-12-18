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
    @IBOutlet weak var clientNameTextLabel: UILabel!
    @IBOutlet weak var optionalCommentsTextLabel: UILabel!
    
    @IBOutlet weak var dummyButtonForrSegue: UIButton!
    
    var questions: [String] = []
    var clientName = ""
    var csat: [CSAT] = []
    var allCSAT: [[CSAT]] = []
    var commentsTurnedOn = true


    let nextButton = ["Next", "Submit"]
    
    var nrOfQuestions = 0
    var qCount = 0
    var selectedSegmentIndex = 0
    let popUp = PopUp()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        clientNameTextLabel.text = clientName
        nrOfQuestions = questions.count
        prepareCsat()
        setupScreen(qCount)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "printResultsSegue" {
            let detailVC: PrintResultsViewController = segue.destinationViewController as PrintResultsViewController
            detailVC.questions = self.questions
            detailVC.clientName = clientName
            detailVC.allCSAT = self.allCSAT
            
        }
    }
    
    
    //Custom Button Actions
    
    
    @IBAction func adminBarButtonItemPressed(sender: UIBarButtonItem) {
        popUp.show(self.view)

    }
    
    func okButtonPressedFromPopup(button: UIButton) {
        if User.verifyPassword(popUp.passwordTextField.text) == true {
            performSegueWithIdentifier("printResultsSegue", sender: self)
            popUp.remove()
        }

    }
    
    
    func cancelButtonPressedFromPopup(button: UIButton) {
        popUp.remove()
    }
    
    @IBAction func questionBackButtonPressed(sender: UIBarButtonItem) {
        if qCount >  0 {
            qCount--
            setupScreen(qCount)
            ratingBarSegmentedControl.selectedSegmentIndex = csat[qCount].rating-1
            optionalCommentTextField.text = csat[qCount].comment
            selectedSegmentIndex = csat[qCount].rating
            questionNextButtonLow.hidden = false

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
            Alert.showAlertWithText(viewController: self, header: "Alert", message: "Please rate between 1 ... 10 first.")
        } else if qCount < (nrOfQuestions-1) {
            csat[qCount].rating = selectedSegmentIndex
            csat[qCount].comment = optionalCommentTextField.text
            csat[qCount].timeStamp = Date.toString(dateOrTime: kTimeFormat)
            qCount++
            setupScreen(qCount)
            selectedSegmentIndex = 0
            
        }  else if qCount >= nrOfQuestions-1 {

            csat[qCount].rating = selectedSegmentIndex
            csat[qCount].comment = optionalCommentTextField.text
            csat[qCount].timeStamp = Date.toString(dateOrTime: kTimeFormat)
 
            allCSAT.append(csat)
            prepareCsat()
            Alert.showAlertWithText(viewController: self, header: "Thank you!", message: "Have a save return.")
            qCount = 0
            selectedSegmentIndex = 0
            setupScreen(qCount)
            
        }
    }
    
    func setupScreen( count: Int) {
        
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
        
        optionalCommentTextField.hidden = commentsTurnedOn
        optionalCommentsTextLabel.hidden = commentsTurnedOn
        
        optionalCommentTextField.text = ""
        ratingBarSegmentedControl.selectedSegmentIndex =  UISegmentedControlNoSegment
        questionTextLabel.text = questions[count]
        questionsTitelTextLabel.text = "Question \(count+1) of \(nrOfQuestions)"
        
        optionalCommentTextField.resignFirstResponder()
        
    }

  
    //Initialize array with with instances of CSAT structure
    func prepareCsat() {
        csat = []
        var cs:CSAT = CSAT()
        for i in questions {
        csat.append(cs)
        }
    
    }
}

