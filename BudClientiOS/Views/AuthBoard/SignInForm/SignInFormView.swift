//
//  EmailFormView.swift
//  BudClientiOS
//
//  Created by Assistant.
//
import SwiftUI
import BudClient
import Values
import GoogleSignIn
import GoogleSignInSwift
import BudServer


// MARK: view
struct SignInFormView: View {
    // MARK: core
    @Bindable var signInFormRef: SignInForm
    init(_ signInFormRef: SignInForm) {
        self.signInFormRef = signInFormRef
    }
    
    @State private var isSigningIn = false
    @State private var isSigningInByCache = true
    @State private var isSigningInWithGoogle = false
    @State private var showSignUpForm = false
    
    private let buttonCornerRadius: CGFloat = 25
    private let buttonHeight: CGFloat = 50
    
    var body: some View {
        VStack(spacing: 20) {
            if !isSigningInByCache {
                Spacer()
                Title
                
                EmailField
                PasswordField
                
                SignInButton
                SignInWithGoogleButton
                SignUpButton
                Spacer()
                
                if signInFormRef.isIssueOccurred {
                    IssueLabel
                }
                Spacer()
            }
        }
        .padding()
        .task {
            self.isSigningInByCache = true
            await WorkFlow {
                await signInFormRef.signInByCache()
            }
            self.isSigningInByCache = false
        }.onChange(of: signInFormRef.signUpForm) { _, newValue in
            showSignUpForm = (newValue != nil)
        }.sheet(isPresented: $showSignUpForm, onDismiss: {
            Task {
                await WorkFlow {
                    await signInFormRef.signUpForm?.ref?.remove()
                }
            }
        }) {
            if let signUpFormRef = signInFormRef.signUpForm?.ref {
                SignUpFormView(signUpFormRef)
            }
        }
    }
}

extension SignInFormView {
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
                await WorkFlow {
                    await signInFormRef.signIn()
                }
                isSigningIn = false
            }
        }) {
            // ZStack을 사용해 텍스트와 ProgressView를 겹치게 하여
            // 로딩 중에도 레이아웃이 변하지 않도록 합니다.
            ZStack {
                // 항상 텍스트를 그려 투명하게 만들어 공간을 차지하게 합니다.
                Text("Sign In")
                    .bold()
                    .opacity(isSigningIn ? 0 : 1) // 로딩 중일 때 숨김
                
                if isSigningIn {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white)) // 로딩 인디케이터 색상 변경
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50) // 높이 고정
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(buttonCornerRadius)
        }
        .disabled(isSigningIn)
    }
    var SignInWithGoogleButton: some View {
        Button(action: {
            Task {
                isSigningInWithGoogle = true
                // defer는 여기에 두지 않고, 실제 작업이 끝난 후 false로 설정하는 것이
                // 사용자 경험에 더 좋습니다. (성공/실패 분기 처리)
                // defer { isSigningInWithGoogle = false }
                
                await signInFormRef.setUpGoogleForm()
                
                guard let googleFormRef = signInFormRef.googleForm?.ref else {
                    isSigningInWithGoogle = false
                    return
                }
                
                await googleFormRef.fetchGoogleClientId()
                guard let clientId = googleFormRef.googleClientId else {
                    isSigningInWithGoogle = false
                    return
                }
                
                guard let (idToken, accessToken) = await signInWithGoogle(clientId: clientId) else {
                    isSigningInWithGoogle = false
                    return
                }
                
                googleFormRef.idToken = idToken
                googleFormRef.accessToken = accessToken
                await googleFormRef.signUpAndSignIn()
                
                isSigningInWithGoogle = false // 모든 작업이 끝나면 false로 변경
            }
        }) {
            ZStack {
                HStack {
                    // 구글 아이콘 추가 (실제 구글 로고 이미지 사용을 권장)
                    Image("google_logo") // "google_logo"라는 이름으로 Assets에 이미지 추가 필요
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    
                    Text("Sign in with Google")
                        .fontWeight(.medium) // 폰트 두께 조절
                }
                .opacity(isSigningInWithGoogle ? 0 : 1) // 로딩 중일 때 숨김
                
                if isSigningInWithGoogle {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50) // 높이 고정
            .background(Color.white)
            .foregroundColor(.black.opacity(0.8)) // 텍스트 색상을 약간 부드럽게
            .cornerRadius(buttonCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: buttonCornerRadius)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1) // 테두리를 약간 얇고 부드럽게
            )
        }
        .disabled(isSigningInWithGoogle)
        .padding(.bottom, 8)
    }
    var SignUpButton: some View {
            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                
                Button(action: {
                    Task {
                        await WorkFlow {
                            await signInFormRef.setUpSignUpForm()
                        }
                    }
                }) {
                    Text("Sign Up")
                        .fontWeight(.bold)
                        .foregroundColor(.blue) // 앱의 테마 색상과 맞춥니다.
                }
            }
            .font(.footnote) // 전체적으로 작은 폰트 사용
        }
    var IssueLabel: some View {
        Text(signInFormRef.issue?.reason ?? "")
            .foregroundColor(.red)
            .font(.caption)
    }
    
    private func signInWithGoogle(clientId: String) async -> (idToken: String, accessToken: String)? {
        await withCheckedContinuation { continuation in
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



// MARK: Preview
private struct SignInFormPreview: View {
    @State var budClientRef = BudClient()
    
    var body: some View {
        if let authBoardRef = budClientRef.authBoard?.ref,
           let signInFormRef = authBoardRef.signInForm?.ref {
            SignInFormView(signInFormRef)
        } else if budClientRef.isUserSignedIn {
            Text("Signed In!")
            
            Button("Signed Out") {
                Task {
                    await budClientRef.profileBoard?.ref?.signOut()
                }
            }.buttonStyle(.glassProminent)
        } else {
            ProgressView("is loading...")
                .task { await setUp() }
        }
    }
    
    func setUp() async {
        await budClientRef.setUp()
        
        guard let authBoardRef = budClientRef.authBoard?.ref else { return }
        await authBoardRef.setUpForms()
    }
}

#Preview {
    SignInFormPreview()
}
