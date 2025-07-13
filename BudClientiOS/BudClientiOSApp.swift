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


// MARK: Application
@main
struct BudClientiOSApp: App {
//    let budClientRef = BudClient(plistPath: Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!)
    let budClientRef = BudClient()
    
    var body: some Scene {
        WindowGroup {
            BudClientView(budClientRef)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
