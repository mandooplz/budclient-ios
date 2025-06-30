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
    // MARK: core
    @State var authBoardRef: AuthBoard?
    
    
    // MARK: body
    var body: some View {
        ZStack {
            if let signInFormRef = authBoardRef?.signInForm?.ref {
                SignInFormView(signInFormRef)
            }
        }
        .task {
            await authBoardRef?.setUpForms()
        }
    }
}
