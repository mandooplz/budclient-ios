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
                SignIn(budClientRef)
            } else {
                TabView {
                    Tab("Project", systemImage: "folder") {
                        ProjectBoard(budClientRef)
                    }
                    
                    Tab("Community", systemImage: "person.3") {
                        Community(budClientRef)
                    }
                    
                    Tab("Profile", systemImage: "person.crop.circle") {
                        ProfileBoard(budClientRef)
                    }
                }
                
            }
        }
        .task {
            await budClientRef.setUp()
            print("BudClient Task 완료")
        }
    }
}



// MARK: Component
private struct SignIn: View {
    let budClientRef: BudClient
    init(_ budClientRef: BudClient) {
        self.budClientRef = budClientRef
    }
    
    var body: some View {
        if let authBoardRef = budClientRef.authBoard?.ref {
            AuthBoardView(authBoardRef: authBoardRef)
        }
    }
}

private struct ProjectBoard: View {
    let budClientRef: BudClient
    init(_ budClientRef: BudClient) {
        self.budClientRef = budClientRef
    }
    
    var body: some View {
        ZStack {
            if let projectBoardRef = budClientRef.projectBoard?.ref {
                ProjectBoardView(projectBoardRef)
            }
        }
    }
}

private struct Community: View {
    let budClientRef: BudClient
    init(_ budClientRef: BudClient) {
        self.budClientRef = budClientRef
    }
    
    var body: some View {
        ZStack {
            if let communityRef = budClientRef.community?.ref {
                CommunityView(communityRef)
            }
        }
    }
}

private struct ProfileBoard: View {
    let budClientRef: BudClient
    init(_ budClientRef: BudClient) {
        self.budClientRef = budClientRef
    }
    
    var body: some View {
        ZStack {
            if let profileBoardRef = budClientRef.profileBoard?.ref {
                ProfileBoardView(profileBoardRef)
            }
        }
    }
}


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

