//
//  ObjectModelLabel.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/23/25.
//
import SwiftUI
import BudClient
import BudClientUI
import Values
import Collections


// MARK: View
struct ObjectModelLabel: View {
    // MARK: core
    @Bindable var objectModelRef: ObjectModel
    init(_ objectModelRef: ObjectModel) {
        self.objectModelRef = objectModelRef
    }
    
    
    // MARK: state
    
    
    // MARK: body
    var body: some View {
        EditableText(text: objectModelRef.name,
                     textInput: $objectModelRef.nameInput,
                     submitHandler: objectModelRef.pushName )
        // layout
        .padding(.horizontal)
        
        // lifecycke
        .task {
            await objectModelRef.startUpdating()
        }
        
        // action
        .contextMenu {
            Button("자식 객체 생성") {
                Task {
                    await objectModelRef.createChildObject()
                }
            }
            
            Button("삭제하기") {
                Task {
                    await objectModelRef.removeObject()
                }
            }
        }
    }
}
