//
//  EmailFormView.swift
//  BudClientiOS
//
//  Created by Assistant.
//
import SwiftUI
import BudClient
import Tools


struct EmailFormView: View {
    @Bindable var emailFormRef: EmailForm
    @State private var isSigningIn = false
    
    var body: some View {
        VStack(spacing: 20) {
            emailFormTitle
            
            emailInput
            passwordInput

            
            Button(action: {
                Task {
                    isSigningIn = true
                    await emailFormRef.signIn()
                    isSigningIn = false
                }
            }) {
                if isSigningIn {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                } else {
                    Text("Sign In")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .disabled(isSigningIn)

            if emailFormRef.isIssueOccurred {
                Text(emailFormRef.issue?.reason ?? "Unknown error.")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
        .task {
            await emailFormRef.signInByCache()
        }
    }
    
    
    var emailFormTitle: some View {
        Text("Sign In")
            .font(.title)
            .bold()
    }
    
    var emailInput: some View {
        TextField("Email", text: $emailFormRef.email)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    
    var passwordInput: some View {
        SecureField("Password", text: $emailFormRef.password)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)

    }
}
