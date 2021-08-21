//
//  SearchViewController.swift
//  Savvy
//
//  Created by Bhavya on 6/20/20.
//  Copyright © 2020 uiuc. All rights reserved.
//

import Foundation
import UIKit
import SwiftSpinner
import Alamofire



@IBDesignable
class CardView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 5
    var  url: String!
    @IBOutlet weak var title:UILabel!
    @IBOutlet weak var subtitle:UILabel!
    
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.5
    

    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)

        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
    
   
    
    }


class searchCell: UITableViewCell{
    @IBOutlet weak var card:CardView!
}

class searchViewController: UIViewController{
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//           return 240
//       }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("----------",results.count)
//        return results.count
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    if(segue.identifier == "searchToArticle") {
//
//        let nextViewController = (segue.destination as! ArticleViewController)
//        nextViewController.url = self.articleUrl
//        }}
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! searchCell
//        self.articleUrl = cell.card.url
//
//        if self.articleUrl != ""{
//
//        self.performSegue(withIdentifier: "searchToArticle", sender: self)
//        if let selectionIndexPath = tableView.indexPathForSelectedRow {
//            tableView.deselectRow(at: selectionIndexPath, animated: true)
//        }
//        }
//    }
//    func getAttirbutedSnippet(snippet: String) -> NSAttributedString{
//        var htmlSnippet = snippet
//        var retString:NSAttributedString!
//        htmlSnippet = snippet.replacingOccurrences(of: "<em>", with: "<b>")
//        htmlSnippet = htmlSnippet.replacingOccurrences(of: "</em>", with: "</b>")
//
//        let modifiedFont = String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(15)\">%@</span>", htmlSnippet)
//        let attrStr = try! NSAttributedString(
//        data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!,
//        options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue],
//        documentAttributes: nil)
//
//        retString = attrStr
//        return retString
//
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult", for: indexPath) as! searchCell
//
//
//        print(cell,cell.card)
//
//        cell.card.title.text = results[indexPath.row]["title"] ?? ""
//        cell.card.subtitle.attributedText = getAttirbutedSnippet(snippet: results[indexPath.row]["snippet"] ?? "")
//
////        cell.card.url = "http://timan.centralus.cloudapp.azure.com/static/pmc_raw/PMC2211717/97-0582.pdf"
//        cell.card.url = "http://timan.centralus.cloudapp.azure.com/static/pmc_raw" + results[indexPath.row]["pdf"]!
//        print(cell.card.title,cell.card.subtitle)
//
//               return cell
//
//    }
//
//
//    @objc var progress = -1
//    @objc let defaults = UserDefaults.standard
//
    var minScale:CGFloat = 1.0
var maxScale:CGFloat = 5.0
    var cumulativeScale:CGFloat = 1.0
    var isZoom = false
//    var articleUrl :String!
//    @IBOutlet weak var tableView:UITableView!
//    @IBOutlet weak var tableHeight: NSLayoutConstraint!
//
//    var results: [[String:String]] = []
//
//    @IBOutlet weak var searchBar: UISearchBar!
//    var prevTranslation:CGPoint!
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//       let parameters: [String: String] = [
//
//        "searchString" : searchBar.text ?? "",
//
//       ]
//        self.results = []
//
//        SwiftSpinner.show("Fetching Results")
////        results = [["pdf":"/PMC149349/1471-2105-4-5.pdf","snippet":"A: 10 train-<em>test</em> runs, B: 25 train-<em>test</em> runs, C: 50 train-<em>test</em> runs, D: 100 train-<em>test</em> runs, E: 500 train-<em>test</em> ... A: 10 train-<em>test</em> runs, B: 25 train-<em>test</em> runs, C: 50 train-<em>test</em> runs, D: 100 train-<em>test</em> runs, E: 500 train-<em>test</em> ... A: 10 train-<em>test</em> runs, B: 25 train-<em>test</em> runs, C: 50 train-<em>test</em> runs, D: 100 train-<em>test</em> runs, E: 500 train-<em>test</em> ... train-<em>test</em> runs, F: 600 train-<em>test</em> runs, G: 700 train-<em>test</em> runs, H: 800 train-<em>test</em> runs, I: 900 train-<em>test</em> ... train-<em>test</em> runs, F: 600 train-<em>test</em> runs, G: 700 train-<em>test</em> runs, H: 800 train-<em>test</em> runs, I: 900 train-<em>test</em>","title":"Genomic data sampling and its effect on classification performance assessment"],["pdf":"/PMC2657218/1471-2288-9-4.pdf","snippet":"True disease status and <em>Test</em> 1 results. <em>Test</em> 1 is + if the score on <em>Test</em> 1 is greater than x. ... True disease status and <em>Test</em> 2 results. <em>Test</em> 2 is + if the score on <em>Test</em> 1 is greater than x. ... Observed disease status and <em>Test</em> 1 results. <em>Test</em> 1 is + if the score on <em>Test</em> 1 is greater than x. ... <em>Test</em> 1. ... <em>Test</em> 2 and <em>Test</em> 1 is positive (<em>Test</em> 2 true AUC 2013 <em>Test</em> 1 true AUC = 0.70 - 0.64 = 0.06).","title":"Bias in trials comparing paired continuous tests can cause researchers to choose the wrong screening modality"],["pdf":"/PMC2657218/1471-2288-9-4.pdf","snippet":"True disease status and <em>Test</em> 1 results. <em>Test</em> 1 is + if the score on <em>Test</em> 1 is greater than x. ... True disease status and <em>Test</em> 2 results. <em>Test</em> 2 is + if the score on <em>Test</em> 1 is greater than x. ... Observed disease status and <em>Test</em> 1 results. <em>Test</em> 1 is + if the score on <em>Test</em> 1 is greater than x. ... <em>Test</em> 1. ... <em>Test</em> 2 and <em>Test</em> 1 is positive (<em>Test</em> 2 true AUC 2013 <em>Test</em> 1 true AUC = 0.70 - 0.64 = 0.06).","title":"Bias in trials comparing paired continuous tests can cause researchers to choose the wrong screening modality"]]
//
////        adjustHeight()
////       self.tableView.reloadData()
////        self.ta/bleView.isHidden = false
//
//    AF.request("http://timan.centralus.cloudapp.azure.com/search", method: .post,parameters: parameters, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
//    .responseJSON { response in
//        switch response.result {
//        case .success(let results):
//            print("Validation Successful")
//            let searchResults = results as! NSDictionary
//            for (idx,res) in (searchResults["results"] as! NSArray).enumerated(){
////                NSDictionary
////            print(res1["pdf"])
//                if idx == 0{
//                    continue
//                }
//                self.results.append(res as! [String:String])
//            }
////            print(results)
//
////
//        case let .failure(error):
//            print(error)
//            SwiftSpinner.hide()
//        }
//
//        if self.results.count == 0{
//            self.results = [["pdf":"","snippet":"","title":"No results found"]]
//        }
//        self.tableView.reloadData()
//        self.tableView.isHidden = false
//        SwiftSpinner.hide()
//
//
//        }
        
//    }
   
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
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(_ sender: UIButton) {
    if let nvc = navigationController {
        nvc.popViewController(animated: true)
    } else {
        dismiss(animated: true, completion: nil)
    }
    }
}
