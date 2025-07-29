//
//  ObjectModelView.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/23/25.
//
import SwiftUI
import Values
import Collections
import BudClient
import BudClientUI


// MARK: View
struct ObjectModelView: View {
    // MARK: core
    let systemModelRef: SystemModel
    @Bindable var objectModelRef: ObjectModel
    init(_ systemModelRef: SystemModel, _ objectModelRef: ObjectModel) {
        self.systemModelRef = systemModelRef
        self.objectModelRef = objectModelRef
    }
    
    // MARK: state
    
    
    // MARK: body
    var body: some View {
        Form {
            RoleSection
            
            if objectModelRef.role == .node {
                if let objectModel = systemModelRef.objects[objectModelRef.parent],
                   let objectModelRef = objectModel.ref {
                    Section(header: Text("Parent Object")) {
                        Text(objectModelRef.name)
                    }
                }
            }
            
            ChildObjectsSection
            StatesSection
            ActionsSection
        }
        
        // navigation
        .navigationTitle(objectModelRef.name)
        .navigationDestination(for: StateModel.ID.self) { stateModel in
            if let stateModelRef = stateModel.ref {
                StateModelView(stateModelRef)
            }
        }
        .navigationDestination(for: ActionModel.ID.self) { actionModel in
            if let actionModelRef = actionModel.ref {
                ActionModelView(actionModelRef)
            }
        }
    }
}


private extension ObjectModelView {
    private var RoleSection: some View {
        Section(header: Text("Role")) {
            Text(objectModelRef.role.rawValue.uppercased())
                .bold()
        }
    }
    private var ChildObjectsSection: some View {
        // MARK: 자식 객체 섹션
        Section(header: Text("Child Objects")) {
            if objectModelRef.childs.isEmpty {
                Text("No child objects exist.")
                    .foregroundColor(.secondary)
            } else {
                // 각 자식 객체로 이동하는 네비게이션 링크를 생성합니다.
                ForEach(objectModelRef.childs, id: \.value) { object in
                    if let objectModel = systemModelRef.objects[object],
                       let chileObjectModelRef = objectModel.ref {
                        Text(chileObjectModelRef.name)
                    }
                    
                }
            }
            
            // 새로운 자식 객체를 생성하는 버튼입니다.
            Button {
                Task { await objectModelRef.createChildObject()}
            } label: {
                Label("Create Child Object", systemImage: "plus")
            }
        }
    }
    private var StatesSection: some View {
        Section(header: Text("States")) {
            ForEach(objectModelRef.states.values, id: \.value) { stateModel in
                NavigationLink(value: stateModel) {
                    if let stateModelRef = stateModel.ref {
                        StateModelLabel(stateModelRef)
                    }
                }
            }
            // remove Button
            .onDelete { indexSet in
                for index in indexSet {
                    Task { await objectModelRef.states.values[index].ref?.removeState() }
                }
            }
            
            Button {
                Task { await objectModelRef.appendNewState() }
            } label: {
                Label("Append New State", systemImage: "plus.circle")
            }
        }
    }
    private var ActionsSection: some View {
        Section(header: Text("Actions")) {
            ForEach(objectModelRef.actions.values, id: \.value) { actionModel in
                NavigationLink(value: actionModel) {
                    if let actionModelRef = actionModel.ref {
                        ActionModelLabel(actionModelRef)
                    }
                }
            }
            // remove Button
            .onDelete { indexSet in
                for index in indexSet {
                    Task { await objectModelRef.actions.values[index].ref?.removeAction() }
                }
            }
            
            Button {
                Task { await objectModelRef.appendNewAction() }
            } label: {
                Label("Append New Action", systemImage: "plus.circle")
            }
        }
    }
}


// MARK: Preview
private struct ObjectModelPreview: View {
    let budClientRef = BudClient()
    
    var body: some View {
        if let projectBoardRef = budClientRef.projectBoard?.ref,
           let projectModelRef = projectBoardRef.projects.values.first?.ref,
           let systemModelRef = projectModelRef.systemList.first?.ref,
           let rootObjectModelRef = systemModelRef.root?.ref {
            ObjectModelView(systemModelRef, rootObjectModelRef)
        } else {
            ProgressView("SystemModelPreview")
                .task {
                    await signUp()
                    await createRootObjectModel()
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
    func createRootObjectModel() async {
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
        
        // create ObjectModel
        let systemModelRef = projectModelRef.systemList.first!.ref!
        
        await systemModelRef.startUpdating()
        await withCheckedContinuation { continuation in
            Task {
                systemModelRef.setCallback {
                    continuation.resume()
                }
                
                await systemModelRef.createRootObject()
            }
        }
    }
}

#Preview { ObjectModelPreview() }
