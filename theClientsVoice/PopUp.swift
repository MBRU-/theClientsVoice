//
//  PopUp.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 13.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//

import UIKit
import Foundation

let kMarginForView: CGFloat = 200.0
let kMarginForSlot:CGFloat = 2.0
let kSixth:CGFloat = 1.0/6.0
let kThird:CGFloat = 1.0/3.0

let kHalf:CGFloat = 1.0/2.0
let kEighth:CGFloat = 1.0/8.0



class PopUp {
    var popUpContainer: UIView!
    var backgroundImage: UIImageView!
    var titleLabel: UILabel!
    var passwordTextField = UITextField()
    var okButton: UIButton!
    var cancelButton: UIButton!
    var theViewController: UIViewController!
    
    init() {
        
    }
    
    func setupContainerView (view: UIView ) {
        //      let view = theViewController.view

//        popUpContainer = UIView(frame: CGRect(x: view.bounds.origin.x + kMarginForView, y: view.bounds.origin.y + 100, width: view.bounds.width - (kMarginForView * 2), height: view.bounds.height * kThird))
        popUpContainer = UIView(frame: CGRect(x: view.bounds.origin.x + kMarginForView, y: view.bounds.origin.y + 80,width: view.bounds.width/2, height: 40))
            
        popUpContainer.backgroundColor = UIColor.whiteColor()
        popUpContainer.opaque = true
        popUpContainer.alpha = CGFloat(0.95)
        popUpContainer.autoresizesSubviews = true
        view.addSubview(popUpContainer)
        
        setupContainerContent()
    }
    
    
    func setupContainerContent () {
        
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
        
        let titleFont = UIFont(name: "Helvetica Neue Light Italic", size: 12)!
        titleLabel = UILabel()
        titleLabel.font = titleFont
        titleLabel.text = "Please select the second row and press swap button again"
        titleLabel.textColor = UIColor.redColor()
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: CGFloat(containerView.frame.width/2), y: CGFloat(containerView.frame.height/2))
        containerView.addSubview(titleLabel)
        
      }
    
    func removePopUp() {
        popUpContainer.removeFromSuperview()
    }
    
}

