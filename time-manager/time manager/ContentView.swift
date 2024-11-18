//
//  ContentView.swift
//  time manager
//
//  Created by YJ Hsu on 2024/11/16.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var showingAddTask = false
    @State private var showingStats = false  // 添加這行來控制統計視圖的顯示
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.tasks) { task in
                    TaskRow(task: task,
                           onUpdate: { viewModel.updateTask($0) },
                           onStartTracking: { viewModel.startTracking($0) },
                           onStopTracking: { viewModel.stopTracking($0) })
                }
                .onDelete { viewModel.deleteTasks(at: $0) }
            }
            .navigationTitle("時間管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // 添加統計報表按鈕
                    Button(action: { showingStats = true }) {
                        Image(systemName: "chart.bar.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView { task in
                    viewModel.addTask(task)
                }
            }
            // 添加這個 sheet 來顯示統計報表
            .sheet(isPresented: $showingStats) {
                StatsView(viewModel: viewModel)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
