//
//  GetterModelLabel.swift
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
struct GetterModelLabel: View {
    // MARK: core
    @Bindable var getterModelRef: GetterModel
    init(_ getterModelRef: GetterModel) {
        self.getterModelRef = getterModelRef
    }
    
    
    // MARK: body
    var body: some View {
        EditableText(
            text: getterModelRef.name,
            textInput: $getterModelRef.nameInput,
            submitHandler: getterModelRef.pushName
        )
        
        // layout
        .padding(.horizontal)
        
        // lifecycle
        .task {
            await getterModelRef.startUpdating()
        }
        
        // action
        .contextMenu {
            Button("복제하기") {
                Task {
                    await getterModelRef.duplicateGetter()
                }
            }
            
            Button("삭제하기") {
                Task {
                    await getterModelRef.removeGetter()
                }
            }
        }
    }
}
