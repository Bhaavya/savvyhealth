//
//  resourcesViewController.swift
//  Savvy
//
//  Created by Bhavya on 6/25/20.
//  Copyright © 2020 uiuc. All rights reserved.
//

import Foundation
import UIKit
import PDFKit



class FileCell: UITableViewCell{
    
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var spaceLabel: UILabel!
    var fileURL:URL!
}


class ResourcesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    let filemgr = FileManager.default
    @objc let defaults = UserDefaults.standard
    var directoryContents:[URL] = [FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]]
    var fileNames:[String] = ["Documents"]
    var depths:[Int] = [0]
    var minScale:CGFloat = 1.0
    var maxScale:CGFloat = 5.0
    var cumulativeScale:CGFloat = 1.0
    var isZoom = false
    var isExpanded:[Bool] = [true]
    
    @IBOutlet weak var pdfView: UIView!
    @IBOutlet weak var innerView: PDFView!
    
    @IBOutlet weak var tableHeight:NSLayoutConstraint!
    
    var selectedDir:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    @IBOutlet weak var listTableView: UITableView!
    
    
    
    func getFileList(url: URL) -> [URL]{
        var files:[URL] = []
        do{
            files = try(FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []))
            print(files)
        }catch let error as NSError {
    print(error.localizedDescription)}
        var filtFiles:[URL] = []
        for file in files{
            if file.absoluteString.suffix(9) != ".DS_Store"{
                filtFiles.append(file)
            }
        }
        
        
        return filtFiles
    }
    

   
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.directoryContents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
             let cell = self.listTableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath) as! FileCell
      
        cell.fileName.text = self.fileNames[indexPath.row]
        var tabs = ""
        for _ in 0..<self.depths[indexPath.row]{
                   tabs += "\t"
                    
        }
        cell.spaceLabel.text = tabs
         cell.fileName.numberOfLines = 0
         cell.fileName.lineBreakMode = .byWordWrapping
        cell.fileURL = self.directoryContents[indexPath.row]
       
        var numFiles = (getFileList(url: cell.fileURL)).count
        
        
        if numFiles > 0
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
     
    func showPDF(pdfurl:URL){
        print(pdfurl)
        
        if let pdfDocument = PDFDocument(url:pdfurl ){
                innerView.displayMode = .singlePageContinuous
                innerView.autoScales = true
            
                innerView.displayDirection = .vertical
                innerView.document = pdfDocument
            print(innerView.document)
        }
        self.view.addSubview(pdfView)
        self.view.layoutIfNeeded()
    }
     
    @IBAction func closePDF(_ sender: UIButton){
        self.pdfView.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedDir = self.directoryContents[indexPath.row]
        if !self.selectedDir.hasDirectoryPath && self.selectedDir.absoluteString.suffix(4) == ".pdf"
        {   print(self.selectedDir)
            showPDF(pdfurl: self.selectedDir)
        }
        print("in select",indexPath.row,indexPath.section)
     }
    
    
    
    func expandDir(dirIdx: Int){
        var subDirs = getFileList(url: self.directoryContents[dirIdx])
        self.isExpanded[dirIdx] = true
        var insertIndex = dirIdx+1
        let depth = self.depths[dirIdx] + 1
        
        
        for dir in subDirs{
                   self.directoryContents.insert(dir, at: insertIndex)
                   self.depths.insert(depth, at:insertIndex)
                   self.fileNames.insert( FileManager.default.displayName(atPath:  dir.path),at:insertIndex)
                   self.isExpanded.insert(false, at: insertIndex)
                   insertIndex += 1
        }
            
       
          self.selectedDir = self.directoryContents[dirIdx]
        
        
         self.adjustHeight()
        
    }
        
        
    func adjustHeight(){
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
        let subDirs = getFileList(url: self.directoryContents[dirIdx])
        for  dir in subDirs{
            print(dir,self.directoryContents)
            recursiveCollapse(dirIdx: self.directoryContents.firstIndex(of:dir)!)
            let remIdx = self.directoryContents.firstIndex(of:dir)!
            self.directoryContents.remove(at: remIdx)
            self.depths.remove(at:remIdx)
            self.fileNames.remove(at:remIdx)
            self.isExpanded.remove(at:remIdx)
        }
        }
        
    }
    
    @IBAction func clickArrow(_ sender: UIButton){
       
        if !self.isExpanded[sender.tag]{
            
             expandDir(dirIdx: sender.tag)
        }
        else{
            recursiveCollapse(dirIdx: sender.tag)
            adjustHeight()
            }
        
        self.listTableView.reloadData()
        self.view.layoutIfNeeded()
        self.listTableView.selectRow(at: IndexPath(row: sender.tag,section: 0),animated: false, scrollPosition: .none)
    }
    
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
            var pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView))
            var panGesture = UIPanGestureRecognizer(target: self, action: #selector(panPiece))

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(panGesture)

        self.hideKeyboardWhenTappedAround()
       pdfView.frame.size.width = UIScreen.main.bounds.width
        
        pdfView.frame.size.height = UIScreen.main.bounds.height
        
        
               
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
           var subDirContents:[URL] = getFileList(url: myDocumentsDirectory)
           
           
           for dir in subDirContents{
               self.fileNames.append(FileManager.default.displayName(atPath:  dir.path))
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
    
    
