//
//  PopUp.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 14.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//

import UIKit
import Foundation


class PopUp {
    private let kMarginForView: CGFloat = 60.0
    private let kMarginForSlot:CGFloat = 2.0
    private let kSixth:CGFloat = 1.0/6.0
    private let kThird:CGFloat = 1.0/3.0
    
    private let kHalf:CGFloat = 1.0/2.0
    private let kEighth:CGFloat = 1.0/8.0
    
    private var popUpContainer: UIView!
    private var bgContainer:UIView!
    private var backgroundImage: UIImageView!
    private var titleLabel: UILabel!
    private var okButton: UIButton!
    private var cancelButton: UIButton!
    private var theViewController: UIViewController!
    var passwordTextField = UITextField()    
    
    init() {
        
    }
    
    func show (view: UIView ) {
        //      let view = theViewController.view
        //        popUpContainer = UIView(frame: CGRect(x: view.bounds.origin.x + kMarginForView, y: view.bounds.origin.y + 100, width: view.bounds.width - (kMarginForView * 2), height: view.bounds.height * kThird))
        bgContainer = UIView(frame: CGRect(x: 0.0 , y: 0.0, width: view.bounds.width, height: view.bounds.height))
        bgContainer.backgroundColor = UIColor.whiteColor()
        bgContainer.opaque = true
        bgContainer.alpha = CGFloat(0.80)
        bgContainer.autoresizesSubviews = true
        view.addSubview(bgContainer)
        
        popUpContainer = UIView(frame: CGRect(x: (view.bounds.width/2)-150 , y: (view.bounds.height/2)-150, width: 300.0, height: 300.0))
        popUpContainer.backgroundColor = UIColor.whiteColor()
        popUpContainer.opaque = true
        popUpContainer.alpha = CGFloat(0.95)
        popUpContainer.autoresizesSubviews = true
        view.addSubview(popUpContainer)
        
        println("popupContainer")
        setupContainerContent()
    }
    
    
    private func setupContainerContent () {
        
        var containerView = popUpContainer
        
        var bgImage = UIImage(named: "background300.jpg")
        var  size = CGSizeApplyAffineTransform(bgImage!.size, CGAffineTransformMakeScale(0.5, 0.5)) // 0.5
        size = containerView.bounds.size
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        bgImage!.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        backgroundImage = UIImageView(image: scaledImage)
        backgroundImage.contentMode = UIViewContentMode.ScaleToFill
        
        backgroundImage.alpha = CGFloat(1.0)
        containerView.addSubview(backgroundImage)
        
        let titleFont = UIFont(name: "Helvetica Light", size: 12)!

        titleLabel = UILabel()
        titleLabel.font = titleFont
        titleLabel.text = "Finish: Please enter your Password"
        titleLabel.textColor = UIColor.redColor()
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: CGFloat(containerView.frame.width/2), y: CGFloat(containerView.frame.height * kSixth))
        containerView.addSubview(titleLabel)
        
        
        passwordTextField = UITextField(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat( containerView.frame.width * 0.8), height: CGFloat(30)))
        passwordTextField.text = ""
        passwordTextField.secureTextEntry = true
        passwordTextField.center = CGPoint(x: CGFloat(containerView.frame.width/2), y: CGFloat(containerView.frame.height * kSixth * 2.5))
        passwordTextField.borderStyle = UITextBorderStyle.RoundedRect
        containerView.addSubview(passwordTextField)
        
        okButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        okButton.setTitle(" OK ", forState: UIControlState.Normal)
        okButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        okButton.sizeToFit()
        okButton.center = CGPoint(x: CGFloat(containerView.frame.width/4), y: CGFloat(containerView.frame.height * kSixth * 4))
        okButton.addTarget(nil , action: "okButtonPressedFromPopup:", forControlEvents: UIControlEvents.TouchUpInside)
        containerView.addSubview(okButton)
        
        cancelButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        cancelButton.setTitle(" Cancel ", forState: UIControlState.Normal)
        cancelButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        cancelButton.sizeToFit()
        cancelButton.center = CGPoint(x: CGFloat(containerView.frame.width/2), y: CGFloat(containerView.frame.height * kSixth * 4))
        cancelButton.addTarget(nil , action: "cancelButtonPressedFromPopup:", forControlEvents: UIControlEvents.TouchUpInside)
        containerView.addSubview(cancelButton)
        
    }
    
    
    func remove() {
        bgContainer.removeFromSuperview()
        popUpContainer.removeFromSuperview()
    }
    
}
