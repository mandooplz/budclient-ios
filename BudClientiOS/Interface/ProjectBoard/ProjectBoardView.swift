//
//  ProjectBoardView.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/30/25.
//
import SwiftUI
import BudClient
import Values
import os


// MARK: View
struct ProjectBoardView: View {
    // MARK: state
    @Bindable var projectBoardRef: ProjectBoard
    init(_ objectRef: ProjectBoard) {
        self.projectBoardRef = objectRef
    }
    private let logger = Logger(subsystem: "BudClient", category: "ProjectBoardView")
    
    // MARK: body
    var body: some View {
        NavigationStack {
            List {
                ForEach(projectBoardRef.editors, id: \.value) { projectId in
                    if let project = projectId.ref {
                        ProjectEditorView(project)
                    } else {
                        Text("Loading...")
                    }
                }
            }
            .task {
                await WorkFlow.create {
                    await projectBoardRef.subscribe()
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await projectBoardRef.createNewProject()
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onDisappear {
                Task {
                    await projectBoardRef.unsubscribe()
                }
            }
        }
    }
}
