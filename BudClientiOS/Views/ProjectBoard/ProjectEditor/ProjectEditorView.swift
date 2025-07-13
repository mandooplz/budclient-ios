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
    // MARK: core
    let projectEditorRef: ProjectEditor
    init(_ projectEditorRef: ProjectEditor) {
        self.projectEditorRef = projectEditorRef
    }
    
    
    // MARK: state
    @Environment(\.dismiss) private var dismiss
    
    
    // MARK: body
    var body: some View {
        ZStack {
            if let systemBoardRef = projectEditorRef.systemBoard?.ref {
                SystemBoardView(systemBoardRef)
            }
        }
        // lifecycle
        .task {
            await WorkFlow {
                await projectEditorRef.setUp()
            }
        }
        
        // navigation
        .navigationTitle(projectEditorRef.name)
    }
}


// MARK: Components
extension ProjectEditorView {
    
}



// MARK: ProjectEditorPreview
private struct ProjectEditorPreview: View {
    let budClientRef = BudClient()
    
    var body: some View {
        if let projectBoardRef = budClientRef.projectBoard?.ref {
            ProjectBoardView(projectBoardRef)
        } else {
            ProgressView("ProjectEditorPreview")
                .task {
                    await signUp()
                    await createProjectEditor()
                }
        }
    }
    
    func signUp() async {
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
    func createProjectEditor() async {
        let projectBoardRef = budClientRef.projectBoard!.ref!
        
        await projectBoardRef.subscribe()
        await projectBoardRef.createNewProject()
    }
}

#Preview { ProjectEditorPreview() }
