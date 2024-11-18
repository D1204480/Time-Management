//
//  TaskRow.swift
//  time manager
//
//  Created by YJ Hsu on 2024/11/16.
//

import SwiftUI

struct TaskRow: View {
    let task: Task
    let onUpdate: (Task) -> Void
    let onStartTracking: (Task) -> Void
    let onStopTracking: (Task) -> Void
    
    @State private var timeSpent: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 標題和優先級
            HStack {
                Button(action: {
                    var updatedTask = task
                    updatedTask.isCompleted.toggle()
                    onUpdate(updatedTask)
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .green : .gray)
                }
                
                Text(task.title)
                    .strikethrough(task.isCompleted)
                
                Spacer()
                
                priorityBadge
            }
            
            // 日期和時間
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                Text(task.dueDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // 計時控制和顯示
            HStack {
                if task.isTracking {
                    Text(formatTimeInterval(timeSpent))
                        .font(.caption)
                        .monospacedDigit()
                    
                    Spacer()
                    
                    Button(action: {
                        stopTimer()
                        onStopTracking(task)
                    }) {
                        Label("停止", systemImage: "stop.circle.fill")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.bordered)
                } else {
                    Text(formatTimeInterval(task.totalTimeSpent))
                        .font(.caption)
                        .monospacedDigit()
                    
                    Spacer()
                    
                    Button(action: {
                        startTimer()
                        onStartTracking(task)
                    }) {
                        Label("開始", systemImage: "play.circle.fill")
                            .foregroundColor(.green)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            timeSpent = task.totalTimeSpent
            if task.isTracking {
                startTimer()
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private var priorityBadge: some View {
        Text(task.priority.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(priorityColor.opacity(0.2))
            .foregroundColor(priorityColor)
            .cornerRadius(4)
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .blue
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeSpent = task.totalTimeSpent + Date().timeIntervalSince(task.currentStartTime ?? Date())
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// 預覽視圖
struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TaskRow(
                task: Task(
                    title: "示例任務",
                    dueDate: Date(),
                    priority: .medium
                ),
                onUpdate: { _ in },
                onStartTracking: { _ in },
                onStopTracking: { _ in }
            )
        }
    }
}
