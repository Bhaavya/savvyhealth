//
//  NotificationManager.swift
//  Savvy
//
//  Created by Bhavya on 8/21/21.
//  Copyright © 2021 uiuc. All rights reserved.
//


import Foundation
import UserNotifications
import CoreLocation



class NotificationManager {
  static let shared = NotificationManager()
 var settings: UNNotificationSettings?
    
    
    func scheduleNotification() {

      let content = UNMutableNotificationContent()
      content.title = "How are you feeling today?"
      content.body = "Track your mood now!"
        
 


  
      var trigger: UNNotificationTrigger?
  
//
//
//          trigger = UNTimeIntervalNotificationTrigger(
////            3*60*60*24,
//            timeInterval:  3*60*60*24 ,//3 days
//            repeats: false)
        
       
        var dateComponent = DateComponents()
        dateComponent.hour = 12
        dateComponent.minute = 00
        dateComponent.timeZone = .current
        print("dt",dateComponent)
        
        trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        

      
      if let trigger = trigger {
        let request = UNNotificationRequest(
          identifier: UUID().uuidString,
          content: content,
          trigger: trigger)
        // 5
        UNUserNotificationCenter.current().add(request) { error in
          if let error = error {
            print("errorrrr",error)
          }
            print("scheduled")
        }
      }
    }


}
