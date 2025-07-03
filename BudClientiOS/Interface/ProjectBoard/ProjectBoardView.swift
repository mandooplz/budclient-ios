//
//  ProjectBoardView.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/30/25.
//
import SwiftUI
import BudClient
import Tools
import os


// MARK: View
struct ProjectBoardView: View {
    @Bindable var projectBoardRef: ProjectBoard
    
    init(_ objectRef: ProjectBoard) {
        self.projectBoardRef = objectRef
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(projectBoardRef.projects, id: \.value) { projectId in
                    if let project = projectId.ref {
                        ProjectView(project)
                    } else {
                        Text("Loading...")
                    }
                }
            }
            .task {
                await projectBoardRef.setUpUpdater()
                await projectBoardRef.subscribeProjectHub()
                print("ProjectBoard task 완료")
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await projectBoardRef.createProjectSource()
                            print(projectBoardRef.projects.count)
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onDisappear {
                Task {
                    await projectBoardRef.unsubscribeProjectHub()
                }
            }
        }
    }
}
