//
//  LocalNotificationManager.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 26/11/20.
//

import Foundation
import UserNotifications
import UIKit


struct LocalNotification {
    var id: String
    var title: String
    var body: String
}

/// For repeating push notification has to be more than 60 seconds
enum LocalNotificationDurationType {
    case days
    case hours
    case minutes
    case seconds
}

struct LocalNotificationManager {
    
    /// list of notifications - Once we want more than one notifications
    static private var notifications = [LocalNotification]()
    
    static private func requestPermission() -> Void {
        // need to import UserNotification
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .alert]) { granted, error in
                if granted == true && error == nil {
                    // We have permission!
                }
        }
    }
    
    /// Appending on the appending notificaiton array above
    static private func addNotification(title: String, body: String) -> Void {
        notifications.append(LocalNotification(id: UUID().uuidString, title: title, body: body))
    }
    
    /// Schedule the notificaiton, with repeats, with user info
    static private func scheduleNotifications(_ durationInSeconds: Int, repeats: Bool, userInfo: [AnyHashable : Any]) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        /// going through all the notificaitons and create a content
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound = UNNotificationSound.default
            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
            content.userInfo = userInfo
            
            /// creating the trigger
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(durationInSeconds), repeats: repeats)
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            /// removing all notification requests
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else { return }
                print("Scheduling notification with id: \(notification.id)")
            }
        }
        notifications.removeAll()
    }
    
    /// Helping function = for set notification
    static private func scheduleNotifications(_ duration: Int, of type: LocalNotificationDurationType, repeats: Bool, userInfo: [AnyHashable : Any]) {
        var seconds = 0
        switch type {
        case .seconds:
            seconds = duration
        case .minutes:
            seconds = duration * 60
        case .hours:
            seconds = duration * 60 * 60
        case .days:
            seconds = duration * 60 * 60 * 24
        }
        scheduleNotifications(seconds, repeats: repeats, userInfo: userInfo)
    }
    
    static func cancel() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    static func setNotification(_ duration: Int, of type: LocalNotificationDurationType, repeats: Bool, title: String, body: String, userInfo: [AnyHashable : Any]) {
        requestPermission()
        addNotification(title: title, body: body)
        scheduleNotifications(duration, of: type, repeats: repeats, userInfo: userInfo)
    }

}
