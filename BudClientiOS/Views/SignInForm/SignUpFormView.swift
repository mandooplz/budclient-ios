//
//  SignUpFormView.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/13/25.
//
import SwiftUI
import BudClient
import Values


// MARK: View
struct SignUpFormView: View {
    // MARK: Core
    @Environment(BudClient.self) var budClientRef
    @Bindable var signUpFormRef: SignUpForm
    init(_ signUpFormRef: SignUpForm) {
        self.signUpFormRef = signUpFormRef
    }
    
    @State private var isSigningUp = false
    
    private let buttonCornerRadius: CGFloat = 25
    private let buttonHeight: CGFloat = 50
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Title
            
            EmailField
            PasswordField
            ConfirmPasswordField // 비밀번호 확인 필드 추가
            
            Spacer()
            
            SignUpButton
            
            Spacer()
            
            SignInButton // 로그인 화면으로 돌아가는 버튼 추가
            
            if signUpFormRef.isIssueOccurred {
                IssueLabel
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: Components
extension SignUpFormView {
    var Title: some View {
        Text("Sign Up") // 타이틀 변경
            .font(.title)
            .bold()
    }
    
    var EmailField: some View {
        TextField("Email", text: $signUpFormRef.email)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    var PasswordField: some View {
        SecureField("Password", text: $signUpFormRef.password)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    var ConfirmPasswordField: some View {
        SecureField("Confirm Password", text: $signUpFormRef.passwordCheck)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    
    var SignUpButton: some View {
        Button(action: {
            Task {
                isSigningUp = true
                await signUpFormRef.submit()
                await budClientRef.saveUserInCache()
                isSigningUp = false
            }
        }) {
            ZStack {
                Text("Sign Up")
                    .bold()
                    .opacity(isSigningUp ? 0 : 1)
                
                if isSigningUp {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(buttonCornerRadius)
        }
        .disabled(isSigningUp)
    }
    var SignInButton: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .foregroundColor(.gray)
            
            Button(action: {
                Task {
                    await signUpFormRef.cancel()
                }
            }) {
                Text("Sign In")
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        .font(.footnote)
    }
    
    var IssueLabel: some View {
        Text(signUpFormRef.issue?.reason ?? "Unknown error.")
            .foregroundColor(.red)
            .font(.caption)
    }
}




// MARK: Preview
private struct SignUpFormPreview: View {
    let budClientRef = BudClient()
    
    var body: some View {
        if let signInFormRef = budClientRef.signInForm?.ref {
            SignInFormView(signInFormRef)
                .task {
                    await setUpSignUpForm()
            }
        } else {
            if budClientRef.isUserSignedIn {
                BudClientView(budClientRef)
            } else {
                ProgressView("SignUpFormPreview")
                    .task {
                        await budClientRef.setUp()
                    }
            }
        }
    }
    
    func setUpSignUpForm() async {
        guard let signInFormRef = budClientRef.signInForm?.ref else { return }
        await signInFormRef.setUpSignUpForm()
    }
}

#Preview {
    SignUpFormPreview()
}
