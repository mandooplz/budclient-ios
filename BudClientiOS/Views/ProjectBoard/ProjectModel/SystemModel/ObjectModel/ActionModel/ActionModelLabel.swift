//
//  ActionModelLabel.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/25/25.
//
import SwiftUI
import BudClient
import BudClientUI
import Collections
import Values


// MARK: View
struct ActionModelLabel: View {
    // MARK: core
    @Bindable var actionModelRef: ActionModel
    init(_ actionModelRef: ActionModel) {
        self.actionModelRef = actionModelRef
    }
    
    // MARK: state
    var body: some View {
        EditableText(
            text: actionModelRef.name,
            textInput: $actionModelRef.nameInput,
            submitHandler: actionModelRef.pushName
        )
        
        // layout
        .padding(.horizontal)
        
        // lifecycle
        .task {
            await actionModelRef.startUpdating()
        }
        
        // action
        .contextMenu {
            Button("복제하기") {
                Task {
                    await actionModelRef.duplicateAction()
                }
            }
            
            Button("삭제하기") {
                Task {
                    await actionModelRef.removeAction()
                }
            }
        }
    }
}



// MARK: Preview

