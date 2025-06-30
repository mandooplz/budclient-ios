//
//  BudClientView.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/26/25.
//
import SwiftUI
import BudClient
import Tools


// MARK: View
struct BudClientView: View {
    @Bindable var budClientRef: BudClient
    @State var showAlert: Bool = false

    var body: some View {
        ZStack {
            if budClientRef.isUserSignedIn == false {
                AuthBoardView(authBoardRef: budClientRef.authBoard?.ref)
            } else {
                ProjectBoardView(budClientRef.projectBoard!.ref)
                    .tabItem {
                        Label("Project", systemImage: "folder")
                    }

                CommunityView(budClientRef.community?.ref)
                    .tabItem {
                        Label("Community", systemImage: "person.3")
                    }

                ProfileBoardView(budClientRef.profileBoard?.ref)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
            }
        }
        .task {
            await budClientRef.setUp()
        }
    }
}



// MARK: Component

// MARK: Preview
private struct BudClientPreview: View {
    let budClientRef = BudClient()
    
    var body: some View {
        BudClientView(budClientRef: budClientRef)
    }
}

#Preview {
    BudClientPreview()
}

