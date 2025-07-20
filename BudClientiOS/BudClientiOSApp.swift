//
//  BudClientiOSApp.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/26/25.
//
import Foundation
import SwiftUI
import BudClient
import Values
import GoogleSignIn
import GoogleSignInSwift


// MARK: App
@main
struct BudClientiOSApp: App {
    let budClientRef = BudClient(plistPath: Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!)
//    let budClientRef = BudClient()
    
    var body: some Scene {
        WindowGroup {
            BudClientView(budClientRef)
                .environment(budClientRef)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
            
            // forTest
                .task {
//                    #if DEBUG
//                    await signUp(budClientRef)
//                    #endif
                }
        }
    }
}


// MARK: Helphers
private func signUp(_ budClientRef: BudClient) async {
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
    
    await signUpFormRef.submit()
}
