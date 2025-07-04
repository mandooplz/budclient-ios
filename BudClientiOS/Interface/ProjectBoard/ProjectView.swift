//
//  ProjectView.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/4/25.
//
import SwiftUI
import BudClient
import Tools


// MARK: View
struct ProjectView: View {
    let projectRef: Project
    init(_ projectRef: Project) {
        self.projectRef = projectRef
    }
    
    @State var text: String = ""
    
    var body: some View {
        VStack {
            Text(projectRef.name ?? "Unknown")
            HStack {
                TextField("Enter new name", text: $text)
                
                Button("Push") {
                    Task {
                        projectRef.name = text
                        await projectRef.push()
                    }
                }.buttonStyle(.borderedProminent)
                
                Button("Remove") {
                    Task {
                        await projectRef.removeSource()
                    }
                }.buttonStyle(.glassProminent)
            }
            if let issue = projectRef.issue {
                Text(issue.reason)
                    .tint(.red)
            }
        }.task {
            await projectRef.setUpUpdater()
            await projectRef.subscribeSource()
            print("Project task 완료")
        }.onDisappear {
            Task {
                print("ProjectView가 사라집니다.")
                await projectRef.unsubscribeSource()
            }
        }
    }
}
