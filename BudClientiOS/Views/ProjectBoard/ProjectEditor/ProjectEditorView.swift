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
    
    
    // MARK: body
    var body: some View {
        VStack {
            HStack {
                EditableTitle(projectEditorRef)
                
                Spacer()
                
                Button("Remove") {
                    Task {
                        await WorkFlow {
                            await projectEditorRef.removeProject()
                        }
                    }
                }.buttonStyle(.glassProminent)
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
    struct EditableTitle: View {
        // MARK: core
        let projectEditorRef: ProjectEditor
        init(_ projectEditorRef: ProjectEditor) {
            self.projectEditorRef = projectEditorRef
        }
        
        // MARK: state
        @State var text: String = ""
        @State private var isEditing = false
        @FocusState private var isTextFieldFocused: Bool
        
        // MARK: body
        var body: some View {
            // isEditing 상태에 따라 Text 또는 TextField를 보여줌
                        if isEditing {
                            TextField("Enter new name", text: $text)
                                .textFieldStyle(.plain)
                                .font(.title3)
                                .focused($isTextFieldFocused)   // 포커스 상태와 바인딩
                                .onSubmit {
                                    // 'Return' 키를 누르면 실행될 액션
                                    Task {
                                        await WorkFlow {
                                            await projectEditorRef.setNameInput(text)
                                            await projectEditorRef.pushName()
                                        }
                                    }
                                }
                                .padding(.horizontal)
                        } else {
                            Text(projectEditorRef.name)
                                .font(.title3)
                                .padding()
                                .onTapGesture {
                                    // 텍스트를 탭하면 편집 모드로 전환
                                    // 현재 이름을 text 상태에 복사하여 편집 시작
                                    text = projectEditorRef.name
                                    isEditing = true
                                    isTextFieldFocused = true // 편집 모드 시작 시 바로 포커스
                                }
                        }
        }
    }
}



// MARK: ProjectEditorPreview
private struct ProjectEditorPreview: View {
    let budClientRef = BudClient()
    private let logger = WorkFlow.getLogger(for: "ProjectEditorPreview")
    
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
