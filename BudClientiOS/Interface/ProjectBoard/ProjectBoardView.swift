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
                        Text(project.name)
                    } else {
                        Text("Unknown Project")
                    }
                }
            }
            .task {
                projectBoardRef.setUp()
                await projectBoardRef.startObserving()
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await projectBoardRef.createEmptyProject()
                            print(projectBoardRef.projects.count)
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
