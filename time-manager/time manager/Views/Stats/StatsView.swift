//
//  StatsView.swift
//  time manager
//
//  Created by YJ Hsu on 2024/11/16.
//

import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var selectedTimeRange: TimeRange = .week
    @Environment(\.dismiss) private var dismiss
    
    enum TimeRange {
        case day, week, month
        
        var title: String {
            switch self {
            case .day: return "今日"
            case .week: return "本週"
            case .month: return "本月"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                // 時間範圍選擇
                Picker("時間範圍", selection: $selectedTimeRange) {
                    Text("今日").tag(TimeRange.day)
                    Text("本週").tag(TimeRange.week)
                    Text("本月").tag(TimeRange.month)
                }
                .pickerStyle(.segmented)
                .padding(.vertical)
                
                // 總覽卡片
                Section {
                    overviewCards
                }
                
                // 完成情況
                Section(header: Text("任務完成情況")) {
                    completionStatusView
                }
                
                // 時間分配
                Section(header: Text("時間分配")) {
                    timeAllocationChart
                }
                
                // 優先級分布
                Section(header: Text("優先級分布")) {
                    priorityDistributionView
                }
            }
            .navigationTitle("統計報表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // 總覽卡片
    private var overviewCards: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                StatCard(
                    title: "總任務",
                    value: "\(viewModel.tasks.count)",
                    icon: "list.bullet",
                    color: .blue
                )
                
                StatCard(
                    title: "已完成",
                    value: "\(viewModel.completedTasks.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
            
            HStack(spacing: 12) {
                StatCard(
                    title: "總時長",
                    value: formatTime(viewModel.totalTimeSpent),
                    icon: "clock.fill",
                    color: .purple
                )
                
                StatCard(
                    title: "完成率",
                    value: "\(completionRate)%",
                    icon: "chart.pie.fill",
                    color: .orange
                )
            }
        }
    }
    
    // 完成情況視圖
    private var completionStatusView: some View {
        HStack {
            CompletionRing(
                completedCount: viewModel.completedTasks.count,
                totalCount: viewModel.tasks.count
            )
            .frame(width: 100, height: 100)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("完成率：\(completionRate)%")
                    .font(.headline)
                Text("已完成：\(viewModel.completedTasks.count)")
                Text("進行中：\(viewModel.tasks.count - viewModel.completedTasks.count)")
            }
            .padding(.leading)
        }
        .padding(.vertical, 8)
    }
    
    // 時間分配圖表
    private var timeAllocationChart: some View {
        let data = viewModel.tasks.map { task in
            ChartData(
                name: task.title,
                value: task.totalTimeSpent
            )
        }
        
        return Chart(data) { item in
            SectorMark(
                angle: .value("時間", item.value),
                innerRadius: .ratio(0.618),
                angularInset: 1.5
            )
            .cornerRadius(3)
            .foregroundStyle(by: .value("任務", item.name))
        }
        .frame(height: 200)
    }
    
    // 優先級分布視圖
    private var priorityDistributionView: some View {
        VStack(spacing: 12) {
            ForEach(Task.Priority.allCases, id: \.self) { priority in
                HStack {
                    Text(priority.rawValue)
                    
                    Spacer()
                    
                    Text("\(tasksCount(for: priority))")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // 輔助計算
    private var completionRate: Int {
        guard !viewModel.tasks.isEmpty else { return 0 }
        return Int(Double(viewModel.completedTasks.count) / Double(viewModel.tasks.count) * 100)
    }
    
    private func tasksCount(for priority: Task.Priority) -> Int {
        viewModel.tasks.filter { $0.priority == priority }.count
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        return "\(hours)小時\(minutes)分"
    }
}

// 數據模型
private struct ChartData: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
}

// 統計卡片組件
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.secondary)
            }
            .font(.caption)
            
            Text(value)
                .font(.title2)
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// 完成度環形圖組件
struct CompletionRing: View {
    let completedCount: Int
    let totalCount: Int
    
    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.green.opacity(0.2), lineWidth: 10)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            VStack {
                Text("\(Int(progress * 100))")
                    .font(.title2)
                    .bold()
                Text("%")
                    .font(.caption)
            }
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView(viewModel: TaskViewModel())
    }
}
