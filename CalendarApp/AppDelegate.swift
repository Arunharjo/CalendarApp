//
//  AppDelegate.swift
//  CalendarApp
//
//  Created by Arun on 13/05/22.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
          if settings.authorizationStatus == .authorized {
            // Notifications are allowed
              print("allowed")
          } else {
            // Either denied or notDetermined
              print("not allowed")
          }
        }
        registerForPushNotifications(application: application)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func scheduleNotification(at date: Date, title: String, body: String, id: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm a"
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let requests = (UIApplication.shared.scheduledLocalNotifications ?? [])
        print("Notification count",requests.count)
            
                let calendar = Calendar(identifier: .gregorian)
                let components = calendar.dateComponents(in: .current, from: date)
               
                let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
                let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = UNNotificationSound.default
                content.categoryIdentifier = "Medication_Category"
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                UNUserNotificationCenter.current().delegate = self
                UNUserNotificationCenter.current().add(request) {(error) in
                                print("request",request)
                    if let error = error {
                        print("Uh oh! We had an error: \(error)")
                    }
                }
    }
    
    func registerForPushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { [weak self] (granted, error) in
            if (granted) {
                DispatchQueue.main.async {
                    UNUserNotificationCenter.current().delegate = self
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        })
    }
}
