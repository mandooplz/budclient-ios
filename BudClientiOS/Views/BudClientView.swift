//
//  BudClientView.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/26/25.
//
import SwiftUI
import BudClient
import Values


// MARK: View
struct BudClientView: View {
    // MARK: core
    let budClientRef: BudClient
    init(_ budClientRef: BudClient) {
        self.budClientRef = budClientRef
    }
    
    // MARK: state
    @State var showAlert: Bool = false

    // MARK: body
    var body: some View {
        ZStack {
            if budClientRef.isUserSignedIn == false,
               let signInFormRef = budClientRef.signInForm?.ref {
                
                SignInFormView(signInFormRef)
                
            } else if let projectBoardRef = budClientRef.projectBoard?.ref,
                      let communityRef = budClientRef.community?.ref,
                      let profile = budClientRef.profile?.ref {
                
                TabView {
                    Tab("Project", systemImage: "folder") {
                        ProjectBoardView(projectBoardRef)
                    }
                    
                    Tab("Community", systemImage: "person.3") {
                        CommunityView(communityRef)
                    }
                    
                    Tab("Profile", systemImage: "person.crop.circle") {
                        ProfileBoardView(profile)
                    }
                }
                
            } else {
                Text("Error Occurred")
            }
        }
        .task {
            await budClientRef.setUp()
        }
    }
}


// MARK: Preview
private struct BudClientPreview: View {
    let budClientRef = BudClient()
    
    var body: some View {
        BudClientView(budClientRef)
    }
}

#Preview {
    BudClientPreview()
}
