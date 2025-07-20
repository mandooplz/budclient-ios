//
//  SystemModelLavel.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/14/25.
//
import SwiftUI
import BudClient
import Values
import Collections


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
            // lifecycle
            .task {
                await systemModelRef.startUpdating()
            }
            // action
            .contextMenu {
                AddSystemUpButton
                AddSystemDownButton
                AddSystemRightButton
                AddSystemLeftButton
                
                RemoveButton
            }
    }
}


// MARK: Component
extension SystemModelLabel {
    var LabelContent: some View {
        VStack(alignment: .leading) {
            Text(systemModelRef.name)
                .font(.headline)
                .fontWeight(.bold)
                        
            Text("(\(systemModelRef.location.x), \(systemModelRef.location.y))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    var AddSystemUpButton: some View {
        // addSystemUp
        Button {
            Task {
                triggerHapticFeedback()
                await systemModelRef.addSystemTop()
            }
        } label: {
            Label("Add System Top", systemImage: "arrow.up")
        }
    }
    var AddSystemDownButton: some View {
        // addSystemUp
        Button {
            Task {
                triggerHapticFeedback()
                await systemModelRef.addSystemBottom()

            }
        } label: {
            Label("Add System Down", systemImage: "arrow.down")
        }
    }
    var AddSystemLeftButton: some View {
        // addSystemUp
        Button {
            Task {
                triggerHapticFeedback()
                await systemModelRef.addSystemLeft()
            }
        } label: {
            Label("Add System Left", systemImage: "arrow.left")
        }
    }
    var AddSystemRightButton: some View {
        // addSystemUp
        Button {
            Task {
                triggerHapticFeedback()
                await systemModelRef.addSystemRight()
            }
        } label: {
            Label("Add System Right", systemImage: "arrow.right")
        }
    }
    var RemoveButton: some View {
        // remove
        Button(role: .destructive) {
            Task {
                await systemModelRef.removeSystem()
            }
        } label: {
            Label("Remove System", systemImage: "trash")
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
           let projectModelRef = projectBoardRef.projects.values.first?.ref {
            ProjectModelView(projectModelRef)
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
    func createSystemBoard() async {
        // create ProjectEditor
        let projectBoardRef = budClientRef.projectBoard!.ref!
        
        await projectBoardRef.startUpdating()
        await withCheckedContinuation { con in
            Task {
                projectBoardRef.setCallback {
                    con.resume()
                }
                
                await projectBoardRef.createProject()
            }
        }
        
        guard let projectModelRef = projectBoardRef.projects.values.first?.ref else{
            print("ProjectModel을 찾을 수 없습니다.")
            return
        }
        
        
        // create SystemModel
        await projectModelRef.startUpdating()
        await withCheckedContinuation { continuation in
            Task {
                projectModelRef.setCallback {
                    continuation.resume()
                }
                
                await projectModelRef.createFirstSystem()
            }
        }
    }
}

#Preview {
    SystemModelLabelPreview()
}
