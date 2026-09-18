//
//  LoginViewModel.swift
//  Test00
//
//  ViewModel del login (MVVM):
//  la vista solo muestra datos; aquí va la lógica y la llamada al servicio.
//

import Foundation

@Observable
final class LoginViewModel {
    var usuario = ""
    var password = ""
    var estaCargando = false
    var mensajeError: String?

    private let authService: AuthService

    init(authService: AuthService = AuthService()) {
        self.authService = authService
    }

    var puedeEnviar: Bool {
        !usuario.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !password.isEmpty
            && !estaCargando
    }

    @MainActor
    func iniciarSesion(en session: SessionStore) async {
        mensajeError = nil
        estaCargando = true
        defer { estaCargando = false }

        do {
            let respuesta = try await authService.login(
                usuario: usuario.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            session.guardarSesion(token: respuesta.accessToken)
        } catch {
            mensajeError = error.localizedDescription
        }
    }
}
