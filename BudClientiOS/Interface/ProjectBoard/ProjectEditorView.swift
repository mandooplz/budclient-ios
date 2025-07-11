//
//  ProjectView.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/4/25.
//
import SwiftUI
import BudClient
import Values


// MARK: View
struct ProjectEditorView: View {
    let projectEditorRef: ProjectEditor
    init(_ projectEditorRef: ProjectEditor) {
        self.projectEditorRef = projectEditorRef
    }
    
    @State var text: String = ""
    
    var body: some View {
        VStack {
            Text(projectEditorRef.name ?? "Unknown")
            HStack {
                TextField("Enter new name", text: $text)
                
                Button("Push") {
                    Task {
                        projectEditorRef.nameInput = text
                        await projectEditorRef.pushName()
                    }
                }.buttonStyle(.borderedProminent)
                
                Button("Remove") {
                    Task {
                        await projectEditorRef.removeProject()
                    }
                }.buttonStyle(.glassProminent)
            }
            
            
            if let issue = projectEditorRef.issue {
                Text(issue.reason)
                    
            }
        }.task {
            await projectEditorRef.setUp()
        }
    }
}
