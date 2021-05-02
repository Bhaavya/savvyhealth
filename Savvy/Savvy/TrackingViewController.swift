//
//  TrackingViewController.swift
//  Savvy
//
//  Created by Bhavya on 7/4/20.
//  Copyright © 2020 uiuc. All rights reserved.
//

import Foundation
import PopupDialog
import UIKit
import CoreData
import Charts



class trackingViewController: UIViewController, ChartViewDelegate {
   
    var minScale:CGFloat = 1.0
    var maxScale:CGFloat = 5.0
    var cumulativeScale:CGFloat = 1.0
    var isZoom = false
    var type:Int = 0
    var chartsBar:[BarChartView] = []
    var chartLabels:[UILabel] = []

    var chartYLabels:[UILabel] = []
    var chartsLine: [LineChartView] = []
    let teal: UIColor = UIColor(red: 112, green: 172, blue:212)
    
    var symptomsLoggedAggBar:[String:[String:[String:Double]]] = [:]
    var symptomsLoggedLine:[String:[String: Double]] = [:]
    var symptoms: [String] = []
    var freq  = ""
    var freqbuttons: [UIButton] = []
    var freqStr: [String] = []
    var chartType: String = ""
    var cutoffSymptoms = ["Feeling down, depressed or hopeless":3.0,"Feeling anxious or nervous":3.0]
    
    @IBOutlet weak var scrollInnerView: UIView!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var trend: UIButton!
    @IBOutlet weak var agg:UIButton!
    @IBOutlet weak var daily: UIButton!
    @IBOutlet weak var weekly: UIButton!
    @IBOutlet weak var monthly: UIButton!
    
    @IBOutlet weak var freqStack: UIStackView!
    
    @IBOutlet weak var logButton:UIButton!
    
        
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
        trend.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        trend.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        trend.layer.shadowOpacity = 1.0
        trend.layer.shadowRadius = 0.0
        trend.layer.masksToBounds = false
        agg.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        agg.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        agg.layer.shadowOpacity = 1.0
        agg.layer.shadowRadius = 0.0
        agg.layer.masksToBounds = false
        
        freqbuttons = [daily,weekly,monthly]
       freqStr = ["d","w","m"]
        for b in freqbuttons{
           b.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            b.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
           b.layer.shadowOpacity = 1.0
            b.layer.shadowRadius = 0.0
            b.layer.masksToBounds = false
        }
       
        
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {

        print(chartView,entry,highlight)
        
      let idx =  chartView.tag
        var keys:[String]
        print(idx)
        if chartType == "line"  {
           let logData = symptomsLoggedLine[symptoms[idx]]!
           keys = Array(logData.keys)
        }
        else{
           let logData = symptomsLoggedAggBar[symptoms[idx]]!
            keys = Array(logData.keys)
        }
       
            
        
        let dateFormatterGet = DateFormatter()
        let dateFormatterPrint = DateFormatter()
        
        let dateFormatterNote : DateFormatter = DateFormatter()
        dateFormatterNote.dateFormat = "MMM d, y HH:mm"
        
        if chartType == "bar"{
        if (freq == "d" || freq == "w"){
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
            dateFormatterPrint.dateFormat = "MMM dd yyyy"
           
        }
        else{
            dateFormatterGet.dateFormat = "yyyy-MM"
            dateFormatterPrint.dateFormat = "MMM yyyy"
        }
        }
        else{
            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatterPrint.dateFormat = "MMM d, y HH:mm"
        }
       
        let sortedDates = keys.sorted{
            dateFormatterGet.date(from:$0)!.compare(dateFormatterGet.date(from:$1)!) == .orderedAscending
        }
        let date = sortedDates[Int(entry.x)]
       let dateGraph = dateFormatterGet.date(from: date)!
        let dateGraphStr = dateFormatterPrint.string(from: dateGraph)
       print(dateGraphStr)
       let notes = fetchRecords(name: "Note")
        var noteTxt = ""
        var addNote = false
        if notes != nil{
        for n in  (notes as! [NSManagedObject]){
            let dateNote = dateFormatterNote.date(from: (n.value(forKeyPath: "timestamp") as? String)!)
            let dateNoteStr = dateFormatterPrint.string(from: dateNote!)
            addNote = false
            print(dateNoteStr)
            if chartType == "bar" && freq == "w"{
                if dateNote!.isInThisWeek(date: dateNote!, weekStart: dateGraph){
                    addNote = true
                    
                }

            }
            else{
                if dateNoteStr == dateGraphStr{
                    addNote = true
                }
            }
            if addNote{
                noteTxt += (n.value(forKeyPath: "timestamp") as? String)! + "\n\n"
                noteTxt += (n.value(forKeyPath: "title") as? String)! + "\n\n"
                noteTxt += (n.value(forKeyPath: "text") as? String)! + "\n\n\n"
            }
        }
            if noteTxt == ""{
                noteTxt = "No notes found"
            }
        showDialog(msg: noteTxt)
        }
        else{
            showDialog(msg: "No notes found")
        }
    }
    
    func showDialog(msg: String){
        let  alert = UIAlertController(title: "Notes\n", message: msg, preferredStyle: UIAlertController.Style.alert)
       
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
       
        self.present(alert, animated: true, completion: nil)
    }
   

        func chartValueNothingSelected(_ chartView: ChartViewBase)
        {

        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    if(segue.identifier == "trackingViewToLogging") {

        let nextViewController = (segue.destination as! loggingViewController)
        nextViewController.type = self.type
        }}
    
    @IBAction func clickLog(_sender: UIButton){
        self.performSegue(withIdentifier: "trackingViewToLogging", sender: self)
    }
    
    func addConstraints(charts: [UIView],type: String){
        for (idx,_) in charts.enumerated(){
            chartYLabels[idx].font = .systemFont(ofSize: 13)
            chartYLabels[idx].transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        charts[idx].translatesAutoresizingMaskIntoConstraints = false
       
            
            chartLabels[idx].textAlignment = .center
        chartLabels[idx].translatesAutoresizingMaskIntoConstraints = false
            
            chartYLabels[idx].translatesAutoresizingMaskIntoConstraints = false
            
            let horizontalConstraintChart = NSLayoutConstraint(item: charts[idx], attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: scrollInnerView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
           
                       var  yvert = 5
            if type == "line"{
                yvert = -10
            }
                    
            print(yvert)
            let verticalConstraintChartY = NSLayoutConstraint(item: chartYLabels[idx], attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: chartLabels[idx], attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: CGFloat(yvert))
           
            
            let horizontalConstraintChartY = NSLayoutConstraint(item: chartYLabels[idx], attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: chartLabels[idx], attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: -125)
            
             let widthConstraintChartY = NSLayoutConstraint(item: chartYLabels[idx], attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 250)
            
            
                           
            
            let horizontalConstraintChartLabel = NSLayoutConstraint(item: chartLabels[idx], attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: scrollInnerView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
            var prevItem = UIView()
            var attr = NSLayoutConstraint.Attribute.bottom
            if idx == 0{
                if type == "line"{
                prevItem = scrollInnerView
                attr = NSLayoutConstraint.Attribute.top
                }
                else{
                    prevItem = freqStack
                }
                
            }
            else{
                prevItem = charts[idx-1]
            }
            
           
            
            let verticalConstraintChartLabel = NSLayoutConstraint(item: chartLabels[idx], attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: prevItem, attribute: attr, multiplier: 1, constant: 20)
            
            let verticalConstraintChart = NSLayoutConstraint(item: charts[idx], attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: chartLabels[idx], attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 5)
            
            let widthConstraintChartLabel = NSLayoutConstraint(item: chartLabels[idx], attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: scrollInnerView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.80, constant: 0)
            
            let widthConstraintChart = NSLayoutConstraint(item: charts[idx], attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: scrollInnerView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.75, constant: 0)
            
            let heightConstraintChartLabel = NSLayoutConstraint(item: chartLabels[idx], attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant:20)
            
            let heightConstraintChart = NSLayoutConstraint(item: charts[idx], attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem:nil , attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0.3*self.view.frame.height)
            NSLayoutConstraint.activate([horizontalConstraintChart,horizontalConstraintChartLabel,horizontalConstraintChartY, verticalConstraintChartLabel,verticalConstraintChart,
               verticalConstraintChartY,widthConstraintChart, widthConstraintChartLabel,
               widthConstraintChartY,
               heightConstraintChart, heightConstraintChartLabel])
          
            self.height.constant = self.height.constant + 0.3*self.view.frame.height + 80
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "userID") != nil{

        let uid = UserDefaults.standard.object(forKey: "userID")
        
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"trackingView"as AnyObject,"action":"appear" as AnyObject,"json":[:] as AnyObject]
        self.remoteLogging(logging_parameters )
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "userID") != nil{

        let uid = UserDefaults.standard.object(forKey: "userID")
        
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"trackingView"as AnyObject,"action":"disappear" as AnyObject,"json":[:] as AnyObject]
        self.remoteLogging(logging_parameters )
        }
    }
    
    
  
    func drawBarCharts(records: [NSManagedObject]){
       var symptom = ""
       var date = ""
       var dur = "--"
       var intensity = "low"
       let dateFormatterGet = DateFormatter()
        
       dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.symptomsLoggedAggBar = [:]
        self.symptoms=[]
       
        
        var symptomsLogged : [String:[String:[String]]] = [:]
       
        for record in records{
                            symptom =  record.value(forKey: "name") as! String
            
                           date =  record.value(forKey: "timestamp") as! String
                           
                          dur = record.value(forKey: "duration") as! String
            
                           let intensityFloat = record.value(forKey: "intensity") as! Float
            if Array(cutoffSymptoms.keys).contains(symptom){
                if intensityFloat <= 1 {
                    intensity = "low"}
                else if intensityFloat <= 3{
                    intensity = "medium"
                }
                else{
                    intensity = "high"
                }
                dur = String(1.0)
            }
            else{
            if intensityFloat <= 3.6 {
                intensity = "low"}
            else if intensityFloat <= 7.2{
                intensity = "medium"
            }
            else{
                intensity = "high"
            }
                let durUnit = record.value(forKey: "durationUnit") as! String
                if durUnit == "mins" && Int(dur) != nil{
                 dur = String(Double(dur)!/60.0)
                }
            }
                          
                           
                           
                           if symptomsLogged[symptom] == nil {
                               symptomsLogged[symptom] = [:]
                           }
                           
                           if symptomsLogged[symptom]![date] == nil{
                               symptomsLogged[symptom]![date] = []
                           }
                            
                        symptomsLogged[symptom]![date] =  [dur,intensity]

              
            }
     
        
        var durDouble = 0.0
        for (sym,smpLog) in symptomsLogged{
        let sortedDates = Array(smpLog.keys).sorted{
            dateFormatterGet.date(from:$0)!.compare(dateFormatterGet.date(from:$1)!) == .orderedAscending}
            let dateFormatterPrint = DateFormatter()
            if freq == "d" || freq == "w"{
            dateFormatterPrint.dateFormat = "yyyy-MM-dd"
            }
            else{
                dateFormatterPrint.dateFormat = "yyyy-MM"
            }
           
           
            var totDur:[String:Double] = [:]
            
            for (idx,date) in sortedDates.enumerated(){
                var day = dateFormatterPrint.string(from: (dateFormatterGet.date(from: date)!))
                var maxDur = 24.0
                
                  if freq == "w"{
                    maxDur = 168.0
                  day = dateFormatterPrint.string(from: dateFormatterGet.date(from:date)!.startOfWeek())
                  }
                
                  else if freq == "m"{
                    let calendar = Calendar.gregorian
                  

                    // Calculate start and end of the current year (or month with `.month`):
                    let interval = calendar.dateInterval(of: .month, for: dateFormatterGet.date(from:date)!)!

                    // Compute difference in days:
                    let daysInMonth = calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
                
                    maxDur = 24.0 * Double(daysInMonth)
                  }

                
                if Array(cutoffSymptoms.keys).contains(symptom){
                    durDouble = Double(symptomsLogged[sym]![date]![0])!
                    totDur[day] = totDur[day] ?? 0.0 + durDouble
                    
                }
                else{
                if symptomsLogged[sym]![date]![0] == "24"{
                                if idx < sortedDates.count - 1 && dateFormatterPrint.string(from: (dateFormatterGet.date(from: date)!)) == dateFormatterPrint.string(from: (dateFormatterGet.date(from: sortedDates[idx+1])!)){
                                    let startDate = dateFormatterGet.date(from:date)!
                                    let endDate = dateFormatterGet.date(from: sortedDates[idx+1])!
                                    let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: startDate, to: endDate)
                                    let hours = Double(diffComponents.hour ?? 0) + Double(diffComponents.minute ?? 0)/60.0
                        
                                    durDouble = hours
                                }
                                else{
                                    durDouble = Double(symptomsLogged[sym]![date]![0])!
                                }
                                
                                }
                                else{
                                    durDouble = Double(symptomsLogged[sym]![date]![0])!
                                }
                              
                                
               
             
                totDur[day] = min(totDur[day] ?? 0.0 + durDouble,24)
                print(totDur[day],durDouble,Double(symptomsLogged[sym]![date]![0])!)
                }
                
                
                intensity = symptomsLogged[sym]![date]![1]
                if symptomsLoggedAggBar[sym] == nil {
                                             symptomsLoggedAggBar[sym] = [:]
                                         }
                                         
                                         if symptomsLoggedAggBar[sym]![day] == nil{
                                            symptomsLoggedAggBar[sym]![day] = [:]
                                         }
                
                if symptomsLoggedAggBar[sym]![day]![intensity] == nil{
                    symptomsLoggedAggBar[sym]![day]![intensity] = 0.0
                }
                
                if Array(cutoffSymptoms.keys).contains(symptom){
                    symptomsLoggedAggBar[sym]![day]![intensity] = symptomsLoggedAggBar[sym]![day]![intensity]! + durDouble
                }
                else{
                symptomsLoggedAggBar[sym]![day]![intensity] = min(symptomsLoggedAggBar[sym]![day]![intensity]! + durDouble,maxDur)
                
                }
                
            }
        
            }
                   
                   height.constant = 0
                   chartsBar = []
                   chartLabels = []
                   chartYLabels = []
                   for (idx,symptom) in symptomsLoggedAggBar.enumerated(){
                       print(idx,symptom)
                   
                       
                       chartsBar.append(BarChartView())
                    symptoms.append(symptom.key)
                    chartsBar[idx].delegate = self
                    chartsBar[idx].tag = idx
                       chartLabels.append(UILabel())
                       chartYLabels.append(UILabel())
                       chartLabels[idx].text = symptom.key
                    chartLabels[idx].font = UIFont.systemFont(ofSize: 17, weight: .medium)
                    
                       chartYLabels[idx].text = "Duration (hrs)             "
                       self.scrollInnerView.addSubview(chartLabels[idx])
                       self.scrollInnerView.addSubview(chartYLabels[idx])
                    
                    var cutoff = 0.0
                    var addCutoff = false
                    if Array(cutoffSymptoms.keys).contains(symptom.key){
                        cutoff = cutoffSymptoms[symptom.key]!
                        addCutoff = true
                        chartYLabels[idx].text = "Number of times"
                    }
                       
                    updateBarChart(barChartView: chartsBar[idx], logData: symptom.value,freq: self.freq,addCutoff: addCutoff, cutoff: cutoff)
                   self.scrollInnerView.addSubview(chartsBar[idx])
        
                      
                   }
                   print(chartYLabels)
        addConstraints(charts: chartsBar, type: "bar")
                   
                   self.view.layoutIfNeeded()
    }
    
    func drawLineCharts(records: [NSManagedObject]){
          var symptom = ""
          var date = ""
          var dur = 0.0
        var intensity = 5.0
          let dateFormatterGet = DateFormatter()
        self.symptoms=[]
          dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
          
           for record in records{
                               symptom =  record.value(forKey: "name") as! String
                              date =  record.value(forKey: "timestamp") as! String
                             
                             
                              let intensity = record.value(forKey: "intensity") as! Double
               
                              let durUnit = record.value(forKey: "durationUnit") as! String
                              if durUnit == "mins"{
                                  dur = dur/60.0
                              }
                              
                              
                              if self.symptomsLoggedLine[symptom] == nil {
                                  self.symptomsLoggedLine[symptom] = [:]
                              }

                           self.symptomsLoggedLine[symptom]![date] = intensity
                 
                          }
                      
                      height.constant = 0
                      chartsLine = []
                      chartLabels = []
                      chartYLabels = []
                      for (idx,symptom) in symptomsLoggedLine.enumerated(){
                          print(idx,symptom)
                        symptoms.append(symptom.key)
                          chartsLine.append(LineChartView())
                        chartsLine[idx].delegate = self
                        chartsLine[idx].tag = idx
                          chartLabels.append(UILabel())
                         chartLabels[idx].font = UIFont.systemFont(ofSize: 17, weight: .medium)
                        chartYLabels.append(UILabel())
                          chartLabels[idx].text = symptom.key
                          chartYLabels[idx].text = "Intensity"
                          self.scrollInnerView.addSubview(chartLabels[idx])
                          self.scrollInnerView.addSubview(chartYLabels[idx])
                        var addCutoff = false
                        var cutoff = 0.0
                        if
                            Array(self.cutoffSymptoms.keys).contains(symptom.key){
                            addCutoff = true
                            cutoff = self.cutoffSymptoms[symptom.key]!
                        }
                          
                          updateLineChart(lineChartView: chartsLine[idx], logData: symptom.value, addCutoff: addCutoff, cutoff: cutoff)
                      self.scrollInnerView.addSubview(chartsLine[idx])
           
                         
                      }
                      print(chartYLabels)
        addConstraints(charts: chartsLine, type: "line")
                      
                      self.view.layoutIfNeeded()
       }
    
    func selectfreq(frequency: Int){
       
       freqbuttons[frequency].backgroundColor = teal
        freqbuttons[frequency].setTitleColor(UIColor.white, for: .normal)
        for f in [0,1,2]{
            if f != frequency{
                freqbuttons[f].backgroundColor = UIColor.white
                freqbuttons[f].setTitleColor(teal, for: .normal)
            }
        }
        freq = freqStr[frequency]
    }
    
    @IBAction func clickDailyButton(_ sender: UIButton){
        
        selectfreq(frequency: 0)
        removeCharts()
        var records:Optional<Any> = nil
        if self.type == 0{
        records = fetchRecords(name: "SymptomLog")
        }
        else{
            records = fetchRecords(name: "MoodLog")
        }
        if records != nil {
       drawBarCharts(records:records as! [NSManagedObject])
        }
        
    }
    
    @IBAction func clickWeeklyButton(_ sender: UIButton){
        selectfreq(frequency: 1)
        removeCharts()
        var records:Optional<Any> = nil
        if self.type == 0{
        records = fetchRecords(name: "SymptomLog")
        }
        else{
            records = fetchRecords(name: "MoodLog")
        }
        if records != nil {
       drawBarCharts(records:records as! [NSManagedObject])
    }
    }
    
  @IBAction func clickMonthlyButton(_ sender: UIButton){
        selectfreq(frequency: 2)
    removeCharts()
    var records:Optional<Any> = nil
    if self.type == 0{
    records = fetchRecords(name: "SymptomLog")
    }
    else{
        records = fetchRecords(name: "MoodLog")
    }
    if records != nil {
   drawBarCharts(records:records as! [NSManagedObject])
    }
  }
    
    
    
    @IBAction func clickLineButton(_ sender: UIButton){
        freqStack.isHidden = true
        chartType = "line"
        removeCharts()
        
        trend.backgroundColor = teal
        trend.setTitleColor(UIColor.white, for: .normal)
        agg.backgroundColor = UIColor.white
        agg.setTitleColor(teal, for: .normal)
        var records:Optional<Any> = nil
        if self.type == 0{
        records = fetchRecords(name: "SymptomLog")
        }
        else{
            records = fetchRecords(name: "MoodLog")
        }
               if records != nil {
                drawLineCharts(records: records as! [NSManagedObject])
        }
    }
    
    @IBAction func clickAggButton(_ sender: UIButton){
        freqStack.isHidden = false
        chartType = "bar"
        removeCharts()
        
        
        agg.backgroundColor = teal
        agg.setTitleColor(UIColor.white, for: .normal)
        trend.backgroundColor = UIColor.white
        trend.setTitleColor(teal, for: .normal)
        selectfreq(frequency: 0)
         var records:Optional<Any> = nil
         if self.type == 0{
         records = fetchRecords(name: "SymptomLog")
         }
         else{
             records = fetchRecords(name: "MoodLog")
         }
         if records != nil {
        drawBarCharts(records:records as! [NSManagedObject])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(self.type)
        var records:Optional<Any> =  nil
        if self.type == 0{
            self.logButton.setTitle("+ Log your health", for: .normal)
            records = fetchRecords(name: "SymptomLog")
           
        }
        else{
            self.logButton.setTitle("+ Log your mood", for: .normal)
            records = fetchRecords(name: "MoodLog")
        }
            if records != nil {
                if (records as! [NSManagedObject]).count > 0{
                    self.buttonStack.isHidden = false
                   trend.backgroundColor = teal
                    trend.setTitleColor(UIColor.white, for: .normal)
                    agg.backgroundColor = UIColor.white
                    agg.setTitleColor(teal, for: .normal)
                    
                   
                    
                }
                else{
                    self.buttonStack.isHidden = true
                }
                self.chartType = "line"
                self.drawLineCharts(records: records as! [NSManagedObject])
                }
            else{
                self.buttonStack.isHidden = true
            }
    
    }
    func removeCharts(){
    for (idx,_) in symptomsLoggedAggBar.enumerated(){
    self.chartsBar[idx].removeFromSuperview()
    self.chartYLabels[idx].removeFromSuperview()
    self.chartLabels[idx].removeFromSuperview()
    }
    for (idx,_) in symptomsLoggedLine.enumerated(){
        self.chartsLine[idx].removeFromSuperview()
        self.chartYLabels[idx].removeFromSuperview()
        self.chartLabels[idx].removeFromSuperview()
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
     
        removeCharts()
    }
    
    @IBAction func backClicked(_ sender: UIButton){
    if let nvc = navigationController {
            nvc.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    

}

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)

}

extension Date {
    func startOfWeek(using calendar: Calendar = .gregorian) -> Date {
        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    func isInThisWeek(using calendar: Calendar = .gregorian, date: Date, weekStart: Date) -> Bool {
        return calendar.isDate(date, equalTo: weekStart, toGranularity: .weekOfYear)
    }
   
}
