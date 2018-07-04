//
//  ConvertViewController.swift
//  PDFConvert
//
//  Created by Steven Kanceruk on 12/1/17.
//  Copyright © 2017 steve. All rights reserved.
//

import Cocoa

struct ImageFileType {
    var uti: CFString
    var fileExtention: String
    
    // This list can include anything returned by CGImageDestinationCopyTypeIdentifiers()
    // I'm including only the popular formats here
    static let bmp = ImageFileType(uti: kUTTypeBMP, fileExtention: "bmp")
    static let gif = ImageFileType(uti: kUTTypeGIF, fileExtention: "gif")
    static let jpg = ImageFileType(uti: kUTTypeJPEG, fileExtention: "jpg")
    static let png = ImageFileType(uti: kUTTypePNG, fileExtention: "png")
    static let tiff = ImageFileType(uti: kUTTypeTIFF, fileExtention: "tiff")
}



class ConvertViewController: NSViewController {

    @IBOutlet weak var inputpath_field: NSTextField!
    @IBOutlet weak var outputpath_field: NSTextField!
    @IBOutlet weak var outputFilename: NSTextField!
    
    @IBOutlet weak var inputPathButton: NSButton!
    @IBOutlet weak var outputPathButton: NSButton!
    
    @IBOutlet weak var infoLabel: NSTextField!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var completeLabel: NSTextField!
    
    @IBOutlet weak var dropDown: NSPopUpButton!
    
    var inputPath  = String()
    var outputPath:String?
    
    // to center the text. yea this is bad but whatev
    var inputToExt = ["                                                                   JPG"  : ImageFileType.jpg,
                      "                                                                   PNG"  : ImageFileType.png,
                      "                                                                   TIFF" : ImageFileType.tiff,
                      "                                                                   BMP"  : ImageFileType.bmp,
                      "                                                                   GIF"  : ImageFileType.gif]
    
    var allTheThings = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allTheThings = ["                                                                   JPG",
                        "                                                                   PNG",
                        "                                                                   TIFF",
                        "                                                                   BMP",
                        "                                                                   GIF"]
        dropDown.removeAllItems()
        dropDown.addItems(withTitles: allTheThings)
        // Do view setup here.
        progressIndicator.isHidden = true
        let convertTo = allTheThings[dropDown.indexOfSelectedItem].trimmingCharacters(in: .whitespacesAndNewlines)
        completeLabel.stringValue = "You will be converting a PDF to a \(convertTo)"
    }
    
    @IBAction func browseFileInput(sender: AnyObject) {
        let dialog = NSOpenPanel();
        
        //completeLabel.isHidden = true
        
        dialog.title                   = "Choose a pdf file to split";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = false;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false // true;
        dialog.allowedFileTypes        = ["pdf"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                
                inputpath_field.stringValue = path
                inputPath = path
                
                //infoLabel.stringValue = "You will be spliting \(thePDFs.count) file"
                
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func browseFileOutput(sender: AnyObject) {
        let dialog = NSOpenPanel();
        
        ///completeLabel.isHidden = true
        
        dialog.title                   = "Choose a folder for the output";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseFiles = false
        //dialog.allowedFileTypes        = ["txt"];
        
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
    
    @IBAction func dropDownSelected(_ sender: Any) {
        let convertTo = allTheThings[dropDown.indexOfSelectedItem].trimmingCharacters(in: .whitespacesAndNewlines)
        completeLabel.stringValue = "You will be converting a PDF to a \(convertTo)"
    }
    
    @IBAction func convertButtonPressed(sender: AnyObject) {
       
        if (!checkInputs()) {
            return
        }
        
        progressIndicator.startAnimation(nil)
        progressIndicator.isHidden = false
        
        let pdfURLString = inputPath
        
        let pdfURL = URL(fileURLWithPath: pdfURLString)
        
        let cfPdfUrl = pdfURLString as CFString
        let pdfPath = CFBridgingRetain(pdfURLString) as! CFString
        let localUrl  = pdfURLString as! CFString
        let cfurl = CFURLCreateWithString(nil, cfPdfUrl, nil)
        let input_pdfDocumentRef = CFURLCreateWithFileSystemPath(nil, localUrl, CFURLPathStyle.cfurlposixPathStyle, false)
        // NSLog("\(pdfPath)")
        // let input_pdfReferencetwo = CGPDFDocument(cfurl!)
        let input_pdfReference = CGPDFDocument(input_pdfDocumentRef!)
        
        //let outputFileName = "yoyoyoyoyoy"
        //let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let documentsPath = NSURL(fileURLWithPath: outputPath!)
        let outputPDFPath = documentsPath as URL
            //documentsPath.appendingPathComponent( "" )
        
        let type = dropDown.selectedItem
        let fileType = inputToExt[(type?.title)!]
        
        do {
            try convertPDF(at: pdfURL, to: outputPDFPath, fileType:  fileType!) ///  ImageFileType.jpg)
        }
        catch {
            print("could not convert")
        }
        
        progressIndicator.stopAnimation(nil)
        progressIndicator.isHidden = true
        completeLabel.stringValue = "File Converted!"
        //isHidden = false
        
        clearInputs()
        
    }
    
    func convertPDF(at sourceURL: URL, to destinationURL: URL, fileType: ImageFileType, dpi: CGFloat = 200) throws -> [URL] {
        let pdfDocument = CGPDFDocument(sourceURL as CFURL)!
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.noneSkipLast.rawValue
        
        var urls = [URL](repeating: URL(fileURLWithPath : "/"), count: pdfDocument.numberOfPages)
        
        if (pdfDocument.numberOfPages <= 1) {
            DispatchQueue.concurrentPerform(iterations: pdfDocument.numberOfPages) { i in
                // Page number starts at 1, not 0
                let pdfPage = pdfDocument.page(at: i + 1)!
                
                let mediaBoxRect = pdfPage.getBoxRect(.mediaBox)
                let scale = dpi / 72.0
                let width = Int(mediaBoxRect.width * scale)
                let height = Int(mediaBoxRect.height * scale)
                
                let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo)!
                context.interpolationQuality = .high
                context.setFillColor(.white)
                context.fill(CGRect(x: 0, y: 0, width: width, height: height))
                context.scaleBy(x: scale, y: scale)
                context.drawPDFPage(pdfPage)
                
                let image = context.makeImage()!
                let imageName = sourceURL.deletingPathExtension().lastPathComponent
                let imageURL = destinationURL.appendingPathComponent("\(imageName).\(fileType.fileExtention)")
                
                let imageDestination = CGImageDestinationCreateWithURL(imageURL as CFURL, fileType.uti, 1, nil)!
                CGImageDestinationAddImage(imageDestination, image, nil)
                CGImageDestinationFinalize(imageDestination)
                
                urls[i] = imageURL
            }
        }
        else {
            DispatchQueue.concurrentPerform(iterations: pdfDocument.numberOfPages) { i in
                // Page number starts at 1, not 0
                let pdfPage = pdfDocument.page(at: i + 1)!
                
                let mediaBoxRect = pdfPage.getBoxRect(.mediaBox)
                let scale = dpi / 72.0
                let width = Int(mediaBoxRect.width * scale)
                let height = Int(mediaBoxRect.height * scale)
                
                let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo)!
                context.interpolationQuality = .high
                context.setFillColor(.white)
                context.fill(CGRect(x: 0, y: 0, width: width, height: height))
                context.scaleBy(x: scale, y: scale)
                context.drawPDFPage(pdfPage)
                
                let image = context.makeImage()!
                let imageName = sourceURL.deletingPathExtension().lastPathComponent
                let imageURL = destinationURL.appendingPathComponent("\(imageName)-\(i+1).\(fileType.fileExtention)")
                
                let imageDestination = CGImageDestinationCreateWithURL(imageURL as CFURL, fileType.uti, 1, nil)!
                CGImageDestinationAddImage(imageDestination, image, nil)
                CGImageDestinationFinalize(imageDestination)
                
                urls[i] = imageURL
            }
        }
        return urls
    }
    
    @IBAction func myPopUpButtonWasSelected(sender:AnyObject) {
        
        if let menuItem = sender as? NSMenuItem {
            //let type = menuItem
        }
    }
    
    func checkInputs() -> Bool{
        if (inputpath_field.stringValue == "" ||  outputpath_field.stringValue == "" ) {
            let alert = NSAlert()
            alert.messageText =  "Enter all values"
            alert.informativeText = "Please enter values for input path, output path and file format"
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
        //outputFilename.stringValue = ""
    }
    
}
