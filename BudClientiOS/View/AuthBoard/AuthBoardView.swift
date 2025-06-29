//
//  AuthBoardView.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/28/25.
//
import SwiftUI
import BudClient


// MARK: View
struct AuthBoardView: View {
    @State var authBoardRef: AuthBoard
    
    var body: some View {
        ZStack {
            if let signInFormRef = authBoardRef.signInForm?.ref {
                EmailFormView(signInFormRef: signInFormRef)
            }
        }
        .task {
            await authBoardRef.setUpForms()
        }
    }
}
