//
//  SystemModelLavel.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/14/25.
//
import SwiftUI
import BudClient
import Values


// MARK: View
struct SystemModelLabel: View {
    // MARK: core
    @Bindable var systemModelRef: SystemModel
    init(_ systemModelRef: SystemModel) {
        self.systemModelRef = systemModelRef
    }
    
    
    // MARK: state
    
    
    // MARK: body
    var body: some View {
        LabelContent
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .overlay(addButton(for: .top))
            .overlay(addButton(for: .bottom))
            .overlay(addButton(for: .leading))
            .overlay(addButton(for: .trailing))
            // MARK: iOS 최적화 3. 컨텍스트 메뉴 추가
            .contextMenu {
                // 이름 변경, 복제 등 추가 액션을 넣을 수 있습니다.
                Button(role: .destructive) {
                    Task {
                        await systemModelRef.remove()
                        // Board에서 실제 데이터 제거 로직 호출 필요
                    }
                } label: {
                    Label("Remove System", systemImage: "trash")
                }
            }
    }
}


// MARK: Component
extension SystemModelLabel {
    var LabelContent: some View {
        VStack(spacing: 4) {
            Text(systemModelRef.name)
                .font(.headline)
                .fontWeight(.bold)
                        
            Text("(\(systemModelRef.location.x), \(systemModelRef.location.y))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private func addButton(for edge: Edge) -> some View {
        ZStack(alignment: .center) {
            Color.clear // 전체 영역을 차지하여 alignment가 동작하도록 함
            
            Button(action: {
                // MARK: iOS 최적화 2. 햅틱 피드백 호출
                triggerHapticFeedback()
                
                Task {
                    await performAddAction(for: edge)
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .tint) // .blue 대신 .accentColor 사용
                    .background(Circle().fill(.white))
            }
            .buttonStyle(.plain)
            // MARK: iOS 최적화 1. onHover 제거, 버튼을 항상 보이도록 함
        }
    }
    
    /// 방향에 맞는 모델 액션을 실행하는 헬퍼 함수
    private func performAddAction(for edge: Edge) async {
        switch edge {
        case .top:    await systemModelRef.addSystemTop()
        case .bottom: await systemModelRef.addSystemBottom()
        case .leading: await systemModelRef.addSystemLeft()
        case .trailing: await systemModelRef.addSystemRight()
        }
    }
    
    /// 중간 세기의 햅틱 피드백을 생성하는 함수
    private func triggerHapticFeedback() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
    }
}




// MARK: Preview
private struct SystemModelLabelPreview: View {
    let budClientRef = BudClient()
    
    var body: some View {
        if let projectBoardRef = budClientRef.projectBoard?.ref,
           let projectEditorRef = projectBoardRef.editors.first?.ref,
           let systemBoardRef = projectEditorRef.systemBoard?.ref {
            SystemBoardView(systemBoardRef)
        } else {
            ProgressView("SystemModelLabelPreview")
                .task {
                    await signUp()
                    await createSystemBoard()
                }
        }
        Text("SystemModelLabelPreview")
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
        
        guard let systemBoardRef = projectEditorRef.systemBoard?.ref else {
            print("SystemBoard를 찾을 수 없습니다.")
            return
        }
        
        // create SystemModel
        await withCheckedContinuation { continuation in
            Task {
                systemBoardRef.setCallback {
                    continuation.resume()
                }
                
                await systemBoardRef.subscribe()
                await systemBoardRef.createFirstSystem()
            }
        }
        
        await systemBoardRef.unsubscribe()
        systemBoardRef.setCallback { }
        await systemBoardRef.subscribe()
    }
}

#Preview {
    SystemModelLabelPreview()
}
