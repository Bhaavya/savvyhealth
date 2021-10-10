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
    func requestAuthorization(completion: @escaping  (Bool) -> Void) {
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _  in
            self.fetchNotificationSettings()

          completion(granted)
        }
    }
    
    func fetchNotificationSettings() {
      // 1
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        // 2
        DispatchQueue.main.async {
          self.settings = settings
        }
      }
    }
    
    func scheduleNotification() {

      let content = UNMutableNotificationContent()
      content.title = "How are you feeling today?"
      content.body = "Track your mood now!"
        
        let uuid = UUID().uuidString


  
      var trigger: UNNotificationTrigger?
  
   
      
          trigger = UNTimeIntervalNotificationTrigger(
//            3*60*60*24,
            timeInterval:  3*60*60*24 ,//3 days
            repeats: false)
        
      
      if let trigger = trigger {
        let request = UNNotificationRequest(
          identifier: uuid,
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
