//
//  TaskViewModel.swift
//  time manager
//
//  Created by YJ Hsu on 2024/11/16.
//

import Foundation
import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    
    init() {
        loadTasks()
    }
    
    // CRUD 操作
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func deleteTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }
    
    // 任務追踪
    func startTracking(_ task: Task) {
        var updatedTask = task
        updatedTask.startTracking()
        updateTask(updatedTask)
    }
    
    func stopTracking(_ task: Task) {
        var updatedTask = task
        updatedTask.stopTracking()
        updateTask(updatedTask)
    }
    
    // 任務篩選
    var inProgressTasks: [Task] {
        tasks.filter { !$0.isCompleted }
    }
    
    var completedTasks: [Task] {
        tasks.filter { $0.isCompleted }
    }
    
    // 統計
    var totalTasksCount: Int {
        tasks.count
    }
    
    var completedTasksCount: Int {
        completedTasks.count
    }
    
    var totalTimeSpent: TimeInterval {
        tasks.reduce(0) { $0 + $1.totalTimeSpent }
    }
    
    // 持久化
    private func saveTasks() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(tasks)
            UserDefaults.standard.set(data, forKey: "tasks")
        } catch {
            print("保存任務失敗: \(error.localizedDescription)")
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks") {
            do {
                let decoder = JSONDecoder()
                tasks = try decoder.decode([Task].self, from: data)
            } catch {
                print("讀取任務失敗: \(error.localizedDescription)")
            }
        }
    }
    
    // 時間範圍統計
    func tasksForDate(_ date: Date) -> [Task] {
        let calendar = Calendar.current
        return tasks.filter { task in
            calendar.isDate(task.dueDate, inSameDayAs: date)
        }
    }
    
    func timeSpentInRange(from startDate: Date, to endDate: Date) -> TimeInterval {
        let filteredTasks = tasks.filter { task in
            task.timeEntries.contains { entry in
                entry.startTime >= startDate && entry.endTime <= endDate
            }
        }
        
        return filteredTasks.reduce(0) { total, task in
            total + task.timeEntries
                .filter { $0.startTime >= startDate && $0.endTime <= endDate }
                .reduce(0) { $0 + $1.duration }
        }
    }
    
    // 優先級統計
    func tasksForPriority(_ priority: Task.Priority) -> [Task] {
        tasks.filter { $0.priority == priority }
    }
    
    func timeSpentByPriority(_ priority: Task.Priority) -> TimeInterval {
        tasksForPriority(priority).reduce(0) { $0 + $1.totalTimeSpent }
    }
}
