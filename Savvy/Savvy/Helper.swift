//
//  Helper.swift
//  Savvy
//
//  Created by Bhavya on 6/18/20.
//  Copyright © 2020 uiuc. All rights reserved.
//

import Foundation
import UIKit
import PopupDialog
import SwiftSpinner
import CoreData
import Charts
import Alamofire

extension UIImage {
    
    @objc func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}
import SafariServices
extension UIViewController {
func showWebView(_ urlString: String) {
    
if let url = URL(string: urlString) {
let vc = SFSafariViewController(url: url)
self.present(vc, animated: true)}
    
}
}

extension UIColor {
    @objc convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
    
}





extension UIViewController {
    
    func jsonToString(json: AnyObject) -> String{
        var convertedString = ""
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            convertedString = String(data: data1, encoding: String.Encoding.utf8) ?? "default" // the data will be converted to the string
            
        } catch let myJSONError {
            print(myJSONError)
        }
        return convertedString
    }
   
    
    @objc func displayMyAlertMessage(_ userMessage:String) {
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertController.Style.alert);
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil);
        myAlert.addAction(okAction);
        self.present(myAlert, animated: true, completion: nil);
    }
    
    @objc func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func remoteLogging(_ parameters:[String:AnyObject]){
        let timestamp = "\(NSDate().timeIntervalSince1970 * 1000)"
        var sendParams :[String:AnyObject] = parameters
        sendParams["ts"] = timestamp as AnyObject
        
     
        let request = AF.request("https://timan102.cs.illinois.edu/savvy_logging/", method: HTTPMethod.post, parameters: sendParams, encoding: JSONEncoding.default)
        .responseJSON(completionHandler: { (response) in
            print(3, response)

        })

            
        
        print("2",request)
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    @objc func remoteFetch(_ parameters:[String:AnyObject],json: [String:Any],completion :  @escaping ([String:[Any]],[String:Any])->()){
        let sendParams :[String:AnyObject] = parameters
        var retResponse:[String:[Any]] = ["results":[]]
        let request = AF.request("https://timan102.cs.illinois.edu/savvy_fetch/", method: HTTPMethod.post, parameters: sendParams, encoding: JSONEncoding.default)
        .responseJSON(completionHandler: { (response) in
            switch response.result {
                           case .success(let value):
                               if let JSON = value as? [String: Any] {
                                print(1,response,JSON)
                                   
                                retResponse["results"] = JSON["results"] as? [Any]
                                completion(retResponse,json)
                               }
                           case .failure(let error): break
                               // error handling
                           }


        })
        
        
        
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func saveSymptomName(id: int_fast64_t, name: String,ename: String) {
        guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return
      }
      
      
      let managedContext =
        appDelegate.persistentContainer.viewContext
      
      
      let entity =
        NSEntityDescription.entity(forEntityName: ename,
                                   in: managedContext)!
      
      let symptom = NSManagedObject(entity: entity,                               insertInto: managedContext)
      symptom.setValue(id, forKeyPath: "id")
     symptom.setValue(name, forKeyPath: "name")
      
      do {
        try managedContext.save()
        
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }


    func saveSymptomLog(name: String, timestamp: String, duration: String, durationUnit: String, intensity: Float, ename: String) {
        
        guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      
      
      let managedContext =
        appDelegate.persistentContainer.viewContext
      
      
      let entity =
        NSEntityDescription.entity(forEntityName: ename,
                                   in: managedContext)!
      
      let symptom = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
      symptom.setValue(name, forKeyPath: "name")
     symptom.setValue(timestamp, forKeyPath: "timestamp")
    symptom.setValue(duration, forKeyPath: "duration")
    symptom.setValue(durationUnit, forKeyPath: "durationUnit")
    symptom.setValue(intensity, forKeyPath: "intensity")
      
      
      do {
        try managedContext.save()
        
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
    func saveNote(id: Int64, title: String, timestamp: String, text: String, note: NSManagedObject?) -> Int{
        
        guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return 1
      }
      
      
      let managedContext =
        appDelegate.persistentContainer.viewContext
      
      
      let entity =
        NSEntityDescription.entity(forEntityName: "Note",
                                   in: managedContext)!
        var newNote:NSManagedObject? = nil
        
        if note != nil{
            managedContext.delete(note!)
        }
       
        newNote = NSManagedObject(entity: entity,
                                          insertInto: managedContext)
        
      (newNote as! NSManagedObject).setValue(title, forKeyPath: "title")
     (newNote as! NSManagedObject).setValue(timestamp, forKeyPath: "timestamp")
    (newNote as! NSManagedObject).setValue(text, forKeyPath: "text")
        (newNote as! NSManagedObject).setValue(id, forKeyPath: "id")
      
      
       
      do {
        try managedContext.save()
        
        return 0
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
        return 1
      }
    }
    
    
    func saveContact(emails: [String], ename: String) {
        let emailRec = fetchRecords(name: "Contact")
        var prevEmails:[String] = []
        for em in emailRec as! [NSManagedObject]{
            prevEmails.append((em.value(forKeyPath: "email") as? String)!)
                   }
        
        guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      
      
      let managedContext =
        appDelegate.persistentContainer.viewContext
        var entity:NSEntityDescription
        var contact:NSManagedObject
        
        for email in emails{
            if !prevEmails.contains(email){
     entity =
        NSEntityDescription.entity(forEntityName: ename,
                                   in: managedContext)!
      
      contact = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
      contact.setValue(email, forKeyPath: "email")
    
      do {
        try managedContext.save()
        
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
        }
        }
    }
    
   
    

    func fetchRecords(name: String) -> Optional<Any>{
        guard let appDelegate =
               UIApplication.shared.delegate as? AppDelegate else {
                 return nil
             }
            
             let managedContext =
               appDelegate.persistentContainer.viewContext
            
             let fetchRequest =
               NSFetchRequest<NSManagedObject>(entityName: name)
             
           
             do {
               let  symptoms = try managedContext.fetch(fetchRequest)
               return symptoms
             } catch let error as NSError {
               print("Could not fetch. \(error), \(error.userInfo)")
                return nil
             }
    }

    func updateBarChart(barChartView: BarChartView , logData: [String:[String:Double]],freq: String,addCutoff: Bool, cutoff: Double,hasNote: [String:Bool]) {
            
        
        var dataEntries: [BarChartDataEntry] = []
        
        
        var minVal = 100000.0
        
        let dateFormatterGet = DateFormatter()
        let dateFormatterPrint = DateFormatter()
        if freq == "d" || freq == "w"{
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
            dateFormatterPrint.dateFormat = "MMM dd yyyy"
        }
        else{
            dateFormatterGet.dateFormat = "yyyy-MM"
            dateFormatterPrint.dateFormat = "MMM yyyy"
        }
      
        
    
       
        let sortedDates = Array(logData.keys).sorted{
                                       dateFormatterGet.date(from:$0)!.compare(dateFormatterGet.date(from:$1)!) == .orderedAscending
                                   }
        var dates: [String] = []
       
        var palette: [NSUIColor] = []
        
        
         var yvals:[Double] = []
       
  
        for (idx,date) in sortedDates.enumerated() {
            yvals = []
            
            yvals.append(logData[date]!["low"] ?? 0.0)
            yvals.append(logData[date]!["medium"] ?? 0.0)
            yvals.append(logData[date]!["high"] ?? 0.0)
            if hasNote[date]!{
                palette.append(UIColor(red: 255,green: 192, blue: 203))
                palette.append(UIColor(red: 255,green: 105, blue: 180))
                
                palette.append(UIColor(red: 199,green: 21, blue: 133))
                
            }
            else{
                palette.append(UIColor(red: 232, green: 246, blue:255))
                palette.append(UIColor(red: 112, green: 172, blue:212))
                palette.append(UIColor(red: 61, green: 122, blue:163))
            }
           var de = BarChartDataEntry(x: Double(idx), yValues: yvals)
            
            dataEntries.append(de)
            
            dates.append(dateFormatterPrint.string(from: dateFormatterGet.date(from: date)!))
            }
            
      print(dates)
        
        var dataSet = BarChartDataSet(entries: dataEntries, label: "")

        dataSet.stackLabels = ["Low Intensity", "Medium Intensity", "High Intensity"]
      
        let chartData = BarChartData(dataSet: dataSet)
        chartData.setDrawValues(false)
        
        barChartView.data = chartData
        barChartView.highlightPerDragEnabled = false
     
            barChartView.highlightFullBarEnabled = false
        barChartView.rightAxis.enabled = false
        
        
        barChartView.fitBars = true
    
        barChartView.doubleTapToZoomEnabled = false
               
        barChartView.chartDescription?.text = ""
        
        dataSet.colors = palette
        dataSet.highlightAlpha = 0.0
         barChartView.xAxis.granularityEnabled = true
                barChartView.xAxis.granularity = 1
//                barChartView.leftAxis.granularity = 1
//                barChartView.leftAxis.granularityEnabled = true
              
                barChartView.xAxis.wordWrapEnabled = true
             barChartView.leftAxis.axisMinimum = 0
        
            barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dates)
            
                
                barChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
                
                barChartView.xAxis.drawGridLinesEnabled = false
                barChartView.leftAxis.drawGridLinesEnabled = false
                barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeOutBack)
        barChartView.xAxis.labelRotationAngle = -45
      barChartView.leftAxis.granularityEnabled = true //to make integer steps
      barChartView.leftAxis.granularity = 1.0
//            lineChartView.leftAxis.min
        barChartView.rightAxis.granularityEnabled = true
        barChartView.rightAxis.granularity = 1.0
                
    }
    
    
    func updateLineChart(lineChartView: LineChartView , logData: [String:Double], addCutoff: Bool, cutoff: Double, hasNote: [String:Bool]) {
                
            
            var dataEntries: [ChartDataEntry] = []
        var cutoffEntries: [ChartDataEntry]  = []
       
       
            
            
            var minVal = 100000.0
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd HH:mm"
            
        print(logData)
            let sortedDates = Array(logData.keys).sorted{
                                           dateFormatterGet.date(from:$0)!.compare(dateFormatterGet.date(from:$1)!) == .orderedAscending
                                       }
            var dates: [String] = []
           
          
             
        var palette: [NSUIColor] = []
      
           
                 var lastIdx = 0
                        
        for (idx,date) in sortedDates.enumerated(){
            let a = ChartDataEntry(x: Double(idx), y: logData[date]!)
                            dataEntries.append(a)
            if addCutoff{
                cutoffEntries.append(ChartDataEntry(x: Double(idx), y:cutoff))
                if cutoff<minVal{
                    minVal = cutoff
                }
            }
                            if logData[date]!<minVal{
                                minVal = logData[date]!
                            }
            dates.append(dateFormatterPrint.string(from:dateFormatterGet.date(from: date)!))
            lastIdx = idx
           
            if !hasNote[date]!{
                palette.append(UIColor(red: 112, green: 172, blue:212))
            }
            else{
                palette.append(UIColor(red: 255,green: 105, blue: 180))
            }
                        }
        print("cnt",Array(sortedDates).count)
        if Array(sortedDates).count < 2{
            cutoffEntries.append(ChartDataEntry(x: Double(lastIdx)+1, y:cutoff))
        }
                        
                      
                        
//                        lineChartView.highlightPerDragEnabled = false
        
        var datasets: [LineChartDataSet] = []
                    
                        let lineDataSet = LineChartDataSet(entries: dataEntries, label: "" )
        datasets.append(lineDataSet)
        if addCutoff{
            let cutoffDataSet = LineChartDataSet(entries: cutoffEntries, label: "")
            cutoffDataSet.lineDashLengths = [10]
            cutoffDataSet.drawCirclesEnabled = false
            datasets.append(cutoffDataSet)
        }
            //            + ": Frequency"
                        
        lineDataSet.formSize = 0
        
                        
        lineDataSet.circleColors = palette
                        lineDataSet.drawCircleHoleEnabled = false
                        lineDataSet.drawValuesEnabled = true
                        
                        let lineData = LineChartData(dataSets: datasets )
                        lineData.setDrawValues(false) //don't display values above the graph
                        lineChartView.data = lineData
                
                        lineChartView.chartDescription?.text = "" //no text in the bottom right corner of the graph
       
                        
                        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dates)
//        lineChartView.fit
        lineChartView.xAxis.wordWrapEnabled = true
        lineChartView.legend.enabled = false
                        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.labelRotationAngle = -45
                        lineChartView.leftAxis.granularityEnabled = true
                        lineChartView.leftAxis.granularity = 1
                        lineChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
                        lineChartView.leftAxis.axisMinimum = max(minVal-1,0)
                        lineChartView.rightAxis.axisMinimum = max(minVal-1,0)
                        lineChartView.xAxis.drawGridLinesEnabled = false
                        lineChartView.leftAxis.drawGridLinesEnabled = false
                        lineChartView.rightAxis.drawGridLinesEnabled = false
                        lineChartView.leftAxis.granularityEnabled = true //to make integer steps
                        lineChartView.leftAxis.granularity = 1.0
            //            lineChartView.leftAxis.min
                        lineChartView.rightAxis.granularityEnabled = true
                        lineChartView.rightAxis.granularity = 1.0
        lineChartView.scaleXEnabled = true
        lineChartView.scaleYEnabled = false
        lineChartView.xAxis.spaceMax = 0.5
        lineChartView.xAxis.spaceMin = 0.5
                        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeOutBack)
                    }
                    
        
    
   
    
}

extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex

        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }

        return indices
    }
}





