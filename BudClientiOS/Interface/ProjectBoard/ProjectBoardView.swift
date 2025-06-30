//
//  ProjectBoardView.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/30/25.
//
import SwiftUI
import BudClient
import Tools


// MARK: View
struct ProjectBoardView: View {
    var projectBoardRef: ProjectBoard
    
    init(_ objectRef: ProjectBoard) {
        self.projectBoardRef = objectRef
    }
    
    var body: some View {
        Text("This is ProjectBoard")
    }
}
