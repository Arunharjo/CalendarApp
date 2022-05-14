//
//  Date+Extension.swift
//  CalendarApp
//
//  Created by Arun on 14/05/22.
//

import UIKit

extension Date {
    func removeSeconds() -> Date {
        let timeInterval = floor(self.timeIntervalSinceReferenceDate / 60.0) * 60.0
        return Date(timeIntervalSinceReferenceDate: timeInterval)
    }
    
    func minus(minutes: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .minute, value: -minutes, to: self)!
    }
    
    func convertTimeToMinute(date: Date) -> Int {
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: date)
        let hour = comp.hour ?? 0
        let minute = comp.minute ?? 0
        print(hour)
        let finalMinut:Int = (hour * 60) + minute
        return finalMinut
    }
}
