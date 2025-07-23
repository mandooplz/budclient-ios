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
    }
}


private extension ObjectModelView {
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
            Button(action: {
                Task {
                    await objectModelRef.createChildObject()
                }
            }) {
                Label("Create Child Object", systemImage: "plus")
            }
        }
    }
    private var StatesSection: some View {
        Section(header: Text("States")) {
            Text("States: \(objectModelRef.states.count)")
            
            Button(action: {
                Task { await objectModelRef.appendNewState() }
            }) {
                Label("Append New State", systemImage: "plus.circle")
            }
        }
    }
    private var ActionsSection: some View {
        Section(header: Text("Actions")) {
            Text("Actions: \(objectModelRef.actions.count)")
            Button(action: {
                Task { await objectModelRef.appendNewAction() }
            }) {
                Label("Append New Action", systemImage: "plus.circle")
            }
        }
    }
}
