//
//  DocViewController.swift
//  Savvy
//
//  Created by Bhavya on 8/15/21.
//  Copyright © 2021 uiuc. All rights reserved.
//

import Foundation
import CoreData
import PopupDialog
import UIKit
import NotificationCenter
import UserNotifications
import DropDown
import SearchTextField
import DLRadioButton
import PhoneNumberKit

class docCell: UITableViewCell {
        
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowLabel: UILabel!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}

class docViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var srchBar: UISearchBar!
    @IBOutlet weak var tbl: UITableView!
    
    @IBOutlet weak var editOverlayView: UIView!
    
    @IBOutlet weak var editInnerView: UIView!
    
    @IBOutlet weak var showOverlayView: UIView!
    
    @IBOutlet weak var showInnerView: UIScrollView!
    
    @IBOutlet weak var confirmOverlayView: UIView!
    
    @IBOutlet weak var confirmInnerView: UIView!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: PhoneNumberTextField!
    @IBOutlet weak var addField: UITextField!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addLabel : UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var delBtn: UIButton!
    
    @IBOutlet weak var yesBtn: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    var maxId: Int = 0
    
    var fromEdit: Bool = false
    
    var docs: [[String: Any]] = []
    var filteredDocs: [[String: Any]] = []
        
        
    var minScale:CGFloat = 1.0
    var maxScale:CGFloat = 5.0
    var cumulativeScale:CGFloat = 1.0
    var isZoom = false
    
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

     
     
        filteredDocs = searchText.isEmpty ? docs : docs.filter({(dataString: [String:Any]) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return (dataString["name"] as! String).range(of: searchText, options: .caseInsensitive) != nil
        })

        tbl.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.nameLabel.text = (self.filteredDocs[indexPath.row]["name"] as! String)
        self.phoneLabel.text = (self.filteredDocs[indexPath.row]["phone"] as! String)
        self.emailLabel.text = (self.filteredDocs[indexPath.row]["email"] as! String)
        self.addLabel.text = (self.filteredDocs[indexPath.row]["address"] as! String)

        self.editBtn.tag = indexPath.row
        self.delBtn.tag = indexPath.row
        
        
        self.view.addSubview(self.showOverlayView)
    }
    
    @IBAction func showEdit(_ sender: UIButton){
        self.nameField.text = (self.filteredDocs[sender.tag]["name"] as! String)
        self.phoneField.text = (self.filteredDocs[sender.tag]["phone"] as! String)
        self.emailField.text = (self.filteredDocs[sender.tag]["email"] as! String)
        self.addField.text = (self.filteredDocs[sender.tag]["address"] as! String)
        self.showOverlayView.removeFromSuperview()
        self.fromEdit = true
        self.saveBtn.tag = sender.tag
        self.view.addSubview(self.editOverlayView)
    }
    
    @IBAction func delDoc(_ sender: UIButton){
        self.showOverlayView.removeFromSuperview()
        self.yesBtn.tag = sender.tag
        self.view.addSubview(self.confirmOverlayView)
    }
    
    @IBAction func confirmDel(_ sender: UIButton){
        self.confirmOverlayView.removeFromSuperview()
        
        var did = self.filteredDocs[sender.tag]["did"] as! String
        
        let uid = UserDefaults.standard.object(forKey: "userID")
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"doc" as AnyObject,"action":"delDoc" as AnyObject,"json": ["did":did] as AnyObject]
            self.remoteLogging(logging_parameters )
        
        self.docs = self.docs.filter({(dataString: [String:Any]) -> Bool in
           // If dataItem matches the searchText, return true to include it
                                        return !(did  == dataString["did"] as? String ?? "")})
        
        self.filteredDocs = self.filteredDocs.filter({(dataString: [String:Any]) -> Bool in
                                                // If dataItem matches the searchText, return true to include it
                                                                             return !(did as! String == dataString["did"] as? String ?? "")})
        
        self.tbl.reloadData()
        
        
    }
    
    @IBAction func cancelDel(_ sender: UIButton){
        self.confirmOverlayView.removeFromSuperview()
    }
    
    @IBAction func backShow(_ sender: UIButton){
        self.showOverlayView.removeFromSuperview()
    }
    
    
    
    func showDialog(msg: String){
        let containerAppearance = PopupDialogContainerView.appearance()
    
        containerAppearance.backgroundColor = UIColor.white
        var dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.messageColor = UIColor.black
        dialogAppearance.titleFont = UIFont.boldSystemFont(ofSize: 16)
        dialogAppearance.titleColor = UIColor.black
        let popup = PopupDialog(title: "Error", message: msg)
        let buttonOne = DefaultButton(title: "OK", dismissOnTap: true) {
        }
        
        popup.addButtons([buttonOne])
        self.present(popup, animated: true, completion: nil)
    }
    
    @IBAction func saveDoc(_ sender: UIButton){
        var name = self.nameField.text
        if name == nil || name == ""{
            showDialog(msg: "Please enter doctor's name")
            return
        }
        
   
       
        for doc in self.docs{
            
            if (doc["name"] as! String).lowercased().trimmingCharacters(in: .whitespaces) == name?.lowercased().trimmingCharacters(in: .whitespaces){
                if self.fromEdit{
                    if doc["did"] as! String != filteredDocs[sender.tag]["did"] as! String{
                        showDialog(msg: "A doctor with the same name already exists. Please enter a different name.")
                        
                        return
                    }
                }
                else{
                showDialog(msg: "A doctor with the same name already exists. Please enter a different name.")
                return
                }
                
            
        }
        }
        
            var phone: String = self.phoneField.text ?? " "
            var email: String = self.emailField.text ?? " "
            var address: String = self.addField.text ?? " "
        
        
        var did = String(maxId+1)
        
        if self.fromEdit{
            did = self.filteredDocs[sender.tag]["did"] as! String
            
            self.docs = self.docs.filter({(dataString: [String:Any]) -> Bool in
               // If dataItem matches the searchText, return true to include it
                                            return !(did  == dataString["did"] as? String ?? "")})
            
            self.filteredDocs = self.filteredDocs.filter({(dataString: [String:Any]) -> Bool in
                                                    // If dataItem matches the searchText, return true to include it
                                                                                 return !(did as! String == dataString["did"] as? String ?? "")})
            
        }
        else{
            maxId = maxId + 1
        }
        
        var docDict = ["did":did,"name":name, "phone": phone, "email": email, "address": address]
        
        let uid = UserDefaults.standard.object(forKey: "userID")
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"doc" as AnyObject,"action":"createDoc" as AnyObject,"json": docDict as AnyObject]
            self.remoteLogging(logging_parameters )
        
        
        
        docs.insert(docDict,at:0)
        filteredDocs.insert(docDict,at:0)
        self.fromEdit = false
        self.editOverlayView.removeFromSuperview()
        self.tbl.reloadData()
            
        
    }
    
    @IBAction func cancelEdit(_ sender: UIButton){
        self.fromEdit = false
        self.editOverlayView.removeFromSuperview()
    }
    
    func fetchRemoteDoc1(json: [String:Any],completion: @escaping ([String:[Any]],[String:Any])->()){
       
        if UserDefaults.standard.object(forKey: "userID") != nil{

            let uid = UserDefaults.standard.object(forKey: "userID")
            var parameters = ["id":uid as AnyObject,"page":"doc" as AnyObject,"action":"createDoc" as AnyObject]
            remoteFetch(parameters, json: json, completion: completion)
        }
        }
    
    func fetchRemoteDoc2(json: [String:Any],completion: @escaping ([String:[Any]],[String:Any])->()){
       
        if UserDefaults.standard.object(forKey: "userID") != nil{

            let uid = UserDefaults.standard.object(forKey: "userID")
            var parameters = ["id":uid as AnyObject,"page":"doc" as AnyObject,"action":"delDoc" as AnyObject]
            remoteFetch(parameters, json: json, completion: completion)
        }
        }
        
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return self.filteredDocs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tbl.dequeueReusableCell(withIdentifier: "docCell", for: indexPath) as! docCell
        
       

        cell.titleLabel!.text = self.filteredDocs[indexPath.row]["name"] as? String
    
    cell.titleLabel?.numberOfLines = 0
    cell.titleLabel?.lineBreakMode = .byWordWrapping
  
    return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
   
   
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "userID") != nil{

        let uid = UserDefaults.standard.object(forKey: "userID")
        
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"doc"as AnyObject,"action":"appear" as AnyObject,"json":[:] as AnyObject]
        self.remoteLogging(logging_parameters )
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "userID") != nil{

        let uid = UserDefaults.standard.object(forKey: "userID")
        
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"doc"as AnyObject,"action":"disappear" as AnyObject,"json":[:] as AnyObject]
        self.remoteLogging(logging_parameters )
        }
    }
   
    func setView(overlayView: UIView, innerView: UIView){
    
    overlayView.frame.size.width = UIScreen.main.bounds.width
    overlayView.frame.size.height = UIScreen.main.bounds.height
    
    overlayView.frame.size.width = UIScreen.main.bounds.width
    overlayView.frame.size.height = UIScreen.main.bounds.height
    
    
    innerView.layer.cornerRadius = 8.0
      let borderWidth = 0.5

      
     innerView.layer.borderColor = UIColor.darkGray.cgColor
     innerView.layer.borderWidth = CGFloat(borderWidth);
     
    
     
      innerView.layer.cornerRadius = 8.0
       
innerView.layer.borderColor = UIColor.darkGray.cgColor
      innerView.layer.borderWidth = CGFloat(borderWidth);
    
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        fetchRemoteDoc1(json: [:],completion: setDocs1(resdocs:filter_json:))
        setView(overlayView: editOverlayView , innerView: editInnerView)
        setView(overlayView: showOverlayView , innerView: showInnerView)
        setView(overlayView: confirmOverlayView , innerView: confirmInnerView)
    
    }
    
    func setDocs1(resdocs: [String:[Any]],filter_json:[String:Any]){
        let sortedResDocs = (resdocs["results"]! as! [[String:AnyObject]]).sorted { ($0["ts"] as! NSNumber).intValue > ($1["ts"] as! NSNumber).intValue}
        var added: [String] = []
        for doc in sortedResDocs{
            let docJson = convertToDictionary(text:doc["eventJson"] as! String)
            if !added.contains(docJson!["did"] as! String){
            self.docs.append(docJson!)
            self.filteredDocs.append(docJson!)
            added.append(docJson!["did"] as! String)
            }
            if Int(docJson!["did"] as! String)! > self.maxId{
                self.maxId = Int(docJson!["did"] as! String)!
            }
            }
        fetchRemoteDoc2(json: [:],completion: setDocs2(resdocs:filter_json:))
       
        }
    
    func setDocs2(resdocs: [String:[Any]],filter_json:[String:Any]){
    
        var delIds: [String] = []
        for doc in resdocs["results"]! as [Any]{
            let docDict = doc as! [String:AnyObject]
            let docJson = convertToDictionary(text:docDict["eventJson"] as! String)
            delIds.append(docJson!["did"] as! String)
            }
        
        self.docs = self.docs.filter({(dataString: [String:Any]) -> Bool in
           // If dataItem matches the searchText, return true to include it
        return !delIds.contains(dataString["did"] as? String ?? "")
            
            
        
        })
        
        self.filteredDocs = self.filteredDocs.filter({(dataString: [String:Any]) -> Bool in
           // If dataItem matches the searchText, return true to include it
        return !delIds.contains(dataString["did"] as? String ?? "")
        })
       self.tbl.reloadData()
    }
    
    @IBAction func addDoc(_ sender: UIButton){
        self.nameField.text = ""
        self.phoneField.text = ""
        self.addField.text = ""
        self.emailField.text = ""
        self.view.addSubview(editOverlayView)
    }
    
    
    @IBAction func backClicked(_ sender: UIButton){
        if let nvc = navigationController {
            nvc.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
     
    
    
}

