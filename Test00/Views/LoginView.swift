//
//  LoginView.swift
//  Test00
//
//  Requisito 1: autenticación con usuario y contraseña.
//  Si el login es correcto, SessionStore cambia y RootView muestra la lista.
//

import SwiftUI

struct LoginView: View {
    @Environment(SessionStore.self) private var session
    @State private var viewModel = LoginViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.tint)
                    .padding(.top, 32)

                Text("Iniciar sesión")
                    .font(.title.bold())

                Text("Usa el usuario y la contraseña del servicio web.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    TextField("Usuario", text: $viewModel.usuario)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                    SecureField("Contraseña", text: $viewModel.password)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    Task {
                        await viewModel.iniciarSesion(en: session)
                    }
                } label: {
                    Text("Entrar")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.puedeEnviar)

                Text("Prueba DummyJSON: emilys / emilyspass")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle("Login")
            .overlayDeCarga(viewModel.estaCargando, mensaje: "Iniciando sesión...")
            .alert("No se pudo entrar", isPresented: errorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.mensajeError ?? "")
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.mensajeError != nil },
            set: { if !$0 { viewModel.mensajeError = nil } }
        )
    }
}

#Preview {
    LoginView()
        .environment(SessionStore())
}
