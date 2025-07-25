//
//  StateModelLabel.swift
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
struct StateModelLabel: View {
    // MARK: core
    @Bindable var stateModelRef: StateModel
    init(_ stateModelRef: StateModel) {
        self.stateModelRef = stateModelRef
    }
    
    
    // MARK: body
    var body: some View {
        EditableText(
            text: stateModelRef.name,
            textInput: $stateModelRef.nameInput,
            submitHandler: stateModelRef.pushName
        )
        
        // layout
        .padding(.horizontal)
        
        // lifecycle
        .task {
            await stateModelRef.startUpdating()
        }
        
        // action
        .contextMenu {
            Button("복제하기") {
                Task {
                    await stateModelRef.duplicateState()
                }
            }
            
            Button("삭제하기") {
                Task {
                    await stateModelRef.removeState()
                }
            }
        }
    }
}
