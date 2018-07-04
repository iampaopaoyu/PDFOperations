//
//  SplitViewController.swift
//  PDFConvert
//
//  Created by Steven Kanceruk on 12/1/17.
//  Copyright © 2017 steve. All rights reserved.
//

import Cocoa

class SplitViewController: NSViewController {

    @IBOutlet weak var inputpath_field: NSTextField!
    @IBOutlet weak var outputpath_field: NSTextField!
    @IBOutlet weak var outputFilename: NSTextField!
    
    @IBOutlet weak var inputPathButton: NSButton!
    @IBOutlet weak var outputPathButton: NSButton!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var completeLabel: NSTextField!
    @IBOutlet weak var infoLabel: NSTextField!
    
    var inputPath = String()
    var outputPath:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        completeLabel.stringValue = ""
        //.isHidden = true
        progressIndicator.isHidden = true
    }
    
    @IBAction func browseFileInput(sender: AnyObject) {
        let dialog = NSOpenPanel();
        
        // completeLabel.isHidden = true
        
        dialog.title                   = "Choose a pdf file to split";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = false;
        // dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false // true;
        dialog.allowedFileTypes        = ["pdf"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                
                inputpath_field.stringValue = path
                inputPath = path
                let pdfURL = inputPath
                let localUrl = pdfURL as! CFString
                let input_pdfDocumentRef = CFURLCreateWithFileSystemPath(nil, localUrl, CFURLPathStyle.cfurlposixPathStyle, false)
                let input_pdfReference = CGPDFDocument(input_pdfDocumentRef!)
                let numberOfPages = input_pdfReference!.numberOfPages
                //infoLabel.stringValue = "You will be creating \(numberOfPages)  new files"
                completeLabel.stringValue = "You will be creating \(numberOfPages) new files"
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func browseFileOutput(sender: AnyObject) {
        let dialog = NSOpenPanel();
        
        // completeLabel.isHidden = true
        
        dialog.title                   = "Choose a folder for the output";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseFiles = false
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                outputpath_field.stringValue = path
                outputPath = path
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func splitButtonPressed(sender: AnyObject) {
        
        if (!checkInputs()) {
            return
        }
        
        progressIndicator.startAnimation(nil)
        progressIndicator.isHidden = false
        
        let pdfURL = inputPath
        let cfPdfUrl = pdfURL as CFString
        //let pdfPath = CFBridgingRetain(pdfURL) as! CFString
        let localUrl  = pdfURL as! CFString
        let cfurl = CFURLCreateWithString(nil, cfPdfUrl, nil)
        print("the localurl =    \(localUrl)")
        print("the cfurl =    \(cfurl)")
        let input_pdfDocumentRef = CFURLCreateWithFileSystemPath(nil, localUrl, CFURLPathStyle.cfurlposixPathStyle, false)
        // NSLog("\(pdfPath)")
        // let input_pdfReferencetwo = CGPDFDocument(cfurl!)
        let input_pdfReference = CGPDFDocument(input_pdfDocumentRef!)
        // NSLog(String(describing: pdfDocumentRef ))
        NSLog("number ")
        NSLog(String(describing: input_pdfReference?.numberOfPages))
        //let numberOfPages = input_pdfReference!.numberOfPages
        let numberOfPages = input_pdfReference!.numberOfPages
        
        var page: CGPDFPage
        var mediaBox: CGRect
        
        let outputFileName = outputFilename.stringValue
        
        print("the output file name =    \(outputFileName)")
        
        
        for index in 1...numberOfPages {
            
            // let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
            let documentsPath = NSURL(fileURLWithPath: outputPath!)
            let outputPDFPath = documentsPath.appendingPathComponent("\(outputFileName)-\(index).pdf")
            let cfOutputPDFPath: CFURL = outputPDFPath! as CFURL
            let currentWriteContext = CGContext(cfOutputPDFPath, mediaBox: nil, nil)
            guard let getCGPDFPage = input_pdfReference?.page(at: index) else {
                NSLog("Error occurred in creating page")
                return
            }
            page = getCGPDFPage
            mediaBox = page.getBoxRect(.mediaBox)
            currentWriteContext!.beginPage(mediaBox: &mediaBox)
            currentWriteContext!.drawPDFPage(page)
            currentWriteContext!.endPage()
            currentWriteContext!.closePDF();
        }
        
        NSLog("DONE!")
        progressIndicator.stopAnimation(nil)
        progressIndicator.isHidden = true
        completeLabel.stringValue = "File Split!"
        //.isHidden = false
        
        clearInputs()
    }
    
    func checkInputs() -> Bool{
        if (inputpath_field.stringValue == "" ||  outputpath_field.stringValue == "" || outputFilename.stringValue == "") {
            let alert = NSAlert()
            alert.messageText =  "Enter all values"
            alert.informativeText = "Please enter values for input path, output path and output title"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return false
        }
        return true
    }
    
    func clearInputs() {
        inputpath_field.stringValue = ""
        outputpath_field.stringValue = ""
        outputFilename.stringValue = ""
    }
}
