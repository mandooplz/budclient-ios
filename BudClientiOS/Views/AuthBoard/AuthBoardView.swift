//
//  AuthBoardView.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/28/25.
//
import SwiftUI
import BudClient
import Values


// MARK: View
struct AuthBoardView: View {
    // MARK: core
    let authBoardRef: AuthBoard
    init(_ authBoardRef: AuthBoard) {
        self.authBoardRef = authBoardRef
    }
    
    // MARK: body
    var body: some View {
        ZStack {
            if let signInFormRef = authBoardRef.signInForm?.ref {
                SignInFormView(signInFormRef)
            }
        }
        .task {
            await WorkFlow {            
                await authBoardRef.setUpForms()
            }
        }
    }
}


// MARK: Preview
private struct AuthBoardPreview: View {
    let budClientRef = BudClient()
    
    var body: some View {
        if let authBoardRef = budClientRef.authBoard?.ref {
            AuthBoardView(authBoardRef)
        } else {
            BudClientView(budClientRef)
                .task {
                    await budClientRef.setUp()
                }
        }
    }
}


#Preview {
    AuthBoardPreview()
}
