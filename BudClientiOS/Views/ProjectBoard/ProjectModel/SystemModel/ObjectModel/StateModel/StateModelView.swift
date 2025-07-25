//
//  StateModelView.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/25/25.
//
import SwiftUI
import BudClient
import BudClientUI
import Values
import Collections


// MARK: View
struct StateModelView: View {
    // MARK: core
    @Bindable var stateModelRef: StateModel
    init(_ stateModelRef: StateModel) {
        self.stateModelRef = stateModelRef
        self.accessLevel = stateModelRef.accessLevel
    }
    
    
    // MARK: state
    @State var accessLevel: AccessLevel
    
    
    // MARK: body
    var body: some View {
        Form {
            AccessLevelPicker
            
            GetterModels
            SetterModels
        }
        
        // navigation
        .navigationTitle($stateModelRef.nameInput)
        .navigationDestination(for: GetterModel.ID.self) {
            if let getterModelRef = $0.ref {
                GetterModelView(getterModelRef)
            }
        }
        .navigationDestination(for: SetterModel.ID.self) {
            if let setterModelRef = $0.ref {
                SetterModelView(setterModelRef)
            }
        }
    }
}

// MARK: Component
private extension StateModelView {
    var AccessLevelPicker: some View {
        Picker("AccessLevel", selection: $accessLevel) {
            ForEach(AccessLevel.allCases, id: \.self) {
                Text($0.rawValue)
            }
        }.onChange(of: accessLevel) { oldValue, newValue in
            Task {
                stateModelRef.accessLevelInput = newValue
                await stateModelRef.pushAccessLevel()
            }
        }
    }
    
    var GetterModels: some View {
        Section {
            ForEach(stateModelRef.getters.values, id: \.value) { getterModel in
                NavigationLink(value: getterModel) {
                    if let getterModelRef = getterModel.ref {
                        GetterModelLabel(getterModelRef)
                    }
                }
            }
            // remove Button
            .onDelete { indexSet in
                for index in indexSet {
                    Task { await stateModelRef.getters.values[index].ref?.removeGetter() }
                }
            }
            
            Button {
                Task { await stateModelRef.appendNewGetter() }
            } label: {
                Label("Append New Getter", systemImage: "plus.circle")
            }
        } header: {
            Text("Getter")
        }
    }
    var SetterModels: some View {
        Section {
            ForEach(stateModelRef.setters.values, id: \.value) { setterModel in
                NavigationLink(value: setterModel) {
                    if let setterModelRef = setterModel.ref {
                        SetterModelLabel(setterModelRef)
                    }
                }
            }
            // remove Button
            .onDelete { indexSet in
                for index in indexSet {
                    Task { await stateModelRef.setters.values[index].ref?.removeSetter() }
                }
            }
            
            Button {
                Task { await stateModelRef.appendNewSetter() }
            } label: {
                Label("Append New Setter", systemImage: "plus.circle")
            }

        } header: {
            Text("Setter")
        }
    }
}


// MARK: Preview
private struct StateModelPreview: View {
    let budClientRef = BudClient()
    
    var body: some View {
        Text("StateModelPreview")
    }
}
