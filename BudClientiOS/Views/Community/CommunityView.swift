//
//  CommunityView.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/30/25.
//
import SwiftUI
import BudClient
import Values


// MARK: View
struct CommunityView: View {
    let communityRef: Community
    init(_ communityRef: Community) {
        self.communityRef = communityRef
    }
    
    var body: some View {
        Text("Community View")
    }
}



// MARK: Preview
private struct CommunityPreview: View {
    let budClientRef = BudClient()
    var body: some View {
        if let communityRef = budClientRef.community?.ref {
            CommunityView(communityRef)
        } else {
            ProgressView("ProfileBoardPreview")
                .task { await signUp() }
        }
    }
    
    func signUp() async {
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
    CommunityPreview()
}
