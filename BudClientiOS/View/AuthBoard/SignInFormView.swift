//
//  EmailFormView.swift
//  BudClientiOS
//
//  Created by Assistant.
//
import SwiftUI
import BudClient
import Tools
import GoogleSignIn
import GoogleSignInSwift
import BudServer


// MARK: view
struct SignInFormView: View {
    // MARK: core
    @Bindable var signInFormRef: SignInForm
    init(_ objectRef: SignInForm) {
        self.signInFormRef = objectRef
    }
    
    // MARK: state
    @State private var isSigningIn = false
    @State private var isSigningInByCache = true
    
    
    // MARK: body
    var body: some View {
        VStack(spacing: 20) {
            if !isSigningInByCache {
                Title
                
                EmailField
                PasswordField
                
                SignInButton
                SignInWithGoogleButton
                
                if signInFormRef.isIssueOccurred {
                    IssueLabel
                }
            }
        }
        .padding()
        .task {
            await signInFormRef.signInByCache()
            isSigningInByCache = false
        }
    }
    
    
    // MARK: component
    var Title: some View {
        Text("Sign In")
            .font(.title)
            .bold()
    }
    var EmailField: some View {
        TextField("Email", text: $signInFormRef.email)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    var PasswordField: some View {
        SecureField("Password", text: $signInFormRef.password)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)

    }
    var SignInButton: some View {
        Button(action: {
            Task {
                isSigningIn = true
                await signInFormRef.signIn()
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
    }
    var SignInWithGoogleButton: some View {
        GoogleSignInButton {
            Task {
                guard let (idToken, accessToken) = await signInWithGoogle() else {
                    return
                }
                
                guard let googleFormRef = signInFormRef.authBoard.ref?.googleForm?.ref else { return }
                googleFormRef.idToken = idToken
                googleFormRef.accessToken = accessToken
                await googleFormRef.signIn()
            }
        }
        .frame(height: 50)
        .padding(.bottom, 8)
    }
    var IssueLabel: some View {
        Text(signInFormRef.issue?.reason ?? "Unknown error.")
            .foregroundColor(.red)
            .font(.caption)
    }
    
    // MARK: Helpher
    private func signInWithGoogle() async -> (idToken: String, accessToken: String)? {
        await withCheckedContinuation { continuation in
            guard let budClientRef = signInFormRef
                .authBoard.ref?
                .budClient.ref else {
                return
            }
            
            guard let clientId = budClientRef.budServerLink?.getGoogleClientId() else {
                return
            }
            
            let config = GIDConfiguration(clientID: clientId)
            GIDSignIn.sharedInstance.configuration = config
            
            // 현재 윈도우에서 ViewController 가져오기
            guard let rootViewController = (UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow })?
                .rootViewController else {
                return
            }
            
            // Start the sign in flow!
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                guard error == nil else {
                    print("구글 로그인 과정에서 에러가 발생했습니다.")
                    continuation.resume(returning: nil)
                    return
                }

                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    print("user와 idToken을 가져오는 과정에 에러가 발생했습니다. ")
                    continuation.resume(returning: nil)
                    return
                }
                
                let accessToken = user.accessToken.tokenString
                
                continuation.resume(returning: (idToken, accessToken))
            }
        }
    }
}


private func handleGoogleSignIn() {
}

