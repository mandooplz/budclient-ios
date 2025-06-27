//
//  BudClientiOSApp.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/26/25.
//

import SwiftUI
import BudClient
import Tools


@main
struct BudClientiOSApp: App {
    let budClientRef = BudClient(mode: .real,
                                 plistPath: Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!)
    
    var body: some Scene {
        WindowGroup {
            BudClientView(budClientRef: budClientRef)
        }
    }
}
