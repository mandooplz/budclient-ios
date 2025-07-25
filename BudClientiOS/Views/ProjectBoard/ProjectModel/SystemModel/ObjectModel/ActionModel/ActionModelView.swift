//
//  ActionModelView.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/25/25.
//
import SwiftUI
import Collections
import Values
import BudClient
import BudClientUI


// MARK: View
struct ActionModelView: View {
    // MARK: core
    @Bindable var actionModelRef: ActionModel
    init(_ actionModelRef: ActionModel) {
        self.actionModelRef = actionModelRef
    }
    
    // MARK: body
    var body: some View {
        Text("ActionModelView")
    }
}



// MARK: Preview
private struct ActionModelPreview: View {
    let budClientRef = BudClient()
    
    var body: some View {
        Text("ActionModelPreview")
    }
}

#Preview { ActionModelPreview() }
