//
//  LoggingViewController.swift
//  Savvy
//
//  Created by Bhavya on 7/3/20.
//  Copyright © 2020 uiuc. All rights reserved.
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

class loggingCell: UITableViewCell {
        
    @IBOutlet weak var titleLabel: UILabel!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}


class loggingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource{
    @IBOutlet weak var logSymptomInnerView: UIView!
@IBOutlet weak var logSymptomOverlay: UIView!
    
    @IBOutlet weak var newSymptomInnerView: UIView!
    @IBOutlet weak var newSymptomOverlay: UIView!
    @IBOutlet weak var newSymptomTextField: UITextField!
    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var searchSym: SearchTextField!
    

    @IBOutlet weak var q1lbl: UILabel!
    
    @IBOutlet  var q1opt: [DLRadioButton]!
    
    @IBOutlet weak var q2lbl: UILabel!
    
    @IBOutlet var q2opt: [DLRadioButton]!
    
    @IBOutlet weak var logMoodOverlay: UIView!
    
    @IBOutlet weak var logMoodInner: UIView!
    
    @IBOutlet weak var durLbl: UILabel!
    var noteTimestamp: String = ""
    
    
    
    @IBAction func clickNewSymp()
    {
        self.newSymptomTextField.text = ""
        
        self.view.addSubview(newSymptomOverlay)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "System", size: 15)
            pickerLabel?.textAlignment = .center
        }
        if pickerView == durPicker{
           
            pickerLabel?.text = String(self.dur[row])
            
        }
        else{
            print(row,self.durUnit)
            pickerLabel?.text = self.durUnit[row]
        }
        
        pickerLabel?.textColor = UIColor.black

        return pickerLabel!
    }
    
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    print(pickerView.tag)
    if pickerView == durPicker{
        return 59
    }
    
    else {
        return 2
    }
    
    }
    

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == durPicker{
                   
            self.durSelected = self.dur[row]
               }
               else {
                  self.durUnitSelected = self.durUnit[row]
               }
              
    }
   
    
   
    
    @objc var tableList: [Int:[String]] = [0:[],1:[]]
    var symptomSelected: String = ""
    var durSelected: Int = 24
    var durUnitSelected: String = "hrs"
    var intensitySelected: Float = 5
    @objc var fullList: [Int:[String]] = [0:[]]
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var datepicker:UIDatePicker!
    @IBOutlet weak var datepickerMood: UIDatePicker!
    @IBOutlet weak var durPicker:UIPickerView!
    @IBOutlet weak var durUnitPicker:UIPickerView!
    var defaultSymptoms: [String] = []
    
    let dur:[Int] = Array(1...59)
    let durUnit:[String] = ["mins","hrs"]
    
    var type:Int = 0
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
    
   
    func addBorder(picker: UIView){
       
        picker.layer.borderColor   = UIColor.lightGray.cgColor;
        picker.layer.borderWidth   = 1.0;
        picker.layer.cornerRadius  = 5.0;
       picker.layer.masksToBounds = true;
        picker.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
         picker.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
          picker.layer.shadowOpacity = 1.0
        picker.layer.shadowRadius = 0.0
        picker.layer.masksToBounds = false
    }
   
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{ UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(x:0, y:0, width:newSize.width, height:newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView))
        var panGesture = UIPanGestureRecognizer(target: self, action: #selector(panPiece))
        
        view.isUserInteractionEnabled = true
        
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(panGesture)
        self.datepicker.maximumDate = Date()
        
        addBorder(picker: self.datepicker)
        
        self.datepickerMood.maximumDate = Date()
        
        addBorder(picker: self.datepickerMood)
        
        self.intensitySlider.isContinuous = false
       
        var image = UIImage(named: "number-zero");
        var size = CGSize(width: image!.size.width * 0.04, height: image!.size.height * 0.04 )
        
        self.intensitySlider.minimumValueImage =  self.imageWithImage(image: image!, scaledToSize: size)
        
         image = UIImage(named: "number-ten");
        
        self.intensitySlider.maximumValueImage =  self.imageWithImage(image: image!, scaledToSize: size)
        
        
        logSymptomOverlay.frame.size.width = UIScreen.main.bounds.width
        logSymptomOverlay.frame.size.height = UIScreen.main.bounds.height
       
       
        logSymptomInnerView.layer.cornerRadius = 8.0
         let borderWidth = 0.5

         
         logSymptomInnerView.layer.borderColor = UIColor.darkGray.cgColor
        logSymptomInnerView.layer.borderWidth = CGFloat(borderWidth);
        
        logMoodOverlay.frame.size.width = UIScreen.main.bounds.width
        logMoodOverlay.frame.size.height = UIScreen.main.bounds.height
       
       
       
        
        newSymptomOverlay.frame.size.width = UIScreen.main.bounds.width
         newSymptomOverlay.frame.size.height = UIScreen.main.bounds.height
        
        
         newSymptomInnerView.layer.cornerRadius = 8.0
          
          newSymptomInnerView.layer.borderColor = UIColor.darkGray.cgColor
         newSymptomInnerView.layer.borderWidth = CGFloat(borderWidth);
        
        for btn in self.q1opt{
            btn.titleLabel!.numberOfLines = 0; // Dynamic number of lines
            btn.titleLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping;
        }
        for btn in self.q2opt{
            btn.titleLabel!.numberOfLines = 0; // Dynamic number of lines
            btn.titleLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping;
        }
        
    }
    
   
    
    @objc func reloadData(notification:Notification){
        // reload function here, so when called it will reload the tableView
        self.tableView.reloadData()
    }
    
    func setSymptoms(symptoms: [String:[Any]],filter_json:[String:Any]){
    
        for sym in self.defaultSymptoms{
            (self.tableList[filter_json["type"] as! Int])!.append((sym))
        }
        for symptom in symptoms["results"]! as [Any]{
               let symDict = symptom as! [String:AnyObject]
               let symJson = convertToDictionary(text:symDict["eventJson"] as! String)
            if symJson!["ename"] as! String == filter_json["ename"] as! String{
            if !self.tableList[filter_json["type"] as! Int]!.contains(symJson!["name"] as! String) {
                (self.tableList[filter_json["type"] as! Int])!.append((symJson!["name"] as! String))
            }
            }
        }
//            self.tableList[self.type]!.append("Create new symptom")
        self.fullList[filter_json["type"] as! Int] = Array(self.tableList[self.type]!)
    var listLength = 10
    if filter_json["type"] as! Int == 1{
        listLength = 3
    }
    
        self.tableList[filter_json["type"] as! Int] = Array(self.tableList[filter_json["type"] as! Int]!.prefix(listLength))
    
    self.searchSym.theme = SearchTextFieldTheme.darkTheme()
    self.searchSym.theme.font = UIFont.systemFont(ofSize: 21)
//        self.searchSym.theme.fontColor
    self.searchSym.theme.bgColor = UIColor.lightGray
    
    self.searchSym.theme.borderColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    self.searchSym.theme.separatorColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    self.searchSym.theme.cellHeight = 50
    self.searchSym.maxNumberOfResults = 10
    self.searchSym.startVisible = true

self.searchSym.filterStrings(Array(self.fullList[self.type]!))
    self.searchSym.itemSelectionHandler = {item, itemPosition in
        self.selectSym(item: item[itemPosition].title)
   
    }
        self.tableView.reloadData()

    }
    
    func fetchRemoteSymptom(json: [String:Any],completion: @escaping ([String:[Any]],[String:Any])->()){
       
        if UserDefaults.standard.object(forKey: "userID") != nil{

            let uid = UserDefaults.standard.object(forKey: "userID")
            var parameters = ["id":uid as AnyObject,"page":"logging" as AnyObject,"action":"createCondition" as AnyObject]
            remoteFetch(parameters, json: json, completion: completion)
        }
        }
        
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if self.type == 0{
      
            self.defaultSymptoms = ["Feeling good","Fatigue","Walking (Gait) Difficulties","Numbness or Tingling","Spasticity","Weakness","Vision Problems","Dizziness and Vertigo","Bladder Problems","Sexual Problems","Bowel Problems","Pain & Itching","Cognitive Problems"]
            
            self.addButton.setTitle("Create new health condition",for:.normal)
        }
        else{
            self.defaultSymptoms = ["Feeling happy", "Feeling down, depressed or hopeless","Feeling anxious or nervous" ]
            self.addButton.setTitle("Create new mood" , for: .normal)
            
        }
        var symptoms:Optional<Any> = []
        var ename: String = ""
        if self.type == 0{
            
            ename = "Symptom"
        }
        else{
           
            ename = "Mood"
        }
        symptoms = fetchRemoteSymptom(json: ["type":self.type,"ename":ename],completion: setSymptoms(symptoms:filter_json:))
 
    }
    
   
    
    override func viewWillDisappear(_ animated: Bool) {
    
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    if(segue.identifier == "logToNote") {

        let nextViewController = (segue.destination as! noteDetailViewController)
        nextViewController.sentTimestamp = noteTimestamp
        }}
    
    @IBAction func addNote(_sender: UIButton){
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, y HH:mm"
        noteTimestamp = dateFormatter.string(from:datepicker.date)
        self.performSegue(withIdentifier: "logToNote", sender: self)
    }
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "logCell", for: indexPath) as! loggingCell

        cell.titleLabel!.text =    self.tableList[self.type]![indexPath.section]
        
        cell.titleLabel?.numberOfLines = 0
        cell.titleLabel?.lineBreakMode = .byWordWrapping
       cell.backgroundColor = UIColor.white
       cell.layer.borderColor = UIColor.black.cgColor
       cell.layer.borderWidth = 1
       cell.layer.cornerRadius = 8
       cell.clipsToBounds = true
        cell.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        cell.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        cell.layer.shadowOpacity = 1.0
        cell.layer.shadowRadius = 0.0
        cell.layer.masksToBounds = false
        return cell
       
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableList[self.type]!.count
    }
    
    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
        
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func selectSym (item: String){
        
        if (["Feeling down, depressed or hopeless","Feeling anxious or nervous"].contains(item)){
        selectMood(item: item)
        }
        else{
            self.searchSym.text = item
            self.symptomSelected = item
            self.durPicker.selectRow(23, inComponent: 0, animated: true)
            if self.type == 0{
                self.durPicker.isHidden = false
                self.durUnitPicker.isHidden = false
                self.durLbl.isHidden = false
            }
            else{
                self.durPicker.isHidden = true
                self.durUnitPicker.isHidden = true
                self.durLbl.isHidden = true
            }
            self.durUnitPicker.selectRow(1, inComponent: 0, animated: true)
            self.view.addSubview(logSymptomOverlay)
        
        }
    
        print("You selected cell #\(item)!")
    }
    func selectMood (item: String){
        self.searchSym.text = item
        self.symptomSelected = item
       
            
            if item == "Feeling down, depressed or hopeless"{
                self.q1lbl.text = "1. Little interest or pleasure in doing things"
                self.q2lbl.text = "2. Feeling down, depressed or hopeless"
            }
            else if item == "Feeling anxious or nervous" {
                self.q1lbl.text = "Feeling anxious or nervous"
                self.q2lbl.text = "Not being able to stop or control worrying"
            }
            
            
            self.view.addSubview(logMoodOverlay)
        
        
    
        print("You selected cell #\(item)!")
    }
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        selectSym(item: self.tableList[self.type]![indexPath.section])
   
    }
    
    func validateSymptomLog() -> Bool{
        if self.durSelected > 24 && self.durUnitSelected == "hrs"{
            return false
        }
        else{
        return true
        }
    }
    
    @IBAction func intensityChanged(_ sender: UISlider) {
        self.intensitySelected = sender.value
           }
    
    
    
    @IBAction func logSymptomCancelClicked(_sender: UIButton){
         self.logSymptomOverlay.removeFromSuperview()
    }
    
    
    @IBAction func logMoodCancelClicked(_sender: UIButton){
             self.logMoodOverlay.removeFromSuperview()
        }
    
    @IBAction func newSymptomCancelClicked(_sender: UIButton){
         self.newSymptomOverlay.removeFromSuperview()
    }
    
    @IBAction func newSymptomSubmitClicked(_sender: UIButton){
        let name = self.newSymptomTextField!.text
        if name != nil && name != ""{
            let newId = self.fullList[self.type]!.count
            var ename:String = ""
            if self.type == 0{
                ename = "Symptom"
            }
            else{
                ename = "Mood"
            }
//            self.saveSymptomName(id: int_fast64_t(newId), name: name!, ename:ename)
            self.fullList[self.type]!.insert(name!, at: newId)
        self.searchSym.filterStrings(Array(self.fullList[self.type]!))
            let uid = UserDefaults.standard.object(forKey: "userID")
            var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"logging" as AnyObject,"action":"createCondition" as AnyObject,"json":["name":name!, "ename": ename] as AnyObject]
                self.remoteLogging(logging_parameters )
            
//            self.tableList[self.type]!.insert(name!, at: newId)
//            self.tableView.reloadData()
        self.newSymptomOverlay.removeFromSuperview()
        }
        else{
            let alertController = UIAlertController(title: "Error", message: "Enter symptom name", preferredStyle: .alert)
                               
                               
                               let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                               alertController.addAction(defaultAction)
                               
                               self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showDialog(){
        let containerAppearance = PopupDialogContainerView.appearance()
        let msg = ["You’ve tracked '"+self.symptomSelected+"' for 3 consecutive days. Would you like to find more information on it? Click on the 'Find Resources' button on the home page!", "You’ve tracked '"+self.symptomSelected+"' for 3 consecutive days. Would you like to take notes and discuss it with your clinician? Click on 'Notes' on the home page!"].randomElement()
        containerAppearance.backgroundColor = UIColor.white
        var dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.messageColor = UIColor.black
        dialogAppearance.titleFont = UIFont.boldSystemFont(ofSize: 16)
        dialogAppearance.titleColor = UIColor.black
        let popup = PopupDialog(title: "Tip", message: msg)
        let buttonOne = DefaultButton(title: "OK", dismissOnTap: true) {
        }
        
        popup.addButtons([buttonOne])
        self.present(popup, animated: true, completion: nil)
    }
    
    func checkMulSrch(prevSearches: [String:[Any]], json1:[String:Any]){
        let dateFormatterGet = DateFormatter()
        let uid = UserDefaults.standard.object(forKey: "userID")
        
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startDt = dateFormatterGet.date(from:json1["timestamp"] as! String)
        var found = false
        for srch in prevSearches["results"]! as [Any]{
            let symDict = srch as! [String:AnyObject]
            let json = convertToDictionary(text: symDict["eventJson"] as! String)
            if (json!["query"] as! String).lowercased().contains(((json1["name"]!) as! String).lowercased()) == true{
                
                let ts = symDict["ts"]?.integerValue
                let timeInterval = TimeInterval(ts!)

                // create NSDate from Double (NSTimeInterval)
                let dt = Date(timeIntervalSince1970: timeInterval)
                print("dt",dt)
                let diff = Calendar.current.dateComponents([.day], from: startDt!, to: dt).day ?? 0
                if diff > -3{
                    found = true
                    
                    break
                }
               
            }
            
        }
        if found == false {
            showDialog()
        }
    }
  

    
    func checkMultipleSym(prevSymptoms: [String:[Any]],json1:[String:Any]){
        let dateFormatterGet = DateFormatter()
        let uid = UserDefaults.standard.object(forKey: "userID")
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startDt = dateFormatterGet.date(from: json1["timestamp"] as! String)!
        var dates:[String] = []
        for sym in prevSymptoms["results"]! as [Any]{
            let symDict = sym as! [String:AnyObject]
            let json = convertToDictionary(text:symDict["eventJson"] as! String)
            if (json1["name"] as! String == (json!["name"] as! String)) {
                
                dates.append(json!["timestamp"]! as! String)
            }
            
        }
        var diffs:[Int]=[]
        for strDt in dates{
            let dt = dateFormatterGet.date(from: strDt)
            let diff = Calendar.current.dateComponents([.day], from: startDt, to: dt!)
            diffs.append(diff.day ?? 0)
        }
        print("diffs",diffs)
        if ((diffs.contains(-1)) && (diffs.contains(-2)) || (diffs.contains(1)) && (diffs.contains(2)) && ((json1["name"] as! String != "Feeling good") && (json1["name"] as! String != "Feeling happy"))){
            var fetchParams:[String:AnyObject] = ["id":uid as AnyObject,"page":"search" as AnyObject,"action":"search" as AnyObject]
           
            
            self.remoteFetch(fetchParams,json: json1, completion: checkMulSrch(prevSearches:json1:))
        }
    }
    
    @IBAction func logSubmitClicked(_sender: UIButton){
        if validateSymptomLog(){
            var ename:String = ""
            if self.type == 0{
                ename = "SymptomLog"
            }
            else{
                ename = "MoodLog"
            }
       let dateFormatterGet = DateFormatter()
              dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
            var du: String = ""
            var dun: String = ""
            if self.type == 1{
                du = "24"
                dun = "hrs"
            }
            else{
                du = String(self.durSelected)
                dun = self.durUnitSelected
            }
        
//            self.saveSymptomLog(name: self.symptomSelected, timestamp:  dateFormatterGet.string(from:datepicker.date), duration: du, durationUnit: dun, intensity: self.intensitySelected,ename: ename)
          

                let uid = UserDefaults.standard.object(forKey: "userID")
                
            var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"logging" as AnyObject,"action":"log" as AnyObject,"json":["name":self.symptomSelected, "timestamp":dateFormatterGet.string(from:datepicker.date),
                 "duration":du,"durationUnit": dun, "intensity": self.intensitySelected,"ename": ename] as AnyObject]
            
            self.remoteLogging(logging_parameters)
            
            var fetchParams:[String:AnyObject] = ["id":uid as AnyObject,"page":"logging" as AnyObject,"action":"log" as AnyObject]
            var otherParams:[String:String] = ["name":self.symptomSelected,"timestamp":dateFormatterGet.string(from:datepicker.date)]
            
            self.remoteFetch(fetchParams,json: otherParams,completion: checkMultipleSym(prevSymptoms:json1:))
           
        self.logSymptomOverlay.removeFromSuperview()
        }
        else{
            let alertController = UIAlertController(title: "Error", message: "Duration must be less than 24 hours ", preferredStyle: .alert)
                    
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func dispMsg(msg:String){
        let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
    }
    
  @IBAction  func logMoodSubmitClicked(_sender: UIButton){
        
            var ename:String = "MoodLog"
            
       let dateFormatterGet = DateFormatter()
              dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
    var score = 0
    var sel = false
    for (idx,btn) in self.q1opt.enumerated(){
        if btn.isSelected{
        score += idx
            sel = true
        }
    }
    if sel == false{
        dispMsg(msg: "Please answer both the questions!")
        return
    }
    sel = false
    for (idx,btn) in self.q2opt.enumerated(){
        if btn.isSelected{
        score += idx
            sel = true
        }
    }
    if sel == false {
        dispMsg(msg: "Please answer both the questions!")
        return
    }
//    self.saveSymptomLog(name: self.symptomSelected, timestamp:  dateFormatterGet.string(from:datepickerMood.date), duration: "24", durationUnit: "hrs", intensity: Float(score),ename: ename)
          

                let uid = UserDefaults.standard.object(forKey: "userID")
                
            var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"logging" as AnyObject,"action":"log" as AnyObject,"json":["name":self.symptomSelected, "timestamp":dateFormatterGet.string(from:datepicker.date),
                 "duration":"24","durationUnit": "hrs", "intensity": Float(score),"ename": ename] as AnyObject]
            
            self.remoteLogging(logging_parameters)
            
            var fetchParams:[String:AnyObject] = ["id":uid as AnyObject,"page":"logging" as AnyObject,"action":"log" as AnyObject]
            var otherParams:[String:String] = ["name":self.symptomSelected,"timestamp":dateFormatterGet.string(from:datepicker.date)]
            
            self.remoteFetch(fetchParams,json: otherParams,completion: checkMultipleSym(prevSymptoms:json1:))
           
        self.logMoodOverlay.removeFromSuperview()
        
        
    }
    
    @IBAction func backClicked(_ sender: UIButton){
        if let nvc = navigationController {
            nvc.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "userID") != nil{

        let uid = UserDefaults.standard.object(forKey: "userID")
        
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"logging"as AnyObject,"action":"appear" as AnyObject,"json":[:] as AnyObject]
        self.remoteLogging(logging_parameters )
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "userID") != nil{

        let uid = UserDefaults.standard.object(forKey: "userID")
        
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"logging"as AnyObject,"action":"disappear" as AnyObject,"json":[:] as AnyObject]
        self.remoteLogging(logging_parameters )
        }
    }
  
}
