//
//  ProjectModelView.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/4/25.
//
import SwiftUI
import BudClient
import Values
import Collections


// MARK: View
struct ProjectModelView: View {
    // MARK: core
    let projectModelRef: ProjectModel
    init(_ projectModelRef: ProjectModel) {
        self.projectModelRef = projectModelRef
    }
    
    
    // MARK: state
    @Environment(\.dismiss) private var dismiss
    
    
    // MARK: body
    var body: some View {
        ZStack {
            if projectModelRef.systemList.isEmpty {
                EmptySystemView {
                    Task {
                        await projectModelRef.createFirstSystem()
                    }
                }
            } else {
                SystemModelList
            }
        }
        // lifecycle
        .task {
            await projectModelRef.startUpdating()
        }

        // navigation
        .navigationTitle(projectModelRef.name)
        .navigationDestination(for: SystemModel.ID.self) { systemModel in
            if systemModel.isExist {
                SystemModelView(systemModel.ref!)
            }
        }
    }
}


// MARK: Components
extension ProjectModelView {
    var SystemModelList: some View {
        List {
            ForEach(projectModelRef.systemList, id: \.value) { systemModel in
                NavigationLink(value: systemModel) {
                    if systemModel.isExist {
                        SystemModelLabel(systemModel.ref!)
                    }
                }
            }
            // remove Button
            .onDelete { indexSet in
                for index in indexSet {
                    Task { await projectModelRef.systemList[index].ref?.removeSystem() }
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



// MARK: ProjectEditorPreview
private struct ProjectModelPreview: View {
    let budClientRef = BudClient()
    
    var body: some View {
        if let projectBoardRef = budClientRef.projectBoard?.ref {
            ProjectBoardView(projectBoardRef)
        } else {
            ProgressView("ProjectEditorPreview")
                .task {
                    await signUp()
                    await createProjectModel()
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
    func createProjectModel() async {
        let projectBoardRef = budClientRef.projectBoard!.ref!
        
        await projectBoardRef.startUpdating()
        await projectBoardRef.createProject()
    }
}

#Preview { ProjectModelPreview() }
