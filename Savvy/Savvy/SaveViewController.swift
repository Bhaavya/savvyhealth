//
//  saveViewController.swift
//  Savvy
//
//  Created by Bhavya on 6/24/20.
//  Copyright © 2020 uiuc. All rights reserved.
//

import Foundation
import UIKit
import PDFKit
import MobileCoreServices

class DirCell: UITableViewCell{
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var dirName: UILabel!
    @IBOutlet weak var spaceLabel: UILabel!
    var dirURL:URL!
}


class SaveViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    let filemgr = FileManager.default
    @objc let defaults = UserDefaults.standard
    var directoryContents:[URL] = [FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]]
    var directoryNames:[String] = ["Documents"]
    var depths:[Int] = [0]
    var articleURL: String!
    var minScale:CGFloat = 1.0
    var maxScale:CGFloat = 5.0
    var cumulativeScale:CGFloat = 1.0
    var isZoom = false
    var isExpanded:[Bool] = [true]
    
    
    
    @IBOutlet weak var enterNameView: UIView!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var tableHeight:NSLayoutConstraint!
    
    @IBOutlet weak var innerView:UIView!
    
    var selectedDir:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    @IBOutlet weak var listTableView: UITableView!
    
    func getSubDirectories(url: URL) -> [URL]{
        var subdir:[URL] = []
    do{
       let files = try (FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []))
        for f in files{
            if f.hasDirectoryPath
            {
                subdir.append(f)
            }
        }
        }catch let error as NSError {
        print(error.localizedDescription)
        }
        return subdir
    }
    

   
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.directoryContents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
             let cell = self.listTableView.dequeueReusableCell(withIdentifier: "dirCell", for: indexPath) as! DirCell
      
        cell.dirName.text = self.directoryNames[indexPath.row]
        var tabs = ""
        for _ in 0..<self.depths[indexPath.row]{
                   tabs += "\t"
                    
        }
        cell.spaceLabel.text = tabs
         cell.dirName.numberOfLines = 0
         cell.dirName.lineBreakMode = .byWordWrapping
        cell.dirURL = self.directoryContents[indexPath.row]
       
        var numSubDir = (getSubDirectories(url: cell.dirURL)).count
        
        
        if numSubDir > 0
        {
            
            if self.isExpanded[indexPath.row]{
                cell.arrowButton.setTitle("▼", for: .normal)
            }
            else{
                cell.arrowButton.setTitle("▶", for: .normal)
            }
            
            cell.arrowButton.tag = indexPath.row
            cell.arrowButton.isHidden = false
            
        }
        else{
            cell.arrowButton.isHidden = true
        }
        
               
         return cell
        
         
     }
     
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedDir = self.directoryContents[indexPath.row]
        print("in select",indexPath.row,indexPath.section)
     }
    
    
    
    func addOrexpandDir(dirIdx: Int,addedDir: Optional<Any>){
        var subDirs = getSubDirectories(url: self.directoryContents[dirIdx])
        
        self.isExpanded[dirIdx] = true
        var insertIndex = dirIdx+1
        let depth = self.depths[dirIdx] + 1
        if addedDir != nil{
            let addedDirIdx = subDirs.firstIndex(of: addedDir as! URL)
            subDirs.remove(at: addedDirIdx!)
            subDirs.insert(addedDir as! URL, at: 0)
            
        }
        
        for dir in subDirs{
            if !self.directoryContents.contains(dir){
                   self.directoryContents.insert(dir, at: insertIndex)
                   self.depths.insert(depth, at:insertIndex)
                   self.directoryNames.insert( FileManager.default.displayName(atPath:  dir.path),at:insertIndex)
                   self.isExpanded.insert(false, at: insertIndex)
                   insertIndex += 1
            }
        }
            
        if addedDir != nil{
            self.selectedDir = addedDir as! URL
        }
        else{
          self.selectedDir = self.directoryContents[dirIdx]
        }
        
         self.adjustHeight()
        
    }
        
        
    func adjustHeight(){
        print(self.directoryContents.count)
        var ht = self.directoryContents.count * 45
        if ht>500{
            ht = 500
        }
        if ht<120{
            ht = 120
        }
        self.tableHeight.constant = CGFloat(ht)
        
    }
        
    func recursiveCollapse(dirIdx: Int){
        if self.isExpanded[dirIdx]{
        self.isExpanded[dirIdx] = false
        let subDirs = getSubDirectories(url: self.directoryContents[dirIdx])
        for  dir in subDirs{
            print(dir,self.directoryContents)
            recursiveCollapse(dirIdx: self.directoryContents.firstIndex(of:dir)!)
            let remIdx = self.directoryContents.firstIndex(of:dir)!
            self.directoryContents.remove(at: remIdx)
            self.depths.remove(at:remIdx)
            self.directoryNames.remove(at:remIdx)
            self.isExpanded.remove(at:remIdx)
            
            
        }
        }
        
        
    }
    
    @IBAction func clickArrow(_ sender: UIButton){
       
        if !self.isExpanded[sender.tag]{
            
             addOrexpandDir(dirIdx: sender.tag,addedDir: nil)
        }
        else{
            recursiveCollapse(dirIdx: sender.tag)
        adjustHeight()
            }
        
        self.listTableView.reloadData()
        self.view.layoutIfNeeded()
        self.listTableView.selectRow(at: IndexPath(row: sender.tag,section: 0),animated: false, scrollPosition: .none)
    }
    
    func savePdf( saveDir: URL, docName: String) -> Bool{
        
            //The URL to Save
            let pdfURL = URL(string: self.articleURL)
            //get the data
            let data = PDFDocument(url: pdfURL!)
            let docURL = saveDir.appendingPathComponent(docName)
            //Lastly, write your file to the disk.
        return (data?.write(to: docURL))!
        
    }
    
    
    @IBAction func clickSelect(_ sender: UIButton){
        self.nameLabel.text = self.nameLabel.text?.replacingOccurrences(of: "Folder", with: "File")
        self.nameField.text = ""
        self.saveButton.setTitle("Save", for: .normal)
        self.saveButton.tag = 0
        self.cancelButton.tag = 0
        self.view.addSubview(enterNameView)
        self.enterNameView.layoutIfNeeded()
        self.view.layoutIfNeeded()
        
        
    }
    
    @IBAction func clickSave(_ sender: UIButton ){
       
        if sender.tag == 0{
            let nameText = self.nameField!.text
            var alertController:UIAlertController!
            
        if  (nameText != nil && nameText != ""){
            var docName = ""
            if String(nameText!.suffix(4)) != ".pdf"{
                docName = (nameText!) + ".pdf"
            }
            else{
                docName = nameText!
            }
            if !FileManager.default.fileExists(atPath:  self.selectedDir.appendingPathComponent(docName).path)
            {
            if savePdf(saveDir: self.selectedDir, docName: docName){
                 alertController = UIAlertController(title: "Success!", message: "File successfully saved", preferredStyle: .alert)
                           
                self.enterNameView.removeFromSuperview()}
            else{
                alertController = UIAlertController(title: "Error", message: "Error saving file", preferredStyle: .alert)
                          
            }
            }
            else{
                print(self.selectedDir,docName)
                 alertController = UIAlertController(title: "Error", message: "The name is already taken. Please use another name.", preferredStyle: .alert)
            }
        }
        
        else{
           alertController = UIAlertController(title: "Error", message: "Must enter file name", preferredStyle: .alert)
            
    }
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        else{
            
            
            if  (self.nameField.text ?? nil != nil && self.nameField.text ?? nil != ""){
                let retVal = createDir(createDir: self.selectedDir.absoluteString, dirName: self.nameField.text!)
                if retVal == "Nil"{
                    let selectedDirIdx = self.directoryContents.firstIndex(of: self.selectedDir)!
                    
                    addOrexpandDir(dirIdx: selectedDirIdx, addedDir: self.selectedDir.appendingPathComponent(self.nameField.text!))
                    self.listTableView.reloadData()
                    self.view.layoutIfNeeded()
                    self.enterNameView.removeFromSuperview()
                     self.listTableView.selectRow(at: IndexPath(row: selectedDirIdx + 1,section: 0), animated: false, scrollPosition: .none)
                    
                }
                else{
                     let alertController = UIAlertController(title: "Error", message: retVal, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                }
                else{
                     let alertController = UIAlertController(title: "Error", message: "Must enter folder name", preferredStyle: .alert)
                               let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                               alertController.addAction(defaultAction)
                               
                               self.present(alertController, animated: true, completion: nil)
            }
        }
    }
        
        
    @IBAction func clickCancel(_ sender: UIButton){
        self.enterNameView.removeFromSuperview()
        }
    
        
    func createDir(createDir: String, dirName: String) -> String{
        
        var createError:String = ""
        let docURL = URL(string: createDir)!
               let dataPath = docURL.appendingPathComponent(dirName)
       
        
               if !FileManager.default.fileExists(atPath: dataPath.path) {
                   do {
                       try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
                    createError = "Nil"
                   } catch {
                      
                    createError = error.localizedDescription
                    
                   }
               }
               else{
                createError = "The name is already taken. Please use another name."
        }
        return createError
    }
    
    @IBAction func clickCreate(_ sender: UIButton){
        self.nameLabel.text = self.nameLabel.text?.replacingOccurrences(of: "File", with: "Folder")
        self.nameField.text = ""
        self.saveButton.setTitle("Create", for: .normal)
        self.saveButton.tag = 1
        self.cancelButton.tag = 1
        self.view.addSubview(enterNameView)
         self.enterNameView.layoutIfNeeded()
        self.view.layoutIfNeeded()
           
       }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
            var pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView))
            var panGesture = UIPanGestureRecognizer(target: self, action: #selector(panPiece))

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(panGesture)

        self.hideKeyboardWhenTappedAround()
        enterNameView.frame.size.width = UIScreen.main.bounds.width
        
        enterNameView.frame.size.height = UIScreen.main.bounds.height
        innerView.layer.cornerRadius = 8.0
        let borderWidth = 0.5

        
        innerView.layer.borderColor = UIColor.darkGray.cgColor
       innerView.layer.borderWidth = CGFloat(borderWidth);
        
               
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
       
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
    let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)
       let myDocumentsDirectory = dirPaths[0]
           var subDirContents:[URL] = getSubDirectories(url: myDocumentsDirectory)
           
           
           for dir in subDirContents{
               self.directoryNames.append(FileManager.default.displayName(atPath:  dir.path))
               self.depths.append(1)
               self.isExpanded.append(false)
            self.tableHeight.constant += 45
           }
  
           self.directoryContents += subDirContents
        
        if self.tableHeight.constant > 500{
             self.tableHeight.constant = 500
   
        }
        self.listTableView.selectRow(at: IndexPath(row: 0,section: 0),animated: false, scrollPosition: .none)
    }
    @IBAction func backClicked(_ sender: UIButton){
        if let nvc = navigationController {
                nvc.popViewController(animated: true)
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}
}
    
    
