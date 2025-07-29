//
//  GetterModelView.swift
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
struct GetterModelView: View {
    // MARK: core
    @Bindable var getterModelRef: GetterModel
    init(_ getterModelRef: GetterModel) {
        self.getterModelRef = getterModelRef
        self.parameterInput = getterModelRef.parameterInput
    }
    
    // MARK: state
    @State var parameterInput: [ParameterValue]
    
    
    // MARK: body
    var body: some View {
        List {
            Parameters
            Result
        }
        // navigation
        .navigationTitle(getterModelRef.name)
        .toolbar { EditButton() }
        
        // lifecycle
        .onChange(of: parameterInput) { _, newValue in
            Task {
                getterModelRef.parameterInput = newValue
                await getterModelRef.pushParameterValues()
            }
        }
        .onDisappear {
            Task {
                getterModelRef.parameterInput = self.parameterInput
                await getterModelRef.pushParameterValues()
            }
        }
    }
}


// MARK: Component
private extension GetterModelView {
    var Parameters: some View {
        Section{
            ForEach(parameterInput, id: \.self) { parameter in
                Text("\(parameter.name)")
            }
            // edit state
            .onDelete { indexSet in
                indexSet.forEach { index in
                    self.parameterInput.remove(at: index)
                }
            }
            .onMove { source, destination in
                parameterInput.move(fromOffsets: source, toOffset: destination)
            }
            
        } header: {
            Text("Parameters")
        }
    }
    
    var Result: some View {
        Section {
            Text("\(getterModelRef.result.debugDescription)")
        } header: {
            Text("Result")
        }
    }
}
