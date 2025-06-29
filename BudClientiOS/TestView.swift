//
//  TestView.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/28/25.
//
import Foundation
import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


struct TestView: View {
    @State private var isSignedIn = false
    
    var body: some View {
        VStack {
            if isSignedIn {
                Text("로그인 성공!")
            } else {
                GoogleSignInButton {
                    handleSignIn()
                }
                .frame(width: 200, height: 50)
            }
        }
    }
}

private func handleSignIn() {
    print("출력합니다.")
}


#Preview {
    TestView()
}

