//
//  ProjectEditorLabel.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/13/25.
//
import SwiftUI
import BudClient
import Values


// MARK: View
struct ProjectModelLabel: View {
    let projectModelRef: ProjectModel
    init(_ projectModelRef: ProjectModel) {
        self.projectModelRef = projectModelRef
    }
    
    var body: some View {
        EditableTitle(projectModelRef)
            .padding(.horizontal)
    }
}

extension ProjectModelLabel {
    struct EditableTitle: View {
        // MARK: core
        @Bindable var projectModelRef: ProjectModel
        init(_ projectModelRef: ProjectModel) {
            self.projectModelRef = projectModelRef
        }
        
        // MARK: state
        @State private var isEditing = false
        @FocusState private var isTextFieldFocused: Bool
        
        // MARK: body
        var body: some View {
            // isEditing 상태에 따라 Text 또는 TextField를 보여줌
            Group {
                if isEditing {
                    TextField("Enter new name", text: $projectModelRef.nameInput)
                        .textFieldStyle(.plain)
                        .focused($isTextFieldFocused)   // 포커스 상태와 바인딩
                        .onSubmit {
                            // 'Return' 키를 누르면 실행될 액션
                            Task {
                                await projectModelRef.pushName()
                            }
                        }
                } else {
                    Text(projectModelRef.name)
                        .onTapGesture {
                            // 텍스트를 탭하면 편집 모드로 전환
                            // 현재 이름을 text 상태에 복사하여 편집 시작
                            isEditing = true
                            isTextFieldFocused = true // 편집 모드 시작 시 바로 포커스
                        }
                }
            }
            // lifecycle
            .onDisappear {
                Task {
                    await projectModelRef.pushName()
                }
            }
        }
    }
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


