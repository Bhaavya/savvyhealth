//
//  LoginViewController.swift
//  Savvy
//
//  Created by Bhavya on 6/20/20.
//  Copyright © 2020 uiuc. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import SwiftSpinner
import UserNotifications





class loginViewController: UIViewController,UIScrollViewDelegate {
    
    @objc var progress = -1
    @objc let defaults = UserDefaults.standard
    
    var minScale:CGFloat = 1.0
    var maxScale:CGFloat = 5.0
    var cumulativeScale:CGFloat = 1.0
    var isZoom = false
 
    
    @IBOutlet weak var userEmailText: UITextField!
    
  @IBOutlet weak var userPasswordText: UITextField!
    
    
    @IBOutlet weak var login: UIButton!
    var prevTranslation:CGPoint!
    
    @objc func escapeEmailAddress(emailIn:String) ->String{
        // Replace '.' (not allowed in a Firebase key) with ',' (not allowed in an email address)
        var email = emailIn.lowercased()
        email = email.replacingOccurrences(of: ".", with: ",")
        return email;
    }
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.view
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
            var pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView))
            var panGesture = UIPanGestureRecognizer(target: self, action: #selector(panPiece))

            view.isUserInteractionEnabled = true

            view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(panGesture)

 
        
        self.hideKeyboardWhenTappedAround()
        
        let backgroundColor = UIColor(red:0.37, green:0.69, blue:0.87, alpha:1.0)
        
        login.backgroundColor = backgroundColor
        
       
        
        
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
    
 
    
    override func viewDidAppear(_ animated: Bool) {
    
        
        
      
        if UserDefaults.standard.object(forKey: "userID") != nil{
            let userUID = UserDefaults.standard.object(forKey: "userID")
            var logging_parameters:[String:AnyObject] = ["id":userUID as AnyObject,"page":"login"as AnyObject,"action":"logged in" as AnyObject,"json":[:] as AnyObject]
            self.remoteLogging(logging_parameters )
            print("fromNotl")
            if UserDefaults.standard.object(forKey: "fromNotification") != nil{
                let fromNot = defaults.bool(forKey: "fromNotification")
                print(fromNot)
                if fromNot == true{
                    
                 
                     
                        UserDefaults.standard.set(false,forKey: "fromNotification")
                    
                    self.performSegue(withIdentifier: "loginToTracking", sender: nil)
                    
                    
                }
                else{
                    self.performSegue(withIdentifier: "loginToHome", sender: nil)
                }
            }
            else{
            self.performSegue(withIdentifier: "loginToHome", sender: nil)
            }
  
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print(UserDefaults.standard.object(forKey: "userID"))
        if UserDefaults.standard.object(forKey: "userID") != nil{

        let uid = defaults.string(forKey: "userID")
            
        
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"login"as AnyObject,"action":"disappear" as AnyObject,"json":[:] as AnyObject]
        self.remoteLogging(logging_parameters )
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("in login",defaults.bool(forKey: "fromNotification"))
        if UserDefaults.standard.object(forKey: "userID") != nil{

        let uid = defaults.string(forKey: "userID")
        
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"login"as AnyObject,"action":"appear" as AnyObject,"json":[:] as AnyObject]
            
          
            
        self.remoteLogging(logging_parameters )
        }
        
        UNUserNotificationCenter.current()
          .removeAllPendingNotificationRequests()
      
        NotificationManager.shared.scheduleNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccountClicked(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil);
        self.performSegue(withIdentifier: "loginToRegister", sender: sender)
    }
    
    
    @IBAction func loginClicked(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)//clear user defaults
                                                   
        
        let userEmail = userEmailText.text;
        let userPassword = userPasswordText.text;
        
        
      
        

        Auth.auth().signIn(withEmail: userEmail!, password: userPassword!) { (user, error) in
//
            if error == nil {

                print("You have successfully logged in")
                defaults.set(userEmail, forKey: "email")

                let userUID: String = (Auth.auth().currentUser?.uid)!
//        let userUID = "wtxqFV5Visd6TQzDbEVEbpNSh9F2"
               
                defaults.set(userUID,forKey: "userID")
                
                let emailOut = self.escapeEmailAddress(emailIn: userEmail!)
                var logging_parameters:[String:AnyObject] = ["id":userUID as AnyObject,"page":"login"as AnyObject,"action":"logged in" as AnyObject,"json":[:] as AnyObject]
                self.remoteLogging(logging_parameters )
                
                if UserDefaults.standard.object(forKey: "fromNotification") != nil{
                    let fromNot = defaults.bool(forKey: "fromNotification")
                    if fromNot == true{
                       
                        UserDefaults.standard.set(false,forKey: "fromNotification")
                        print(UserDefaults.standard.object(forKey: "fromNotification") )
                        self.performSegue(withIdentifier: "loginToTracking", sender: nil)
                        
                    }
                    else{
                        self.performSegue(withIdentifier: "loginToHome", sender: nil)
                    }
                }
                else{
                self.performSegue(withIdentifier: "loginToHome", sender: nil)
                }
                       
                
                
            } else {
                print (error! as NSError,error!._code,user,userEmail!,userPassword!)

                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)

                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)

                self.present(alertController, animated: true, completion: nil)
                //self.displayMyAlertMessage("Login failed")

            }

            
        }

        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    if(segue.identifier == "loginToTracking") {

        let nextViewController = (segue.destination as! loggingViewController)
        nextViewController.type = 1
        }}
    
    
}
