//
//  RegisterViewController.swift
//  Savvy
//
//  Created by Bhavya on 6/18/20.
//  Copyright © 2020 uiuc. All rights reserved.
//

import Foundation


import UIKit
import DLRadioButton
import SwiftSpinner
import Firebase
import FirebaseAuth
import FirebaseDatabase
import UserNotifications


class registerViewController: UIViewController {
    
    weak var checkButton: UIButton!
    @IBOutlet weak var clickLogin: UIButton!
   
    @objc var name:String = ""
    @objc var notificationGranted = false
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var emailText: UITextField!
    
    var minScale:CGFloat = 1.0
    var maxScale:CGFloat = 5.0
    var cumulativeScale:CGFloat = 1.0
    var isZoom = false
    
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @objc var ref: DatabaseReference!
    
    @objc func escapeEmailAddress(emailIn:String) ->String{
        // Replace '.' (not allowed in a Firebase key) with ',' (not allowed in an email address)
        var email = emailIn.lowercased()
        email = email.replacingOccurrences(of: ".", with: ",")
        return email;
    }
    
    @objc func createUser(email:String, password: String, firstname: String, lastname:String){
        Auth.auth().createUser(withEmail: email, password: password)
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                let userUID: String = (Auth.auth().currentUser?.uid)!
                var logging_parameters:[String:AnyObject] = ["id":userUID as AnyObject,"page":"register"as AnyObject,"action":"registered" as AnyObject,"json":[:] as AnyObject]
                self.remoteLogging(logging_parameters )
            }}
            
            
    }
    
    @IBAction func loginClicked(_ sender: Any){
        self.performSegue(withIdentifier: "registerToLogin", sender: sender)
    }
    
    
    @IBAction func signUpClicked(_ sender: Any) {
        
        let firstname = firstName.text;
        let lastname = lastName.text;
        let email = emailText.text;
        let password = passwordTextField.text;
        let confirm = confirmPasswordTextField.text;
        
        
        
        //name = firstname! + " " + lastname!
        name = lastname!
        
       
        if ( (firstname!.isEmpty || lastname!.isEmpty || email!.isEmpty || password!.isEmpty || confirm!.isEmpty) ) {
            self.displayMyAlertMessage("All fields are required");
            return;
        }
        
        Auth.auth().signIn(withEmail: email!, password: " ") { (user, error) in
            
            
            if (error?._code == 17009) {
                    self.displayMyAlertMessage("Email is already in use");
                    return;
                }
            else if(error?._code == 17008) {
                    self.displayMyAlertMessage("Please enter a valid email address")
                    return
                }
            else if(error?._code == 17011) {
                    //email doesn't exist
                    print("email dne - registering the user")
                    
                    let length = password!.count
                    
                    if (length < 8) {
                        self.displayMyAlertMessage("Password must be at least 8 characters")
                        return
                    }
                    
                    
                    if (password != confirm) {
                        //Display alert message
                        self.displayMyAlertMessage("Passwords do not match");
                        return;
                    }
                    
                   
                    self.createUser(email: email!, password: password!, firstname: firstname!, lastname: lastname!)
               
               
                self.performSegue(withIdentifier: "registerToHome", sender: sender)
                    }
                    
                else {
                    print("Another error \(error?._code)")
                    self.displayMyAlertMessage("There was an error with the registration. Please check the fields and resubmit.")
                    return
                }
            
        }}
    
    //dynamically shrinks font size of button label
    @objc func autoShrinkButtonLabel(btn:UIButton) {
        btn.titleLabel?.numberOfLines = 1
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.01
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        var pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView))
        var panGesture = UIPanGestureRecognizer(target: self, action: #selector(panPiece))
        
        view.isUserInteractionEnabled = true
        
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(panGesture)
//
        let backgroundColor = UIColor(red:0.37, green:0.69, blue:0.87, alpha:1.0)
        let grey1 = UIColor(red:0.70, green:0.70, blue:0.70, alpha:1.0)
        
        signUpButton.backgroundColor = backgroundColor
        ref = Database.database().reference()
        
        self.hideKeyboardWhenTappedAround()
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge])
        {
            (granted, error) in
            self.notificationGranted = granted
            print("---------------------",granted)
            
            if let error = error {
                print("granted, but Error in notification permission:\(error.localizedDescription)")
            }
        }
        
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
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
