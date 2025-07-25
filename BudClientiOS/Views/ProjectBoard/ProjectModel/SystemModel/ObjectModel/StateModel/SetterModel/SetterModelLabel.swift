//
//  SetterModelLabel.swift
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
struct SetterModelLabel: View {
    // MARK: core
    @Bindable var setterModelRef: SetterModel
    init(_ setterModelRef: SetterModel) {
        self.setterModelRef = setterModelRef
    }
    
    
    // MARK: body
    var body: some View {
        EditableText(
            text: setterModelRef.name,
            textInput: $setterModelRef.nameInput,
            submitHandler: setterModelRef.pushName
        )
        
        // layout
        .padding(.horizontal)
        
        // lifecycle
        .task {
            await setterModelRef.startUpdating()
        }
        
        // action
        .contextMenu {
            Button("복제하기") {
                Task {
                    await setterModelRef.duplicateSetter()
                }
            }
            
            Button("삭제하기") {
                Task {
                    await setterModelRef.removeSetter()
                }
            }
        }
    }
}

