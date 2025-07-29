//
//  SetterModelView.swift
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
struct SetterModelView: View {
    // MARK: state
    @Bindable var setterModelRef: SetterModel
    init(_ setterModelRef: SetterModel) {
        self.setterModelRef = setterModelRef
        self.parameterInput = setterModelRef.parameterInput
    }
    
    // MARK: state
    @State private var parameterInput: [ParameterValue]
    
    
    // MARK: body
    var body: some View {
        List {
            Parameters
        }
        // navigation
        .navigationTitle(setterModelRef.name)
        .toolbar { EditButton() }
        
        // lifecycle
        .onChange(of: parameterInput) { _, newValue in
            Task {
                setterModelRef.parameterInput = newValue
                await setterModelRef.pushParameterValues()
            }
        }
        .onDisappear {
            Task {
                setterModelRef.parameterInput = self.parameterInput
                await setterModelRef.pushParameterValues()
            }
        }
    }
}


// MARK: Components
private extension SetterModelView {
    var Parameters: some View {
        Section{
            ForEach(setterModelRef.parameters, id: \.self) { parameter in
                Text("\(parameter.name)")
            }
            // edit state
            .onDelete { indexSet in
                indexSet.forEach { index in
                    self.parameterInput.remove(at: index)
                }
            }
            .onMove { source, destination in
                self.parameterInput.move(fromOffsets: source, toOffset: destination)
                
                Task {
                    parameterInput.move(fromOffsets: source, toOffset: destination)
                }
            }
        } header: {
            Text("Parameters")
        }
    }
}

