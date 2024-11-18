//
//  TimeEntry.swift
//  time manager
//
//  Created by YJ Hsu on 2024/11/16.
//

import Foundation

struct TimeEntry: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    
    init(id: UUID = UUID(), startTime: Date, endTime: Date) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
    }
}

extension TimeEntry {
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    // 判斷是否在特定日期內
    func isIn(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(startTime, inSameDayAs: date)
    }
    
    // 判斷是否在特定週內
    func isInWeek(of date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(startTime, equalTo: date, toGranularity: .weekOfYear)
    }
    
    // 判斷是否在特定月內
    func isInMonth(of date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(startTime, equalTo: date, toGranularity: .month)
    }
}
