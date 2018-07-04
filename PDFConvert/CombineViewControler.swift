//
//  CombineViewControleer.swift
//  PDFConvert
//
//  Created by Steven Kanceruk on 11/30/17.
//  Copyright © 2017 steve. All rights reserved.
//

import Cocoa

class CombineViewControler: NSViewController {

    
    @IBOutlet weak var inputpath_field: NSTextField!
    @IBOutlet weak var outputpath_field: NSTextField!
    @IBOutlet weak var outputFilename: NSTextField!
    
    @IBOutlet weak var inputPathButton: NSButton!
    @IBOutlet weak var outputPathButton: NSButton!
    
    @IBOutlet weak var infoLabel: NSTextField!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var completeLabel: NSTextField!
    
    var inputPaths = [String]()
    var outputPath:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        completeLabel.stringValue = ""
        // isHidden = true
        progressIndicator.isHidden = true
        // Do view setup here.
    }
    
    
    @IBAction func browseFile(sender: AnyObject) {
        let dialog = NSOpenPanel();
        
        //completeLabel.isHidden = true
        
        dialog.title                   = "Choose pdf files to merge";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = false;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = true;
        dialog.allowedFileTypes        = ["pdf"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                //if (sender as? NSButton == inputPathButton) {
                    let thePDFs = dialog.urls
                    for p in thePDFs {
                        inputpath_field.stringValue += "\(p.absoluteString) ; "
                        inputPaths.append(p.absoluteString)
                    }
                    // inputpath_field.stringValue = path
                    // inputPath = path
                    //infoLabel.stringValue = "You will be combining \(thePDFs.count) files"
                    completeLabel.stringValue = "You will be combining \(thePDFs.count) files"
                //}
                
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func browseFileOutput(sender: AnyObject) {
        let dialog = NSOpenPanel();
        
        //completeLabel.isHidden = true
        
        dialog.title                   = "Choose a folder for the output";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseFiles          = false
        
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
    
    @IBAction func combineButtonPressed(_ sender: Any) {
        
        if (!checkInputs()) {
            return
        }
        
        checkDupe()
        
        progressIndicator.startAnimation(nil)
        progressIndicator.isHidden = false
        let file = outputFilename.stringValue
        
        // let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let documentsPath = NSURL(fileURLWithPath: outputPath!)
        let outputPDFPath = documentsPath.appendingPathComponent("\(file).pdf")
        // \(outputPath!)/
        
        let fullPDFOutput: CFURL = outputPDFPath! as CFURL
        
        let writeContext = CGContext(fullPDFOutput, mediaBox: nil, nil)
        
        for pdfURL in inputPaths {
            NSLog(pdfURL)
            let cfPdfUrl = pdfURL as CFString
            //let pdfPath: CFURL =  NSURL(fileURLWithPath: pdfURL) as CFURL
            let pdfPath = CFBridgingRetain(pdfURL) as! CFString
            let localUrl  = pdfURL as CFString
            let cfurl = CFURLCreateWithString(nil, cfPdfUrl, nil)
            let pdfDocumentRef = CFURLCreateWithFileSystemPath(nil, localUrl, CFURLPathStyle.cfurlposixPathStyle, false)
            //    CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:thePath];
            NSLog("\(pdfPath)")
            //let pdfReference = CGPDFDocument(pdfPath)
            let pdfReference = CGPDFDocument(cfurl!)
            //NSLog(String(describing: pdfReference ))
            NSLog(String(describing: pdfDocumentRef ))
            NSLog("number ")
            NSLog(String(describing: pdfReference?.numberOfPages))
            let numberOfPages = pdfReference!.numberOfPages
            //NSLog(String(describing: pdfDocumentRef?.numberOfPages))
            //let numberOfPages = pdfDocumentRef!.numberOfPages
            var page: CGPDFPage
            var mediaBox: CGRect
            
            for index in 1...numberOfPages {
                
                guard let getCGPDFPage = pdfReference?.page(at: index) else {
                    NSLog("Error occurred in creating page")
                    progressIndicator.stopAnimation(nil)
                    progressIndicator.isHidden = true
                    return
                }
                page = getCGPDFPage
                mediaBox = page.getBoxRect(.mediaBox)
                writeContext!.beginPage(mediaBox: &mediaBox)
                writeContext!.drawPDFPage(page)
                writeContext!.endPage()
            }
        }
        NSLog("DONE!")
        progressIndicator.stopAnimation(nil)
        progressIndicator.isHidden = true
        //completeLabel.isHidden = false
        inputPaths.removeAll()
        completeLabel.stringValue = "Files Combined!"
        
        clearInputs()
        
        writeContext!.closePDF();
        
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
        /*
        let documentsPath = NSURL(fileURLWithPath: outputPath!)
        let outputPDFPath = documentsPath.appendingPathComponent("\(outputFilename.stringValue).pdf")
        let output = outputPath!.appending("/").appending(outputFilename.stringValue).appending(".pdf")
        print("file path - \(output)")
        if ( FileManager.default.fileExists(atPath: output) ) {
            let alert = NSAlert()
            alert.messageText =  "A file already exists at the output location"
            alert.informativeText = "A file with the output name already exists at the output location. Do you want to overwrite it?"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            return alert.runModal() == .alertFirstButtonReturn
            // return false
        }*/
        return true
    }
    
    func checkDupe(){
        let documentsPath = NSURL(fileURLWithPath: outputPath!)
        let outputPDFPath = documentsPath.appendingPathComponent("\(outputFilename.stringValue).pdf")
        let output = outputPath!.appending("/").appending(outputFilename.stringValue).appending(".pdf")
        print("file path - \(output)")
        if ( FileManager.default.fileExists(atPath: output) ) {
            print("  -- file already exists --  ")
            //var deleted: Bool?
            do {
                
                try FileManager.default.removeItem(at: outputPDFPath!)
                print("deleted?")
            }
            catch let error as NSError {
                print(" !!!! error could not delete item \(error)")
            }
            //print("deleted -  \(deleted)")
        }
        /*
        if ( FileManager.default.fileExists(atPath: output) ) {
            print("  -- file already exists --  ")
            //var deleted: Bool?
            do {
                
                try FileManager.default.removeItem(atPath: output)
                print("deleted?")
            }
            catch let error as NSError {
                print(" !!!! error could not delete item \(error)")
            }
            //print("deleted -  \(deleted)")
        }*/
    }
    
    func clearInputs() {
        inputpath_field.stringValue = ""
        outputpath_field.stringValue = ""
        outputFilename.stringValue = ""
    }
}
