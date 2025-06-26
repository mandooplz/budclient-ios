//
//  BudClientView.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/26/25.
//
import SwiftUI
import BudClient
import Tools


struct BudClientView: View {
    @State var budClientRef = BudClient(mode: .real,
                                        plistPath: Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!)
    @State private var isShowingIssueAlert = false
    
    var body: some View {
        TabView {
            Text("Auth")
                .tabItem {
                    Label("Auth", systemImage: "person")
                }
            Text("Project")
                .tabItem {
                    Label("Projects", systemImage: "folder")
                }
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .task {
            budClientRef.setUp()
            
            if budClientRef.issue != nil {
                isShowingIssueAlert = true
            }
        }
        .alert(isPresented: $isShowingIssueAlert) {
            Alert(
                title: Text("Issue"),
                message: Text(budClientRef.issue?.reason ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    BudClientView()
}

