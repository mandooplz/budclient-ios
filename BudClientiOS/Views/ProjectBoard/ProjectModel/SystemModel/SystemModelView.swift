//
//  SystemModelView.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/14/25.
//
import SwiftUI
import Values
import BudClient
import Collections


// MARK: View
struct SystemModelView: View {
    // MARK: core
    let systemModelRef: SystemModel
    init(_ systemModelRef: SystemModel) {
        self.systemModelRef = systemModelRef
    }
    
    // MARK: state
    
    
    // MARK: body
    var body: some View {
        ZStack {
            if systemModelRef.objects.isEmpty {
                EmptyObjectView
            } else {
                ObjectListView
            }
        }
        // lifecycle
        .task {
            await systemModelRef.startUpdating()
        }
        
        // navigation
        .navigationTitle(systemModelRef.name)
        .navigationDestination(for: ObjectModel.ID.self) { objectModel in
            if objectModel.isExist {
                ObjectModelView(systemModelRef, objectModel.ref!)
            }
        }
        
        
    }
}

extension SystemModelView {
    private var ObjectListView: some View {
        List {
            ForEach(systemModelRef.objects.values, id: \.value) { objectModel in
                NavigationLink(value: objectModel) {
                    if let objectModelRef = objectModel.ref {
                        ObjectModelLabel(objectModelRef)
                    }
                }
            }
            // edit Feature
            .onDelete { indexSet in
                for index in indexSet {
                    Task {
                        await systemModelRef.objects.values[index].ref?.removeObject()
                    }
                }
            }
        }
    }
    private var EmptyObjectView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("객체가 없습니다")
                .font(.title)
                .fontWeight(.bold)
            
            Text("새로운 객체를 추가해보세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // 첫 번째 루트 객체를 생성하는 버튼입니다.
            Button {
                Task { await systemModelRef.createRootObject() }
            } label: {
                Label("첫 객체 생성", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)      
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // VStack이 전체 공간을 차지하도록 함
    }
}



// MARK: Preview
private struct SystemModelPreview: View {
    let budClientRef = BudClient()
    
    var body: some View {
        if let projectBoardRef = budClientRef.projectBoard?.ref,
           let projectModelRef = projectBoardRef.projects.values.first?.ref,
           let systemModelRef = projectModelRef.systems.values.first?.ref {
            SystemModelView(systemModelRef)
        } else {
            ProgressView("SystemModelPreview")
                .task {
                    await signUp()
                    await createSystemModel()
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
    func createSystemModel() async {
        // create ProjectModel
        let projectBoardRef = budClientRef.projectBoard!.ref!
        
        await projectBoardRef.startUpdating()
        
        await withCheckedContinuation { continuation in
            Task {
                projectBoardRef.setCallback {
                    continuation.resume()
                }
                
                await projectBoardRef.createProject()
            }
        }
        
        // create SystemModel
        let projectModelRef = budClientRef.projectBoard!.ref!
            .projects.values.first!.ref!
        
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
    SystemModelPreview()
}
