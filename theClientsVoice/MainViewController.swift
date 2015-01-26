//
//  mainViewController.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 09.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var questionBackButton: UIBarButtonItem!
    @IBOutlet weak var questionNextButton: UIBarButtonItem!
    @IBOutlet weak var questionNextButtonLow: UIButton!
    
    @IBOutlet weak var clientNameTextLabel: UILabel!
    @IBOutlet weak var questionsTitelTextLabel: UILabel!
    @IBOutlet weak var questionTextLabel: UILabel!
    
    @IBOutlet weak var ratingBarSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var optionalCommentTextField: UITextField!
    @IBOutlet weak var optionalCommentsTextLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var questions: [String] = []    // Set by prpareForSegue within StartViewController
    var clientName = ""             // Set by prpareForSegue within StartViewController
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
        optionalCommentTextField.delegate = self
        
        println("Register KB")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardPresented:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardRemoved:", name: UIKeyboardDidHideNotification, object: nil)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        scrollView.bounds.size = self.view.bounds.size
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        println("Deregistering!")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "printResultsSegue" {
            let detailVC: PrintResultsViewController = segue.destinationViewController as PrintResultsViewController
            detailVC.questions = self.questions
            detailVC.clientName = clientName
            detailVC.allCSAT = self.allCSAT
            
        }
    }
    
    //Mark - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == optionalCommentTextField {
            optionalCommentTextField.resignFirstResponder()
            return true
        }
        else {
            return false
        }
    }
    
    
    //Mark - Keyboard Notification handler
    func keyboardPresented(notification: NSNotification) {
        
        var info: Dictionary = notification.userInfo!
        var keyboardSize: CGSize = (info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size)!
        var viewOrigin: CGPoint = self.optionalCommentTextField.frame.origin
        var viewHeight: CGFloat = self.optionalCommentTextField.frame.size.height
        var visibleRect: CGRect = self.scrollView.frame
        visibleRect.size.height -= keyboardSize.height
        
        let popupResponse = popUp.isPopupPresent()
        if popupResponse.isPresent {
            viewOrigin = popupResponse.view!.frame.origin
            viewHeight = popupResponse.view!.frame.size.height
            viewOrigin.y += viewHeight
            
            if (!CGRectContainsPoint(visibleRect, viewOrigin)) {
                let newY = ( (visibleRect.origin.y + visibleRect.size.height) - viewHeight)
                popUp.moveFrameUp(newY / 1.2 )
            }
        }
        else {
            viewOrigin = self.optionalCommentTextField.frame.origin
            viewHeight = self.optionalCommentTextField.frame.size.height
            
            if (!CGRectContainsPoint(visibleRect, viewOrigin)) {
                var scrollPoint: CGPoint = CGPointMake(0.0, viewOrigin.y - visibleRect.size.height + viewHeight + 4)
                self.scrollView.setContentOffset(scrollPoint, animated: true)
                
            }
            
        }
    }
    
    func keyboardRemoved(notification: NSNotification) {
        self.scrollView.setContentOffset(CGPointZero, animated: true)
        
    }
    
    
    //Custom Button Actions
    
    @IBAction func adminBarButtonItemPressed(sender: UIBarButtonItem) {
        popUp.show(self.view)
        
    }
    
    func okButtonPressedFromPopup(button: UIButton) {
        if User.verifyPassword(popUp.password()) == true {
            performSegueWithIdentifier("printResultsSegue", sender: self)
            popUp.remove()
        }
        
    }
    
    func cancelButtonPressedFromPopup(button: UIButton) {
        popUp.remove()
    }
    
    
    func abortButtonPressedFromPopup(button: UIButton) {
        if User.verifyPassword(popUp.password()) == true {
            performSegueWithIdentifier("returnToStartSegue", sender: self)
            popUp.remove()
        }
        
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
            Alert.showAlertWithText(viewController: self, header: "Thank you!", message: "Have a safe return.")
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
        
        optionalCommentTextField.hidden = !commentsTurnedOn
        optionalCommentsTextLabel.hidden = !commentsTurnedOn
        
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

