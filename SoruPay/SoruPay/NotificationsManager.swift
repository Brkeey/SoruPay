//
//  NotificationsManager.swift
//  SoruPay
//
//  Created by Berke  on 5.10.2024.
//

// NotificationsManager.swift

import Foundation
import UserNotifications

class NotificationsManager: ObservableObject {
    static let shared = NotificationsManager()

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Bildirim izni hatası: \(error.localizedDescription)")
            }
        }
    }

    func scheduleWeeklyNotification(for soru: Soru) {
        let content = UNMutableNotificationContent()
        content.title = "Haftalık Soru Tekrarı"
        content.body = "Kütüphanenize eklediğiniz \(soru.ders) dersine ait soruyu tekrar gözden geçirin."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 7 // Pazar günü
        dateComponents.hour = 10 // Saat 10:00

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim ekleme hatası: \(error.localizedDescription)")
            }
        }
    }
}

