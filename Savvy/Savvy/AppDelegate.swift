//
//  AppDelegate.swift
//  Savvy
//
//  Created by Bhavya on 6/16/20.
//  Copyright © 2020 uiuc. All rights reserved.
//


import UIKit
import Firebase
import DropDown
import IQKeyboardManager
import CoreData
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
 @objc let defaults = UserDefaults.standard
  var window: UIWindow?
func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    if #available(iOS 13.0, *) {
        // In iOS 13 setup is done in SceneDelegate
    } else {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

       
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller:UIViewController = mainstoryboard.instantiateViewController(withIdentifier: "login")
        window.rootViewController = newViewcontroller
        
    }

    return true
    }
  func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions:
    [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    
    UNUserNotificationCenter.current().delegate = self
           
           
           DropDown.startListeningToKeyboard()
    
    IQKeyboardManager.shared().isEnabled = true
    print("app")
    if #available(iOS 13.0, *) {
        print("app3")
        // In iOS 13 setup is done in SceneDelegate
    } else {
         print("app2")
        self.window?.makeKeyAndVisible()
    }
   

   
    return true
  }


    
   
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound,.badge])
        
    }
    
    
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    func remoteLogging(_ parameters:[String:AnyObject]){
        let timestamp = "\(NSDate().timeIntervalSince1970 * 1000)"
        var sendParams :[String:AnyObject] = parameters
        sendParams["ts"] = timestamp as AnyObject
        
     
        let request = AF.request("https://timan.cs.illinois.edu/savvy_logging/", method: HTTPMethod.post, parameters: sendParams, encoding: JSONEncoding.default)
        .responseJSON(completionHandler: { (response) in
            print(3, response)

        })

            
        
        print("2",request)
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if UserDefaults.standard.object(forKey: "userID") != nil{
        let uid = defaults.string(forKey: "userID")
        
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"app"as AnyObject,"action":"toBackground" as AnyObject,"json":[:] as AnyObject]
        remoteLogging(logging_parameters )
  
        print("entering background now")
       
        }
        
    }
    
   
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if UserDefaults.standard.object(forKey: "userID") != nil{
        let uid = defaults.string(forKey: "userID")
        
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"app"as AnyObject,"action":"fromBackground" as AnyObject,"json":[:] as AnyObject]
        remoteLogging(logging_parameters )
            UNUserNotificationCenter.current()
              .removeAllPendingNotificationRequests()
          
            NotificationManager.shared.scheduleNotification()
            
                 
                     
              
       
        }
        print("coming back", defaults.bool(forKey: "fromNotification"))
       
        
    }
    
   
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        print("exiting app now")
       
    }
    
    // MARK: - Core Data stack

       lazy var persistentContainer: NSPersistentContainer = {
           /*
            The persistent container for the application. This implementation
            creates and returns a container, having loaded the store for the
            application to it. This property is optional since there are legitimate
            error conditions that could cause the creation of the store to fail.
           */
           let container = NSPersistentContainer(name: "Savvy")
        let descriptor = NSPersistentStoreDescription()
        descriptor.url =  NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Savvy.sqlite")
        descriptor.type = NSSQLiteStoreType
        descriptor.shouldAddStoreAsynchronously = false
        descriptor.setOption(FileProtectionType.complete as NSObject, forKey: NSPersistentStoreFileProtectionKey)
        container.persistentStoreDescriptions = [descriptor]
           container.loadPersistentStores(completionHandler: { (storeDescription, error) in
               if let error = error as NSError? {
                   // Replace this implementation with code to handle the error appropriately.
                   // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                   /*
                    Typical reasons for an error here include:
                    * The parent directory does not exist, cannot be created, or disallows writing.
                    * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                    * The device is out of space.
                    * The store could not be migrated to the current model version.
                    Check the error message to determine what the actual problem was.
                    */
                   fatalError("Unresolved error \(error), \(error.userInfo)")
               }
            do {
                               guard var storeUrl = descriptor.url else { throw fatalError("Bad URL") }
                               var resourceValues = URLResourceValues()
                               resourceValues.isExcludedFromBackup = true
                               try storeUrl.setResourceValues(resourceValues)
                           } catch {
                               fatalError("Failed to setup security for data store. \(error)")
                           }
           })
           return container
       }()

       // MARK: - Core Data Saving support

       func saveContext () {
           let context = persistentContainer.viewContext
           if context.hasChanges {
               do {
                   try context.save()
               } catch {
                   // Replace this implementation with code to handle the error appropriately.
                   // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                   let nserror = error as NSError
                   fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
               }
           }
       }
    
    

    
    
}

extension AppDelegate{
    
  // This function will be called right after user tap on the notification
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    
    
    UserDefaults.standard.set(true,forKey: "fromNotification")
  
    guard let window = UIApplication.shared.keyWindow else { return }

    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let logVC = storyboard.instantiateViewController( withIdentifier: "login")
       
       let navController = UINavigationController(rootViewController: logVC)
       navController.modalPresentationStyle = .fullScreen
    window.rootViewController = navController
    window.makeKeyAndVisible()
    
   
        print("from not")
    completionHandler()
  }
    
}


