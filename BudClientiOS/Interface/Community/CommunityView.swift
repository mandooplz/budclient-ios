//
//  CommunityView.swift
//  BudClientiOS
//
//  Created by 김민우 on 6/30/25.
//
import SwiftUI
import BudClient
import Tools


// MARK: View
struct CommunityView: View {
    @State var communityRef: Community?
    
    init(_ communityRef: Community?) {
        self.communityRef = communityRef
    }
    
    var body: some View {
        if let communityRef {        
            Text("Community View")
        }
    }
}
