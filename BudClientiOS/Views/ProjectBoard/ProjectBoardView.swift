//
//  ProjectBoardView.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/30/25.
//
import SwiftUI
import BudClient
import Values
import Collections


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
                ForEach(projectBoardRef.projects.values, id: \.value) { projectModel in
                    NavigationLink(value: projectModel as ProjectModel.ID) {
                        if let projectModelRef = projectModel.ref {
                            ProjectModelLabel(projectModelRef)
                        }
                    }
                }
                // edit list
                .onDelete { indexSet in
                    for index in indexSet {
                        Task {
                            await projectBoardRef.projects.values[index].ref?.removeProject()
                        }
                    }
                }
            }
            // lifecycle
            .task {
                await projectBoardRef.startUpdating()
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
                            await projectBoardRef.createProject()
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: ProjectModel.ID.self) { projectModel in
                if let projectModelRef = projectModel.ref {
                    ProjectModelView(projectModelRef)
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
}


#Preview {
    ProjectBoardPreview()
}
