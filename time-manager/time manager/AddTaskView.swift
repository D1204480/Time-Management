//
//  AddTaskView.swift
//  time manager
//
//  Created by YJ Hsu on 2024/11/16.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (Task) -> Void
    
    @State private var title: String = ""
    @State private var dueDate: Date = Date()
    @State private var priority: Task.Priority = .medium
    
    var body: some View {
        NavigationView {
            Form {
                // 任務標題
                Section(header: Text("任務信息")) {
                    TextField("任務標題", text: $title)
                }
                
                // 截止日期
                Section(header: Text("截止日期")) {
                    DatePicker(
                        "選擇日期",
                        selection: $dueDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                // 優先級
                Section(header: Text("優先級")) {
                    Picker("選擇優先級", selection: $priority) {
                        ForEach(Task.Priority.allCases, id: \.self) { priority in
                            HStack {
                                priorityIcon(for: priority)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("新增任務")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 取消按鈕
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                // 添加按鈕
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        let task = Task(
                            title: title,
                            dueDate: dueDate,
                            isCompleted: false,
                            priority: priority
                        )
                        onAdd(task)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    // 優先級圖標
    @ViewBuilder
    private func priorityIcon(for priority: Task.Priority) -> some View {
        switch priority {
        case .high:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
        case .medium:
            Image(systemName: "equal.circle.fill")
                .foregroundColor(.orange)
        case .low:
            Image(systemName: "minus.circle.fill")
                .foregroundColor(.blue)
        }
    }
}

// 預覽
struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView { _ in }
    }
}
