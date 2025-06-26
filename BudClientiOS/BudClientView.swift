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
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    BudClientView()
}
