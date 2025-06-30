//
//  ProfileBoardView.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/29/25.
//
import SwiftUI
import BudClient
import Tools


// MARK: View
struct ProfileBoardView: View {
    @State var profileBoardRef: ProfileBoard
    
    init(_ objectRef: ProfileBoard) {
        self.profileBoardRef = objectRef
    }
    
    var body: some View {
        VStack {
            Text("ProfileBoardView")
            
            SignOutButton(profileBoardRef)
        }
    }
}


// MARK: Component
private struct SignOutButton: View {
    let profileBoardRef: ProfileBoard
    init(_ objectRef: ProfileBoard) {
        self.profileBoardRef = objectRef
    }
    
    var body: some View {
        Button(action: {
            Task {
                await profileBoardRef.signOut()
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
