//
//  noteDetailViewController.swift
//  Savvy
//
//  Created by Bhavya on 12/25/20.
//  Copyright © 2020 uiuc. All rights reserved.f
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
import MessageUI
import SwiftSpinner



class noteDetailViewController: UIViewController,  MFMessageComposeViewControllerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
  
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController!, didFinishWith result: MessageComposeResult) {
            //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
        }
    
    
    var note:[String:Any]? = nil
    @IBOutlet weak var noteTitle: UITextField!
    @IBOutlet weak var noteDate: UILabel!
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet weak var shareOverlayView: UIView!
    @IBOutlet weak var shareInnerView: UIView!
    @IBOutlet weak var fromNameField: UITextField!
    @IBOutlet weak var toNameField: UITextField!
    @IBOutlet weak var toEmailField: SearchTextField!
    
    @IBOutlet weak var shareOptionOverlayView: UIView!
    @IBOutlet weak var shareOptionInnerView: UIView!
    
    @IBOutlet weak var imageOverlayView: UIView!
    @IBOutlet weak var imageInnerView: UIView!
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    

    var img: Data!
   
    var minScale:CGFloat = 1.0
    var maxScale:CGFloat = 5.0
    var cumulativeScale:CGFloat = 1.0
    var isZoom = false
    var emails:[String] = []
    var sentTimestamp: String = ""
    var sentSymptom: String = ""
    var noteSym: String = ""
    
    var imagePicker: UIImagePickerController!
   
    
    
    let saveQueue = DispatchQueue(label: "saveQueue", attributes: .concurrent)
    
   
        // moc
        var managedContext : NSManagedObjectContext?
    

    @IBAction func takePhoto(_ sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
   
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("in")
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//                  print(image)
            setImageData(image: image)
          
        }
        self.dismiss(animated: true, completion: nil)
    }
       
        
        
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
    
   
    func setImageData(image:UIImage) {

          

    

               // create NSData from UIImage
        guard var imageData = image.jpegData(compressionQuality: 1.0) else {
                   // handle failed conversion
                   print("jpwg error")
                   return
               }
        var tmpImg = UIImage(data: imageData)
        if ((tmpImg!.size.width > imageView.frame.size.width) || (tmpImg!.size.height > imageView.frame.size.height)) {
            tmpImg =  resizeImageWith(newSize: imageView.frame.size, image: tmpImg!)
        }
        
        imageData = tmpImg!.jpegData(compressionQuality: 1.0)!

        self.img = imageData

           
       }
   
    
    func findPhoto(notes: [String:[Any]],json:[String:Any]) -> Optional<Any>{
       
        var foundPhoto = false
      
                guard let moc = self.managedContext else {
                    print("eerri",1)
                    return nil
                
                }
            
            var id = getId(notes: notes, json: json)
        
       
        print("eerri",2,id)
//            let fetchRequest =
//              NSFetchRequest<NSManagedObject>(entityName: "NotePhoto")
  
              
          
            do {
//          print(notes)
                
                for n in notes["results"] as! [Any]{
                    let nDict = n as! [String:AnyObject]
                    let nJson = convertToDictionary(text:nDict["eventJson"] as! String)
                  
                    if (  Int((nJson!)["id"] as! Int64) == id){
                        foundPhoto = true
                        var imgData: Optional<Any>
                        var imgS: String = nJson!["img"] as! String
                        if imgS != "nil"{
                        imgData = NSData(base64Encoded: imgS, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
                        }
                        else{
                            imgData = nil
                        }
                        return imgData
                    }
                }
            }
            catch let error as NSError {
      print("Could not fetch.")
      
    }
        return nil
    }
    func resizeImageWith(newSize: CGSize, image: UIImage) -> UIImage {
        
        var size = image.size

        let horizontalRatio = newSize.width / size.width
        let verticalRatio = newSize.height / size.height

        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
        }
    
    func showPhoto(imgData: Optional<Any>){
     
        if imgData != nil{
            
            var tmpImg = UIImage(data:imgData! as! Data)!
                
            if ((tmpImg.size.width > imageView.frame.size.width) || (tmpImg.size.height > imageView.frame.size.height)) {
           tmpImg =  resizeImageWith(newSize: imageView.frame.size, image: tmpImg)
            }
            imageView.image = tmpImg
            
            print(imageView.frame.size,tmpImg.size,imageView.image?.scale,imageOverlayView.frame.size,imageInnerView.frame.size,UIScreen.main.bounds.width,UIScreen.main.bounds.height,"size")
           

            SwiftSpinner.hide()
                            self.view.addSubview(self.imageOverlayView)
                           
                   
              
                      
        }
                

       else{
            var alertController: UIAlertController
            alertController = UIAlertController(title: "No Photo found", message: "Click on Take Photo to attach a photo to the note", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                   alertController.addAction(defaultAction)

                   self.present(alertController, animated: true, completion: nil)
        SwiftSpinner.hide()

        }
    }
    
    func loadPhoto(notes: [String:[Any]],json:[String:Any])  {
       
//                      print(notes,json)
        print("loading")
                       var imgData = findPhoto(notes: notes, json: json)
        
        showPhoto(imgData: imgData)
    }
    
    @IBAction func backImage(_ sender: UIButton){
        print("back")
        self.imageOverlayView.removeFromSuperview()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView))
        var panGesture = UIPanGestureRecognizer(target: self, action: #selector(panPiece))
        
        view.isUserInteractionEnabled = true
        
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(panGesture)
        guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return
      }
      
      
        self.managedContext =
        appDelegate.persistentContainer.viewContext
        
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
        
        imageOverlayView.frame.size.width = UIScreen.main.bounds.width
         imageOverlayView.frame.size.height = UIScreen.main.bounds.height
        
        shareOptionOverlayView.frame.size.width = UIScreen.main.bounds.width
         shareOptionOverlayView.frame.size.height = UIScreen.main.bounds.height
        
     
        imageView.contentMode = .scaleAspectFit
    
          let borderWidth = 0.5

          
          shareInnerView.layer.borderColor = UIColor.darkGray.cgColor
         shareInnerView.layer.borderWidth = CGFloat(borderWidth);
         
         shareInnerView.frame.size.width = UIScreen.main.bounds.width
          shareInnerView.frame.size.height = UIScreen.main.bounds.height
        
        imageInnerView.frame.size.width = UIScreen.main.bounds.width
        imageInnerView.frame.size.height = UIScreen.main.bounds.height
        
        imageView.frame.size.width = UIScreen.main.bounds.width
        imageView.frame.size.height = UIScreen.main.bounds.height 
         
         
          shareInnerView.layer.cornerRadius = 8.0
         
        
       imageInnerView.layer.borderColor = UIColor.darkGray.cgColor
        imageInnerView.layer.borderWidth = CGFloat(borderWidth);
       

       
       
        imageInnerView.layer.cornerRadius = 8.0
         
        
        shareOptionInnerView.layer.cornerRadius = 8.0
        

          
        shareOptionInnerView.layer.borderColor = UIColor.darkGray.cgColor
        shareOptionInnerView.layer.borderWidth = CGFloat(borderWidth);
         


        
    }
    
    func sendMsgHelp(notes: [String:[Any]],json:[String:Any]){
        // Configure the fields of the interface.
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        var imageData: Optional<Any>
        if self.img == nil{
        
       imageData = findPhoto(notes: notes, json: json)
        }
        else{
            imageData = self.img
        }

        composeVC.body = "Hello! Please see my note below" + "\n" + self.noteTitle.text! + "\n" + self.noteText.text!
        
        if imageData != nil{
            composeVC.addAttachmentData(imageData! as! Data, typeIdentifier: "image/jpeg", filename: "photo.jpg")
        }
        
       
        let uid = UserDefaults.standard.object(forKey: "userID")
        SwiftSpinner.hide()
        
        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
            var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"noteDetail"as AnyObject,"action":"shareNoteMsg" as AnyObject,"json":["title":self.noteTitle.text!,"timestamp":self.noteDate.text!,"text":self.noteText.text!] as AnyObject]
            self.remoteLogging(logging_parameters)
            
        }else {
            print("Can't send messages.")
        }
    }
    
    @IBAction func sendMsg(){
        SwiftSpinner.show("Please Wait")
        fetchRemoteNote(name: "Note", json: ["note":self.note  ,"sentTimestamp":sentTimestamp,"title":self.noteTitle.text, "text":self.noteText.text, "timestamp":self.noteDate.text], completion: sendMsgHelp(notes:json:))

        
    }
    
    
    
    @IBAction func sendEmail(notes: [String:[Any]],json:[String:Any]) {
        let fromUser = self.fromNameField.text
        let toUser = self.toNameField.text
        let toEmail = self.toEmailField.text
        if toEmail != nil{
        if !emails.contains(toEmail!){
            emails.append(toEmail!)
        }
        }
        
        var imageData: Optional<Any>
        if self.img == nil{
       imageData = findPhoto(notes: notes, json: json)
        }
        else{
            imageData = self.img
        }
            let smtpSession = MCOSMTPSession()

            smtpSession.hostname = "smtp.outlook.com"
            smtpSession.username = "savvy_health@outlook.com"
            smtpSession.password = "savvy2022"
       
            smtpSession.port = 587
        smtpSession.timeout = 150
        smtpSession.isCheckCertificateEnabled = false
        smtpSession.authType = MCOAuthType.saslLogin
            smtpSession.connectionType = MCOConnectionType.startTLS
            smtpSession.connectionLogger = {(connectionID, type, data) in
                if data != nil {
                    if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                        NSLog("Connectionlogger: ")
                    }
                }
            }
            

            let  builder = MCOMessageBuilder()
            //testing
            builder.header.to = [MCOAddress(displayName: toUser, mailbox: toEmail)]

            builder.header.from = MCOAddress(displayName: fromUser, mailbox: "savvy_health@outlook.com")
        builder.header.subject = "You've got a note from "+(fromUser ?? "")

            builder.htmlBody = "Hello!<br><br>Please see the note attached!"
        let attachment = MCOAttachment()
        attachment.filename = self.noteTitle.text
        attachment.data = self.noteText.text.data(using: .utf8)
        attachment.mimeType = "text/plain"
        
        if imageData != nil{
        var imgAttachment = MCOAttachment()
  
        imgAttachment.mimeType =  "image/jpeg"
        imgAttachment.filename = "photo.jpg"
            imgAttachment.data = imageData as? Data
       //Attach File
            builder.addAttachment(imgAttachment)
        }
    builder.addAttachment(attachment)
      

        let uid = UserDefaults.standard.object(forKey: "userID")
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"noteDetail"as AnyObject,"action":"shareNoteEmail" as AnyObject,"json":["title":self.noteTitle.text!,"timestamp":self.noteDate.text!,"text":self.noteText.text!,"email":toEmail] as AnyObject]
        self.remoteLogging(logging_parameters)

//            print(builder.data())

            let rfc822Data = builder.data()
       
        var alertController:UIAlertController!
            let sendOperation = smtpSession.sendOperation(with: rfc822Data!)
            sendOperation?.start { (error) -> Void in
                if (error != nil) {
                    print(error)
                    NSLog("Error sending email:")
                     alertController = UIAlertController(title: "Error", message: "Error sending email", preferredStyle: .alert)

                } else {
                    NSLog("Successfully sent email!")
                   alertController = UIAlertController(title: "Success!", message: "Email sent", preferredStyle: .alert)
                }
                SwiftSpinner.hide()
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                       alertController.addAction(defaultAction)

                       self.present(alertController, animated: true, completion: nil)

            }


           
           
        }
        
   
    
    override func viewWillDisappear(_ animated: Bool) {
    
      
    }
    
    @IBAction func back(_ sender: UIButton){
        self.shareOptionOverlayView.removeFromSuperview()

    }
    
    @IBAction func backButton(_ sender: UIButton) {
       goBack()
       }
    
    func getId(notes: [String:[Any]],json:[String:Any]) -> Int{
        var id = 0
        
      
        let innerNote: [String:Any]? = json["note"] as? [String:Any] ?? nil
//        print("inote",innerNote)
        if innerNote == nil{
            id = notes["results"]!.count
        }
        else{
            id = Int((innerNote!)["id"] as! Int64)
            
        
        }
        return id
    }
    
    func save(notes: [String:[Any]],json:[String:Any]){
        var alertController:UIAlertController!
        var symptom: String = ""
        var id = getId(notes: notes, json: json)
        
        let innerNote: [String:Any]? = json["note"] as? [String:Any] ?? nil
        var dateString: String = ""
        if json["sentTimestamp"] as! String == ""{
            let date = Date()
            let dateFormatter : DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, y HH:mm"
            
            if innerNote != nil {
            if innerNote!["symptom"] as! String != "" {
               dateString = innerNote!["timestamp"] as! String
                symptom = innerNote!["symptom"] as! String
            }
            
            else{
                dateString = dateFormatter.string(from: date)
            }
            }
            else{
                dateString = dateFormatter.string(from: date)
            }
     
        
      
        print(dateString)
        self.noteDate.text = dateString
        }
        else{
           
            dateString = json["sentTimestamp"] as! String
            symptom = self.sentSymptom
            print(2,dateString)
        }
        
       
            let uid = UserDefaults.standard.object(forKey: "userID")
        var imgD: Optional<Any> = self.img
            
        if self.img == nil{
            imgD = findPhoto(notes:notes,json:json)
        }
        var imgS: String
            
        if imgD != nil{
            imgS  = String(data:(imgD as! NSData).base64EncodedData(options: NSData.Base64EncodingOptions.endLineWithLineFeed),encoding: .utf8)!
        }
        else{
            imgS = "nil"
        }
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"noteDetail"as AnyObject,"action":"saveNote" as AnyObject,"json":["title":json["title"] as! String,"timestamp":dateString,"text":json["text"] as! String,"id":Int64(id),"symptom":symptom, "img":imgS]as AnyObject]
            self.remoteLogging(logging_parameters)
            
            alertController = UIAlertController(title: "Success!", message: "Note successfully saved", preferredStyle: .alert)
                                      
        self.note = ["title":json["title"] as! String,"timestamp":dateString,"text":json["text"] as! String,"id":Int64(id)]
        
            
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        SwiftSpinner.hide()
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func goBack(){
        if let nvc = navigationController {
            nvc.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func fetchRemoteNote(name: String,json: [String:Any],completion: @escaping ([String:[Any]],[String:Any])->()){
        let innerNote = json["note"] as? [String:Any] ?? nil
    
        if UserDefaults.standard.object(forKey: "userID") != nil{

            let uid = UserDefaults.standard.object(forKey: "userID")
            var parameters = ["id":uid as AnyObject,"page":"noteDetail" as AnyObject,"action":"saveNote" as AnyObject]
            remoteFetch(parameters, json: json, completion: completion)
        
        }
        else{
            let notes:[String:[Any]] = ["results":[]]
            completion(notes,json)
        }
    }
    
    
    @IBAction func viewPhoto(_ sender: UIButton){
        
        if self.img != nil{
            SwiftSpinner.show("Loading Photo")
            showPhoto(imgData: self.img)
            SwiftSpinner.hide()
        }
        else{
            SwiftSpinner.show("Loading Photo")
        fetchRemoteNote(name: "Note", json: ["note":self.note  ,"sentTimestamp":sentTimestamp,"title":self.noteTitle.text, "text":self.noteText.text, "timestamp":self.noteDate.text], completion: loadPhoto(notes:json:))
        }
    }
  
    
    @IBAction func saveButton(_ sender: UIButton){
        SwiftSpinner.show("Saving")
        fetchRemoteNote(name: "Note", json: ["note":self.note  ,"sentTimestamp":sentTimestamp,"title":self.noteTitle.text, "text":self.noteText.text, "timestamp":self.noteDate.text], completion: save(notes:json:))
    }
    
   @IBAction func emailSelected(){
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
    
    @IBAction func shareButton(_ sender: UIButton){
       
        self.view.addSubview(shareOptionOverlayView)
 
}
    
    @IBAction func cancelButton(_ sender: UIButton){
        self.shareOverlayView.removeFromSuperview()
    }
    
    @IBAction func sendButton(_ sender: UIButton){
        SwiftSpinner.show("Please Wait")
        fetchRemoteNote(name: "Note", json: ["note":self.note  ,"sentTimestamp":sentTimestamp,"title":self.noteTitle.text, "text":self.noteText.text, "timestamp":self.noteDate.text], completion: sendEmail(notes:json:))
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

