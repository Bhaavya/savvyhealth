//
//  PDFViewController.swift
//  Savvy
//
//  Created by Bhavya on 6/22/20.
//  Copyright © 2020 uiuc. All rights reserved.
//

import Foundation
import UIKit
import PDFKit
import MobileCoreServices


class ArticleViewController: UIViewController, UIDocumentPickerDelegate {
    
    @IBOutlet weak var pdfView:PDFView!
    var url: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let pdfDocument = PDFDocument(url: URL(string:url)!  ){
                pdfView.displayMode = .singlePageContinuous
                pdfView.autoScales = true
            
                pdfView.displayDirection = .vertical
                pdfView.document = pdfDocument
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    if(segue.identifier == "articleToSave") {

        let nextViewController = (segue.destination as! SaveViewController)
        nextViewController.articleURL = self.url
        }}
    
    @IBAction func closeClicked(){
        if let nvc = navigationController {
            nvc.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
   
    

    @IBAction func saveClicked(){
        self.performSegue(withIdentifier: "articleToSave", sender: self)
        
    }
}
