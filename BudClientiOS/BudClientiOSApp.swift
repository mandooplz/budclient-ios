//
//  BudClientiOSApp.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/26/25.
//
import Foundation
import Collections
import Values
import SwiftUI
import BudClient
import GoogleSignIn
import GoogleSignInSwift


// MARK: App
@main
struct BudClientiOSApp: App {
    let budClientRef = BudClient(plistPath: Bundle.main.path(forResource: "GoogleService-Info",
                                                             ofType: "plist")!,
                                 useEmulator: false)
//    let budClientRef = BudClient()
    
    var body: some Scene {
        WindowGroup {
            BudClientView(budClientRef)
                .environment(budClientRef)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
            
            // forTest
//                .task {
//                    #if DEBUG
//                    await signUp()
//                    await createRootObjectModel()
//                    #endif
//                }
        }
    }
}


// MARK: Helphers
private extension BudClientiOSApp {
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
        
        await signUpFormRef.submit()
    }
    func createRootObjectModel() async {
        // create ProjectModel
        let projectBoardRef = budClientRef.projectBoard!.ref!
        
        await projectBoardRef.startUpdating()
        
        await withCheckedContinuation { continuation in
            Task {
                projectBoardRef.setCallback {
                    continuation.resume()
                }
                
                await projectBoardRef.createProject()
            }
        }
        
        // create SystemModel
        let projectModelRef = budClientRef.projectBoard!.ref!
            .projects.values.first!.ref!
        
        await projectModelRef.startUpdating()
        await withCheckedContinuation { continuation in
            Task {
                projectModelRef.setCallback {
                    continuation.resume()
                }
                
                await projectModelRef.createFirstSystem()
            }
        }
        
        // create ObjectModel
        let systemModelRef = projectModelRef.systemList.first!.ref!
        
        await systemModelRef.startUpdating()
        await withCheckedContinuation { continuation in
            Task {
                systemModelRef.setCallback {
                    continuation.resume()
                }
                
                await systemModelRef.createRootObject()
            }
        }
    }
}

