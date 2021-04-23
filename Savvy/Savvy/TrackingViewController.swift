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


class trackingViewController: UIViewController{
   
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
    @IBOutlet weak var scrollInnerView: UIView!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var trend: UIButton!
    @IBOutlet weak var agg:UIButton!
    
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
            var yvert = 28
            if type == "line"{
                          yvert = -10
                       }
            print(yvert)
            let verticalConstraintChartY = NSLayoutConstraint(item: chartYLabels[idx], attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: chartLabels[idx], attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: CGFloat(yvert))
           
            
            let horizontalConstraintChartY = NSLayoutConstraint(item: chartYLabels[idx], attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: chartLabels[idx], attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: -145)
            
             let widthConstraintChartY = NSLayoutConstraint(item: chartYLabels[idx], attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 250)
            
            
                           
            
            let horizontalConstraintChartLabel = NSLayoutConstraint(item: chartLabels[idx], attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: scrollInnerView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
            var prevItem = UIView()
            var attr = NSLayoutConstraint.Attribute.bottom
            if idx == 0{
                prevItem = scrollInnerView
                attr = NSLayoutConstraint.Attribute.top
                
            }
            else{
                prevItem = charts[idx-1]
            }
            
           
            
            let verticalConstraintChartLabel = NSLayoutConstraint(item: chartLabels[idx], attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: prevItem, attribute: attr, multiplier: 1, constant: 20)
            
            let verticalConstraintChart = NSLayoutConstraint(item: charts[idx], attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: chartLabels[idx], attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 5)
            
            let widthConstraintChartLabel = NSLayoutConstraint(item: chartLabels[idx], attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: scrollInnerView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.80, constant: 0)
            
            let widthConstraintChart = NSLayoutConstraint(item: charts[idx], attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: scrollInnerView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.85, constant: 0)
            
            let heightConstraintChartLabel = NSLayoutConstraint(item: chartLabels[idx], attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant:20)
            
            let heightConstraintChart = NSLayoutConstraint(item: charts[idx], attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem:nil , attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0.3*self.view.frame.height)
            NSLayoutConstraint.activate([horizontalConstraintChart,horizontalConstraintChartLabel,horizontalConstraintChartY, verticalConstraintChartLabel,verticalConstraintChart,
               verticalConstraintChartY,widthConstraintChart, widthConstraintChartLabel,
               widthConstraintChartY,
               heightConstraintChart, heightConstraintChartLabel])
          
            self.height.constant = self.height.constant + 0.3*self.view.frame.height + 50
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
        var symptomsLogged : [String:[String:[String]]] = [:]
       
        for record in records{
                            symptom =  record.value(forKey: "name") as! String
                           date =  record.value(forKey: "timestamp") as! String
                           
                          dur = record.value(forKey: "duration") as! String
            
                           let intensityFloat = record.value(forKey: "intensity") as! Float
            if intensityFloat == 0{
                continue
                
            }
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
            dateFormatterPrint.dateFormat = "yyyy-MM-dd"
            var totDur:[String:Double] = [:]
            for (idx,date) in sortedDates.enumerated(){
                if symptomsLogged[sym]![date]![0] == "24"{
                if idx < sortedDates.count - 1 && dateFormatterPrint.string(from: (dateFormatterGet.date(from: date)!)) == dateFormatterPrint.string(from: (dateFormatterGet.date(from: sortedDates[idx+1])!)){
                    let startDate = dateFormatterGet.date(from:date)!
                    let endDate = dateFormatterGet.date(from: sortedDates[idx+1])!
                    let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: startDate, to: endDate)
                    let hours = Double(diffComponents.hour ?? 0) + Double(diffComponents.minute ?? 0)/60.0
        
                    durDouble = hours
                }
                else{
                    durDouble = 24.0 - (totDur[dateFormatterPrint.string(from: (dateFormatterGet.date(from: date)!))] ?? 0.0)
                    }
                }
                else{
                    durDouble = Double(symptomsLogged[sym]![date]![0])!
                }
              
                totDur[dateFormatterPrint.string(from: (dateFormatterGet.date(from: date)!))] = totDur[dateFormatterPrint.string(from: (dateFormatterGet.date(from: date)!))] ?? 0.0 + durDouble
                print(totDur[dateFormatterPrint.string(from: (dateFormatterGet.date(from: date)!))],durDouble)
                let day = dateFormatterPrint.string(from: (dateFormatterGet.date(from: date)!))
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
                
                symptomsLoggedAggBar[sym]![day]![intensity] = symptomsLoggedAggBar[sym]![day]![intensity]! + durDouble
                
                
                
                                          
                
            }
        
            }
                   
                   height.constant = 0
                   chartsBar = []
                   chartLabels = []
                   chartYLabels = []
                   for (idx,symptom) in symptomsLoggedAggBar.enumerated(){
                       print(idx,symptom)
                       
                       chartsBar.append(BarChartView())
                       chartLabels.append(UILabel())
                       chartYLabels.append(UILabel())
                       chartLabels[idx].text = symptom.key
                    chartLabels[idx].font = UIFont.systemFont(ofSize: 17, weight: .medium)
                       chartYLabels[idx].text = "Duration (hrs)"
                       self.scrollInnerView.addSubview(chartLabels[idx])
                       self.scrollInnerView.addSubview(chartYLabels[idx])
                       
                       updateBarChart(barChartView: chartsBar[idx], logData: symptom.value)
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
                          
                          chartsLine.append(LineChartView())
                          chartLabels.append(UILabel())
                         chartLabels[idx].font = UIFont.systemFont(ofSize: 17, weight: .medium)
                        chartYLabels.append(UILabel())
                          chartLabels[idx].text = symptom.key
                          chartYLabels[idx].text = "Intensity"
                          self.scrollInnerView.addSubview(chartLabels[idx])
                          self.scrollInnerView.addSubview(chartYLabels[idx])
                          
                          updateLineChart(lineChartView: chartsLine[idx], logData: symptom.value)
                      self.scrollInnerView.addSubview(chartsLine[idx])
           
                         
                      }
                      print(chartYLabels)
        addConstraints(charts: chartsLine, type: "line")
                      
                      self.view.layoutIfNeeded()
       }
    
    
    
    @IBAction func clickLineButton(_ sender: UIButton){
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
        removeCharts()
        
        agg.backgroundColor = teal
        agg.setTitleColor(UIColor.white, for: .normal)
        trend.backgroundColor = UIColor.white
        trend.setTitleColor(teal, for: .normal)
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
