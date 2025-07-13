//
//  ProjectEditorLabel.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/13/25.
//
import SwiftUI
import BudClient
import Values


// MARK: View
struct ProjectEditorLabel: View {
    let projectEditorRef: ProjectEditor
    init(_ projectEditorRef: ProjectEditor) {
        self.projectEditorRef = projectEditorRef
    }
    
    var body: some View {
        Text(projectEditorRef.name)
    }
}
