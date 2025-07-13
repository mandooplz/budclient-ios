//
//  SystemBoardView.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/14/25.
//
import SwiftUI
import BudClient
import Values
import Collections


// MARK: View
struct SystemBoardView: View {
    // MARK: core
    let systemBoardRef: SystemBoard
    init(_ systemBoardRef: SystemBoard) {
        self.systemBoardRef = systemBoardRef
    }
    
    // MARK: state
    
    // MARK: body
    var body: some View {
        Group {
            if systemBoardRef.models.isEmpty {
                EmptySystemView {
                    Task {
                        await WorkFlow {
                            await systemBoardRef.createFirstSystem()
                        }
                    }
                }
            } else {
                SystemModelList
            }
        }
        // lifecycke
        .task {
            await systemBoardRef.subscribe()
        }
        
        // navigation
        .navigationDestination(for: SystemModel.ID.self) { systemModel in
            if systemModel.isExist {
                SystemModelView(systemModel.ref!)
            }
        }
    }
}

extension SystemBoardView {
    var SystemModelList: some View {
        List {
            ForEach(systemBoardRef.models.values, id: \.value) { systemModel in
                NavigationLink(value: systemModel) {
                    if systemModel.isExist {
                        SystemModelLabel(systemModel.ref!)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    Task {
                        await WorkFlow {
                            await systemBoardRef.createFirstSystem()
                        }
                    }
                }) {
                    Image(systemName: "plus")
                }
            }
        }
    }
    func EmptySystemView(_ action: @Sendable @escaping () -> Void) -> some View {
        VStack(spacing: 20) {
            Spacer() // 컨텐츠를 중앙으로 밀어올림
            
            // 시각적 상징성을 위한 아이콘
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            // 안내 문구
            Text("시스템이 없습니다")
                .font(.title)
                .fontWeight(.bold)
            
            Text("새로운 시스템을 추가하여 프로젝트 설계를 시작하세요.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // "첫 시스템 생성" 버튼
            Button(action: action) {
                Label("첫 시스템 생성", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent) // 눈에 띄는 버튼 스타일
            .padding(.top)
            
            Spacer() // 컨텐츠를 중앙으로 밀어내림
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // VStack이 전체 공간을 차지하도록 함
    }
}


// MARK: Preview
private struct SystemBoardPreview: View {
    let budClientRef = BudClient()
    
    var body: some View {
        if let projectBoardRef = budClientRef.projectBoard?.ref,
           let projectEditorRef = projectBoardRef.editors.first?.ref,
           let systemBoardRef = projectEditorRef.systemBoard?.ref {
            NavigationStack {
                SystemBoardView(systemBoardRef)
            }
        } else {
            ProgressView("SystemBoardPreview")
                .task {
                    await signUp()
                    await createSystemBoard()
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
    func createSystemBoard() async {
        // create ProjectEditor
        let projectBoardRef = budClientRef.projectBoard!.ref!
        
        await withCheckedContinuation { con in
            Task {
                projectBoardRef.setCallback {
                    con.resume()
                }
                
                await projectBoardRef.subscribe()
                await projectBoardRef.createNewProject()
            }
        }
        
        await projectBoardRef.unsubscribe()
        projectBoardRef.setCallback { }
        await projectBoardRef.subscribe()
        
        guard let projectEditorRef = projectBoardRef.editors.first?.ref else{
            print("ProjectEditor를 찾을 수 없습니다.")
            return
        }
        
        
        // create SystemBoard
        await projectEditorRef.setUp()
    }
}


#Preview {
    SystemBoardPreview()
}
