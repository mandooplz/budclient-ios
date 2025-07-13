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
    // MARK: core
    @Bindable var projectBoardRef: ProjectBoard
    init(_ objectRef: ProjectBoard) {
        self.projectBoardRef = objectRef
    }
    
    // MARK: state
    
    
    // MARK: body
    var body: some View {
        NavigationStack {
            List {
                ForEach(projectBoardRef.editors, id: \.value) { projectEditor in
                    NavigationLink(value: projectEditor) {
                        if let projectEditorRef = projectEditor.ref {
                            ProjectEditorLabel(projectEditorRef)
                        }
                    }
                }
                // edit list
                .onDelete { projectEditorSet in
                    Task {
                        await WorkFlow {
                            for projectEditor in projectEditorSet {
                                await projectBoardRef.editors[projectEditor].ref?.removeProject()
                            }
                        }
                    }
                }
            }
            // lifecycle
            .task {
                await WorkFlow {
                    await projectBoardRef.subscribe()
                }
            }
            
            // navigation
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task {
                            await WorkFlow {
                                await projectBoardRef.createNewProject()
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: ProjectEditor.ID.self) { projectEditor in
                if let projectEditorRef = projectEditor.ref {
                    ProjectEditorView(projectEditorRef)
                }
            }
            
        }
    }
}


// MARK: Component
extension ProjectBoardView {
}


// MARK: Preview
private struct ProjectBoardPreview: View {
    @State var budClientRef = BudClient()
    
    var body: some View {
        if let projectBoardRef = budClientRef.projectBoard?.ref {
            ProjectBoardView(projectBoardRef)
        } else {
            ProgressView("is loading...")
                .task { await setUp() }
        }
    }
    
    func setUp() async {
        await budClientRef.setUp()
        let authBoardRef = budClientRef.authBoard!.ref!
        
        await authBoardRef.setUpForms()
        let signInFormRef = authBoardRef.signInForm!.ref!
        
        await signInFormRef.setUpSignUpForm()
        let signUpFormRef = signInFormRef.signUpForm!.ref!
        let testEmail = Email.random().value
        let testPassword = Password.random().value
        await MainActor.run {
            signUpFormRef.email = testEmail
            signUpFormRef.password = testPassword
            signUpFormRef.passwordCheck = testPassword
        }
        
        await signUpFormRef.signUp()
    }
}


#Preview {
    ProjectBoardPreview()
}
