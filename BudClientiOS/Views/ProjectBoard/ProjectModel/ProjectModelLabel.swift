//
//  ProjectEditorLabel.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/13/25.
//
import SwiftUI
import BudClient
import BudClientUI
import Values


// MARK: View
struct ProjectModelLabel: View {
    @Bindable var projectModelRef: ProjectModel
    init(_ projectModelRef: ProjectModel) {
        self.projectModelRef = projectModelRef
    }
    
    var body: some View {
        EditableText(text: projectModelRef.name,
                     textInput: $projectModelRef.nameInput,
                     submitHandler: projectModelRef.pushName )
            .padding(.horizontal)
    }
}

extension ProjectModelLabel {
    
}


// MARK: Preview
private struct ProjectEditorLabelPreview: View {
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
        let signInFormRef = budClientRef.signInForm!.ref!
        
        await signInFormRef.setUpSignUpForm()
        let signUpFormRef = signInFormRef.signUpForm!.ref!
        let testEmail = Email.random().value
        let testPassword = Password.random().value
        await MainActor.run {
            signUpFormRef.email = testEmail
            signUpFormRef.password = testPassword
            signUpFormRef.passwordCheck = testPassword
        }
        
        await signUpFormRef.submit()
    }
    func createProjectEditor() async {
        let projectBoardRef = budClientRef.projectBoard!.ref!
        
        await projectBoardRef.startUpdating()
        await projectBoardRef.createProject()
    }
}


#Preview { ProjectEditorLabelPreview() }


