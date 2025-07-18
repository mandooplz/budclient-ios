//
//  ProfileBoardView.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/29/25.
//
import SwiftUI
import BudClient
import Values


// MARK: View
struct ProfileBoardView: View {
    // MARK: core
    let profileBoardRef: ProfileBoard
    init(_ profileBoardRef: ProfileBoard) {
        self.profileBoardRef = profileBoardRef
    }
    
    
    // MARK: body
    var body: some View {
        VStack {
            Text("ProfileBoardView")
            
            SignOutButton
        }
    }
}

extension ProfileBoardView {
    var SignOutButton: some View {
        Button(action: {
            Task {
                await WorkFlow {
                    await profileBoardRef.signOut()
                }
            }
        }) {
            Text("Sign Out")
                .bold()
                .foregroundColor(.white)
                .padding(.horizontal, 36)
                .padding(.vertical, 12)
                .background(
                    Capsule().fill(Color.blue)
                )
        }
        .padding(.top, 24)
    }
}


// MARK: Preview
private struct ProfileBoardPreview: View {
    let budClientRef = BudClient()
    var body: some View {
        if let profileBoardRef = budClientRef.profileBoard?.ref {
            ProfileBoardView(profileBoardRef)
        } else {
            if budClientRef.isUserSignedIn {
                BudClientView(budClientRef)
            } else {
                ProgressView("ProfileBoardPreview")
                    .task { await setUp() }
            }
        }
    }
    
    func setUp() async {
        await budClientRef.setUp()
        let signInFormRef = budClientRef.signInForm!.ref!
        
        await signInFormRef.setUpSignUpForm()
        let signUpFormRef = signInFormRef.signUpForm!.ref!
        let testEmail = Email.random().value
        let testPassword = Password.random().value
        await MainActor.run {
            signUpFormRef.email = testEmail
            signUpFormRef.password = testPassword
            signUpFormRef.passwordCheck = testPassword
        }
        
        await signUpFormRef.signUp()
    }
}


#Preview {
    ProfileBoardPreview()
}
