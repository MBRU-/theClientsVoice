//
//  PrintResultsViewController.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 15.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//

import UIKit

class PrintResultsViewController: UIViewController {

    @IBOutlet weak var pdfTextView: UITextView!
    var questions: [String] = []        // Set by prpareForSegue within StartViewController
    var clientName = ""                 // Set by prpareForSegue within StartViewController
    var allCSAT: [[CSAT]] = []          // Set by prpareForSegue within StartViewController
    var comment: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        printAll()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
//Printing related stuff
    //prearing formated text. we stuff all the text into "theString = NSMutableAttributedString(attributedString: attributedText)"
    // the container to display all text: "pdfTextView"
    func printAll() {
        let titleFont = UIFont(name: "Helvetica Bold", size: 14)!
        let textFont = UIFont(name: "Helvetica Neue", size: 12)!
        
        let titleParagraph = NSMutableParagraphStyle()
        
        let textParagraph = NSMutableParagraphStyle()
        textParagraph.alignment = NSTextAlignment.Left
        
        var titleAttributes = [NSFontAttributeName:titleFont,NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: titleParagraph]
        
        var textAttributes = [NSFontAttributeName:textFont,NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: textParagraph]
        
        let title = "IBM Client Center Research - Client Feedback - \n\n"
        let date =  Date.toString(dateOrTime: kDateFormat)  + "\n\n"
        let client = "\(clientName)\n\n"
        let eventMgr = "\(User.credentials().userName)\n\n"

        var ratingSum = 0.0
        var ratingCount = 0.0
        for all in allCSAT {
            for cs in all {
                ratingSum += normalize(cs.rating)
                ratingCount++
            }
        }
        var eval = 0.0
        if ratingCount > 0 {
            eval = Double (ratingSum / ratingCount)
            println("Values: \(ratingSum)  \(ratingCount)  \(eval)")
            println(NSString(format:"%.1f", eval))

        }
        else {
            eval = 9.9
        }
        
        let evalAverage = (NSString(format:"%.1f", eval)) + "\n\n"
        let header = "#\tEval.\t\tDate-Time"
        let evalAll = ["2\t1\t","2\t1\t","1\t2\t","1\t1\t","2\t1\t"]
        var attributedText = NSAttributedString(string:"",attributes: titleAttributes)
        var theString = NSMutableAttributedString(attributedString: attributedText)
        
        theString.appendAttributedString(NSAttributedString(string:"IBM Client Center Research-Zurich - Client Feedback - \n\n",attributes: titleAttributes))
        theString.appendAttributedString(NSAttributedString(string:"Date: \t",attributes: titleAttributes))
        theString.appendAttributedString(NSAttributedString(string:date,attributes: textAttributes))
        
        theString.appendAttributedString(NSAttributedString(string:"Client: \t",attributes: titleAttributes))
        theString.appendAttributedString(NSAttributedString(string:client,attributes: textAttributes))
        
        theString.appendAttributedString(NSAttributedString(string:"Event Mgr: \t",attributes: titleAttributes))
        theString.appendAttributedString(NSAttributedString(string:eventMgr,attributes: textAttributes))
        
        theString.appendAttributedString(NSAttributedString(string:"Evaluation Average: \t",attributes: titleAttributes))
        theString.appendAttributedString(NSAttributedString(string:evalAverage,attributes: textAttributes))
        
        theString.appendAttributedString(NSAttributedString(string:"#\tEval.\t\tDate-Time",attributes: titleAttributes))

        // Preparing for comments
        prepareComments()
        
        var fbNumber = 1
        var fbPerClient = ""
        var fbAll = ""
        var timeStamp = ""
        for all in allCSAT {
            var qNr = 0
            fbPerClient = "\n\(fbNumber): \t "
            for cs in all {
                fbPerClient += "\(cs.rating)\t"
                timeStamp = "\(cs.timeStamp)"
                if !cs.comment.isEmpty {
                    comment[qNr] += "\n \(cs.comment)"
                }
                qNr++
            }
            fbPerClient += "\t\(timeStamp)"
            fbAll += fbPerClient
            fbNumber++
        }
        var subString = NSAttributedString(string: fbAll , attributes: textAttributes)
        theString.appendAttributedString(subString)
        
        //now setting up questions
        var commentString = ""
        var qTitle = ""
        var count = 0
        qTitle = "\n\n Comments\n"
        subString = NSAttributedString(string: qTitle , attributes: titleAttributes)
        theString.appendAttributedString(subString)
        
        for str in questions {
            qTitle = ""
            commentString = ""
            qTitle += "\n\(count+1)\t \(str) \n"
            commentString += "\(comment[count]) \n"
            count++
            subString = NSAttributedString(string: qTitle , attributes: titleAttributes)
            theString.appendAttributedString(subString)
            
            subString = NSAttributedString(string: commentString , attributes: textAttributes)
            theString.appendAttributedString(subString)
            
        }

        pdfTextView.attributedText = theString
        println("Lenght of text: \(CFAttributedStringGetLength(pdfTextView.attributedText))")
        makePDF()
    }

    func makePDF() -> Bool {
        let resultDir = "/Results"
        var isDirectory = false as ObjCBool
        
        let path =  NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
        println("Path: \(path)")
        
        var outputFileName = "\(resultDir)/\(Date.toString(dateOrTime: kDateForSortFormat))_\(clientName).pdf"
        
        let docDirectory: AnyObject = path[0]
        let filePath = docDirectory.stringByAppendingPathComponent(outputFileName)
        println("FilePath: \(filePath)")
        
        let fManager = NSFileManager.defaultManager()
        
        if fManager.fileExistsAtPath(resultDir, isDirectory: &isDirectory) == false{
            if isDirectory {

            }
            else {
                fManager.createDirectoryAtPath("\(path[0])\(resultDir)", withIntermediateDirectories: true, attributes: nil, error: nil)
            }

        }

        if  fManager.createFileAtPath(filePath, contents: nil, attributes: nil)  {
            println("Success")
        }
        else {
            println("Failed")
            return false
        }
        
        //        var frameSetter = CTFramesetterCreateWithAttributedString(myString)
        var frameSetter = CTFramesetterCreateWithAttributedString(pdfTextView.attributedText)
        
        if (frameSetter != nil)   {
            
            // Create the PDF context using the default page size of 612 x 792.
            UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil)
            
            var currentRange: CFRange = CFRangeMake(0, 0)
            var currentPage = 0
            var done:Bool = false
            
            do {        //...until one page is full
                
                // Mark the beginning of a new page.
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                //                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 10, 50), nil);
                
                // Draw a page number at the bottom of each page.
                currentPage++
                self.drawPageNumber(currentPage)
                
                // Render the current page and update the current range to
                // point to the beginning of the next page.
                currentRange = renderPagewithTextRange(currentRange, frameSetter: frameSetter)
                
                // If we're at the end of the text, exit the loop.
                if (currentRange.location == CFAttributedStringGetLength(pdfTextView.attributedText)) {
                    done = true
                }
                println("once done")
                
            } while (!done)
            
            // Close the PDF context and write the contents out.
            UIGraphicsEndPDFContext();
            // Release the framewetter.
        } //end if
        else {
            println("FrameSetter didnt work")
        }
        return true
    }
    
    //Helper PDF Creation
    
    func renderPagewithTextRange ( currentRange:CFRange, frameSetter:CTFramesetterRef ) ->CFRange {
        // Get the graphics context.
        let currentContext: CGContextRef = UIGraphicsGetCurrentContext()
        
        // Put the text matrix into a known state. This ensures
        // that no old scaling factors are left in place.
        CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity)
        
        // Create a path object to enclose the text. Use 72 point
        // margins all around the text.
        let frameRect = CGRectMake(72, 72, 468, 648)
        let framePath = CGPathCreateMutable()
        CGPathAddRect(framePath, nil, frameRect)
        
        // Get the frame that will do the rendering.
        // The currentRange variable specifies only the starting point. The framesetter
        // lays out as much text as will fit into the frame.
        let frameRef = CTFramesetterCreateFrame(frameSetter, currentRange, framePath, nil)
        
        // Core Text draws from the bottom-left corner up, so flip
        // the current transform prior to drawing.
        CGContextTranslateCTM(currentContext, 0, 792)
        CGContextScaleCTM(currentContext, 1.0, -1.0)
        
        // Draw the frame.
        CTFrameDraw(frameRef, currentContext)
        
        // Update the current range based on what was drawn.
        var currRange = currentRange
        currRange = CTFrameGetVisibleStringRange(frameRef)
        currRange.location += currRange.length
        currRange.length = 0
        
        return currRange
    }
    
    
    func drawPageNumber ( pageNumber: Int) {
        let pageString:NSString = "Page \(pageNumber)"
        
        let theFont = UIFont.systemFontOfSize(14)
        let maxSize = CGSizeMake(612, 72);
        let attributes:NSDictionary = [NSFontAttributeName:theFont]
        let pageStringSize = pageString.sizeWithAttributes([NSFontAttributeName:theFont])
        let stringRect = CGRectMake(((612.0 - pageStringSize.width) / 2.0),720.0 + ((72.0 - pageStringSize.height) / 2.0),pageStringSize.width,pageStringSize.height)
        
        pageString.drawInRect(stringRect, withAttributes: attributes)
    }

    
    
    
    //Helper Functions
    func normalize(value: Int) -> Double {
        switch value {
        case (8...10):
            return 1.0
        case (6...7):
            return 2.0
        case (4...5):
            return 3.0
        case (3):
            return 4.0
        case (1...2):
            return 5.0
        default:
            return 1.0
        }
    }

    func prepareComments() {
        comment = []
        var cs:String = ""
        for i in questions {
            comment.append(cs)
        }
        
    }

}
