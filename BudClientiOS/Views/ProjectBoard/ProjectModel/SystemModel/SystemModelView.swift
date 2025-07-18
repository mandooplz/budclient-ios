//
//  SystemModelView.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/14/25.
//
import SwiftUI
import Values
import BudClient


// MARK: View
struct SystemModelView: View {
    // MARK: core
    let systemModelRef: SystemModel
    init(_ systemModelRef: SystemModel) {
        self.systemModelRef = systemModelRef
    }
    
    // MARK: state
    
    
    // MARK: body
    var body: some View {
        Text("SystemModelView")
    }
}

extension SystemModelView {
    
}



// MARK: Preview
private struct SystemModelPreview: View {
    let budClientRef = BudClient()
    
    var body: some View {
        Text("SystemModelPrewview")
    }
}

#Preview {
    SystemModelPreview()
}
