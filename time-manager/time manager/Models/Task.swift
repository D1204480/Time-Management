//
//  Task.swift
//  time manager
//
//  Created by YJ Hsu on 2024/11/16.
//

import Foundation

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var dueDate: Date
    var isCompleted: Bool
    var priority: Priority
    var timeEntries: [TimeEntry]
    var isTracking: Bool
    var currentStartTime: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        dueDate: Date,
        isCompleted: Bool = false,
        priority: Priority = .medium,
        timeEntries: [TimeEntry] = [],
        isTracking: Bool = false,
        currentStartTime: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.priority = priority
        self.timeEntries = timeEntries
        self.isTracking = isTracking
        self.currentStartTime = currentStartTime
    }
    
    enum Priority: String, Codable, CaseIterable {
        case high = "高"
        case medium = "中"
        case low = "低"
    }
}

// 計算屬性擴展
extension Task {
    var totalTimeSpent: TimeInterval {
        let completedEntriesTime = timeEntries.reduce(0) { $0 + $1.duration }
        if let startTime = currentStartTime {
            return completedEntriesTime + Date().timeIntervalSince(startTime)
        }
        return completedEntriesTime
    }
    
    // 添加一些便利方法
    mutating func startTracking() {
        isTracking = true
        currentStartTime = Date()
    }
    
    mutating func stopTracking() {
        guard let startTime = currentStartTime else { return }
        
        let timeEntry = TimeEntry(
            startTime: startTime,
            endTime: Date()
        )
        timeEntries.append(timeEntry)
        
        isTracking = false
        currentStartTime = nil
    }
    
    // 獲取特定時間範圍內的時間記錄
    func timeEntries(in dateRange: ClosedRange<Date>) -> [TimeEntry] {
        timeEntries.filter { entry in
            dateRange.contains(entry.startTime)
        }
    }
    
    // 計算特定時間範圍內的總時間
    func totalTimeSpent(in dateRange: ClosedRange<Date>) -> TimeInterval {
        timeEntries(in: dateRange).reduce(0) { $0 + $1.duration }
    }
}
