//
//  LoginView.swift
//  COEUSit
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    
    enum Field {
        case email, password
    }
    
    @FocusState private var focusedField: Field?
    
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 12) {
                    Image(systemName: "thermometer.sun.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.orange)
                        .symbolEffect(.bounce, value: isLoading)
                    
                    Text("COEUSit")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Monitor temperature & humidity")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                        .disabled(isLoading)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit {
                            Task {
                                await login()
                            }
                        }
                        .disabled(isLoading)
                }
                .padding(.horizontal)
                
                Button {
                    Task {
                        await login()
                    }
                } label: {
                    Group {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign In")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .disabled(email.isEmpty || password.isEmpty || isLoading)
                
                Spacer()
                
                Button("Forgot Password?") { }
                .font(.footnote)
                .foregroundStyle(.blue)
                
                Spacer()
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Login Error", isPresented: $showError, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(errorMessage ?? "An unknown error occurred")
            })
            .alert("Session Expired", isPresented: $authManager.showSessionExpiredAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text("Your session has expired. Please log in again to continue.")
            })
        }
    }
    
    private func login() async {
        focusedField = nil
        isLoading = true
        
        do {
            try await authManager.login(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
