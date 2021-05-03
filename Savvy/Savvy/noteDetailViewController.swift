//
//  noteDetailViewController.swift
//  Savvy
//
//  Created by Bhavya on 12/25/20.
//  Copyright © 2020 uiuc. All rights reserved.
//

import Foundation
import PopupDialog
import UIKit
import NotificationCenter
import UserNotifications
import DropDown
import CoreData
import ContactsUI
import SearchTextField

class noteDetailViewController: UIViewController{
    
    var note:[String:Any]? = nil
    @IBOutlet weak var noteTitle: UITextField!
    @IBOutlet weak var noteDate: UILabel!
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet weak var shareOverlayView: UIView!
    @IBOutlet weak var shareInnerView: UIView!
    @IBOutlet weak var fromNameField: UITextField!
    @IBOutlet weak var toNameField: UITextField!
    @IBOutlet weak var toEmailField: SearchTextField!
    
   
    var minScale:CGFloat = 1.0
    var maxScale:CGFloat = 5.0
    var cumulativeScale:CGFloat = 1.0
    var isZoom = false
    var emails:[String] = []
    var sentTimestamp: String = ""
   
        
    @objc func pinchedView(_ gestureRecognizer : UIPinchGestureRecognizer) { guard gestureRecognizer.view != nil else { return }
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                //            print(gestureRecognizer.scale)
                self.cumulativeScale  *= gestureRecognizer.scale
                if (self.cumulativeScale >= self.minScale && self.cumulativeScale <= self.maxScale){
                    self.isZoom = true
                    //                 print("here",self.cumulativeScale,self.minScale)
                    gestureRecognizer.view?.transform = (gestureRecognizer.view?.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale))!
                var changeCenter = CGPoint(x:self.view.center.x,y:self.view.center.y)
                    
                var change = false
                if self.view.center.x > self.view.frame.width/2{
                    changeCenter.x = self.view.frame.width/2
                    
                    change = true
                }
                else if self.view.center.x+self.view.frame.width/2 < self.view.bounds.maxX{
                    changeCenter.x = self.view.bounds.maxX - self.view.frame.width/2
                    change = true
                    
                    }
                
                if self.view.center.y > self.view.frame.height/2{
                    changeCenter.y = self.view.frame.height/2
                    change = true
                }
                else if self.view.center.y+self.view.frame.height/2 < self.view.bounds.maxY{
                    changeCenter.y = self.view.bounds.maxY - self.view.frame.height/2
                    change = true
                }
                if change{
                    UIView.animate(withDuration: 0.3) {
                        self.view.center = changeCenter
                    }
                }
                
                
                gestureRecognizer.scale = 1.0
            }
            else{
                self.isZoom = false
                self.cumulativeScale = 1.0
                //                  print("here2",self.cumulativeScale,self.minScale)
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = .identity
                    self.view.center = CGPoint(x: self.view.frame.width*0.5, y: self.view.frame.height*0.5)
                }
            }}
    }
    
    var initialCenter = CGPoint()  // The initial center point of the view.
    @IBAction func panPiece(_ gestureRecognizer : UIPanGestureRecognizer) {
        guard gestureRecognizer.view != nil else {return}
        if self.isZoom{
            
            let piece = gestureRecognizer.view!
            // Get the changes in the X and Y directions relative to
            // the superview's coordinate space.
            let translation = gestureRecognizer.translation(in: piece.superview)
            
            if gestureRecognizer.state == .began {
                // Save the view's original position.
                self.initialCenter = piece.center
            }
            // Update the position for the .began, .changed, and .ended states
            if gestureRecognizer.state != .cancelled {
                // Add the X and Y translation to the view's original position.
                let newCenter = CGPoint(x: piece.center.x + translation.x, y: piece.center.y + translation.y)
                
                //             print(self.view.bounds, piece.center,translation,piece.center.x+translation.x,piece.center.y+translation.y,self.view.frame.width/2,self.view.frame.height/2,newCenter.y + piece.frame.height/2,newCenter.x + piece.frame.width/2)
                
                if newCenter.x <= piece.frame.width/2  && newCenter.x + piece.frame.width/2>=self.view.bounds.maxX && newCenter.y <= piece.frame.height/2 && newCenter.y + piece.frame.height/2>=self.view.bounds.maxY {
                    piece.center = newCenter
                }
                
                gestureRecognizer.setTranslation(.zero, in: piece.superview)
            }
            else {
                // On cancellation, return the piece to its original location.
                piece.center = initialCenter
            }
        }
    }
    
   
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView))
        var panGesture = UIPanGestureRecognizer(target: self, action: #selector(panPiece))
        
        view.isUserInteractionEnabled = true
        
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(panGesture)
        
    }
    
   
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, y HH:mm"
        var date: Date
        var dateString: String
        if sentTimestamp == ""{
            date = Date()
            dateString = dateFormatter.string(from: date)
        }
        else{
            dateString = sentTimestamp
        }
        
        print(dateString)
        if self.note != nil{
            self.noteTitle.text = self.note!["title"] as? String
            self.noteDate.text = self.note!["timestamp"] as? String
            self.noteText.text = self.note!["text"] as? String
        }
        else{
            
            self.noteTitle.text = "Title"
            self.noteDate.text = dateString
            self.noteText.text = ""
        }
        let emailRec = fetchRecords(name: "Contact")
        for em in emailRec as! [NSManagedObject]{
            self.emails.append((em.value(forKeyPath: "email") as? String)!)
                   }
        self.toEmailField.theme = SearchTextFieldTheme.darkTheme()
                self.toEmailField.theme.font = UIFont.systemFont(ofSize: 21)
        //        self.searchSym.theme.fontColor
                self.toEmailField.theme.bgColor = UIColor.lightGray
                
                self.toEmailField.theme.borderColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
                self.toEmailField.theme.separatorColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
                self.toEmailField.theme.cellHeight = 50

        self.toEmailField.filterStrings(self.emails)
                
        shareOverlayView.frame.size.width = UIScreen.main.bounds.width
         shareOverlayView.frame.size.height = UIScreen.main.bounds.height
        
        
        shareInnerView.layer.cornerRadius = 8.0
          let borderWidth = 0.5

          
          shareInnerView.layer.borderColor = UIColor.darkGray.cgColor
         shareInnerView.layer.borderWidth = CGFloat(borderWidth);
         
         shareInnerView.frame.size.width = UIScreen.main.bounds.width
          shareInnerView.frame.size.height = UIScreen.main.bounds.height
         
         
          shareInnerView.layer.cornerRadius = 8.0
           
           shareInnerView.layer.borderColor = UIColor.darkGray.cgColor
          shareInnerView.layer.borderWidth = CGFloat(borderWidth);
    }
    
    @objc func sendEmail() {
        let fromUser = self.fromNameField.text
        let toUser = self.toNameField.text
        let toEmail = self.toEmailField.text
        if toEmail != nil{
        if !emails.contains(toEmail!){
            emails.append(toEmail!)
        }
        }

            let smtpSession = MCOSMTPSession()

            smtpSession.hostname = "smtp.gmail.com"
            smtpSession.username = "savvyhealthapp@gmail.com"
            smtpSession.password = "Savvy2021"
            smtpSession.port = 465
            smtpSession.authType = MCOAuthType.saslPlain
            smtpSession.connectionType = MCOConnectionType.TLS
            smtpSession.connectionLogger = {(connectionID, type, data) in
                if data != nil {
                    if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                        NSLog("Connectionlogger: \(string)")
                    }
                }
            }
            

            let  builder = MCOMessageBuilder()
            //testing
            builder.header.to = [MCOAddress(displayName: toUser, mailbox: toEmail)]

            builder.header.from = MCOAddress(displayName: fromUser, mailbox: "Savvyhealthapp@gmail.com")
        builder.header.subject = "You've got a note from "+(fromUser ?? "")

            builder.htmlBody = "Hello!<br><br>Please see the note attached!"
        let attachment = MCOAttachment()
        attachment.filename = self.noteTitle.text
        attachment.data = self.noteText.text.data(using: .utf8)
        attachment.mimeType = "text/plain"
       //Attach File
    builder.addAttachment(attachment)

        let uid = UserDefaults.standard.object(forKey: "userID")
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"noteDetail"as AnyObject,"action":"shareNote" as AnyObject,"json":["title":self.noteTitle.text!,"timestamp":self.noteDate.text!,"text":self.noteText.text!,"email":toEmail] as AnyObject]
        self.remoteLogging(logging_parameters)

            print(builder.data())

            let rfc822Data = builder.data()
        var alertController:UIAlertController!
            let sendOperation = smtpSession.sendOperation(with: rfc822Data!)
            sendOperation?.start { (error) -> Void in
                if (error != nil) {
                    NSLog("Error sending email: \(error)")
                     alertController = UIAlertController(title: "Error", message: "Error sending email", preferredStyle: .alert)

                } else {
                    NSLog("Successfully sent email!")
                   alertController = UIAlertController(title: "Success!", message: "Email sent", preferredStyle: .alert)
                }
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                       alertController.addAction(defaultAction)

                       self.present(alertController, animated: true, completion: nil)

            }


           
           
        }
        
   
    
    override func viewWillDisappear(_ animated: Bool) {
    sentTimestamp = ""
        note = nil
      
    }
    
    @IBAction func backButton(_ sender: UIButton) {
       if let nvc = navigationController {
           nvc.popViewController(animated: true)
       } else {
           dismiss(animated: true, completion: nil)
       }
       }
    
    func save(notes: [String:[Any]],json:[String:Any]){
        var id = 0
        var alertController:UIAlertController!
        let innerNote: [String:Any]? = json["note"] as? [String:Any] ?? nil
//        print("inote",innerNote)
        if innerNote == nil{
            id = notes["results"]!.count
        }
        else{
            id = Int((innerNote!)["id"] as! Int64)
        
        }
        var dateString: String = ""
        if json["sentTimestamp"] as! String == ""{
        let date = Date()
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, y HH:mm"
       dateString = dateFormatter.string(from: date)
        print(dateString)
        self.noteDate.text = dateString
        }
        else{
            dateString = json["sentTimestamp"] as! String
        }
        
       
            let uid = UserDefaults.standard.object(forKey: "userID")
            
            var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"noteDetail"as AnyObject,"action":"saveNote" as AnyObject,"json":["title":json["title"] as! String,"timestamp":dateString,"text":json["text"] as! String,"id":Int64(id)] as AnyObject]
            self.remoteLogging(logging_parameters)
            
            alertController = UIAlertController(title: "Success!", message: "Note successfully saved", preferredStyle: .alert)
                                      
        self.note = ["title":json["title"] as! String,"timestamp":dateString,"text":json["text"] as! String,"id":Int64(id)]
        
            
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func fetchRemoteNote(name: String,json: [String:Any],completion: @escaping ([String:[Any]],[String:Any])->()){
        let innerNote = json["note"] as? [String:Any] ?? nil
        if innerNote == nil{
        if UserDefaults.standard.object(forKey: "userID") != nil{

            let uid = UserDefaults.standard.object(forKey: "userID")
            var parameters = ["id":uid as AnyObject,"page":"noteDetail" as AnyObject,"action":"saveNote" as AnyObject]
            remoteFetch(parameters, json: json, completion: completion)
        }
        }
        else{
            let notes:[String:[Any]] = [:]
            completion(notes,json)
        }
    }
    
  
    
    @IBAction func saveButton(_ sender: UIButton){
        
        fetchRemoteNote(name: "Note", json: ["note":self.note  ,"sentTimestamp":sentTimestamp,"title":self.noteTitle.text, "text":self.noteText.text, "timestamp":self.noteDate.text], completion: save(notes:json:))
    }
    
    @IBAction func shareButton(_ sender: UIButton){
       let contactStore = CNContactStore()
       var contacts = [CNContact]()
        
       let keys = [
               CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                       CNContactPhoneNumbersKey,
                       CNContactEmailAddressesKey
               ] as [Any]
       let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
       do {
           try contactStore.enumerateContacts(with: request){
                   (contact, stop) in
               // Array containing all unified contacts from everywhere
               contacts.append(contact)
               for email in contact.emailAddresses {
                if let em = email.value as? String{
                    if !self.emails.contains(em){
                    self.emails.append(em)
                    }
                   }
               }
           }
         self.toEmailField.filterStrings(self.emails)
       } catch {
           print("unable to fetch contacts")
       }
        self.fromNameField.text = ""
        self.toNameField.text = ""
        self.toEmailField.text = ""
        
        self.view.addSubview(shareOverlayView)
        
    
    
   
}
    
    @IBAction func cancelButton(_ sender: UIButton){
        self.shareOverlayView.removeFromSuperview()
    }
    
    @IBAction func sendButton(_ sender: UIButton){
        sendEmail()
        saveContact(emails: self.emails, ename: "Contact")
        self.shareOverlayView.removeFromSuperview()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "userID") != nil{

        let uid = UserDefaults.standard.object(forKey: "userID")
        
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"noteDetail"as AnyObject,"action":"appear" as AnyObject,"json":[:] as AnyObject]
        self.remoteLogging(logging_parameters )
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "userID") != nil{

        let uid = UserDefaults.standard.object(forKey: "userID")
        
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"noteDetail"as AnyObject,"action":"disappear" as AnyObject,"json":[:] as AnyObject]
        self.remoteLogging(logging_parameters )
        }
    }
  
}

