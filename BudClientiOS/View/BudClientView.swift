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
            if budClientRef.isUserSignedIn {
                TabView {
                    Text("ProjectBoard")
                        .tabItem {
                            Label("Projects", systemImage: "folder")
                        }
                    Text("ProfileBoard")
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                }
            } else {
                // AuthBoardView
                if budClientRef.authBoard != nil {
                    AuthBoardView(authBoardRef: budClientRef.authBoard!.ref!)
                }
            }
        }
        .task {
            budClientRef.setUp()
        }
        .onChange(of: budClientRef.isIssueOccurred, {
            self.showAlert = true
        })
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Issue"),
                message: Text(budClientRef.issue?.reason ?? ""),
                dismissButton: .default(Text("OK"))
            )
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

