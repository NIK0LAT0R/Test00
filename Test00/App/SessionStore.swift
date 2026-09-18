//
//  SessionStore.swift
//  Test00
//
//  Guarda si el usuario ya inició sesión.
//  En una app real el token se guardaría en el Keychain;
//  aquí lo dejamos en memoria para mantener el ejemplo sencillo.
//

import Foundation
import Observation

@Observable
final class SessionStore {
    /// Token JWT que devuelve el login. Lo usamos en las peticiones siguientes.
    private(set) var accessToken: String?

    var estaLogueado: Bool {
        accessToken != nil
    }

    func guardarSesion(token: String) {
        accessToken = token
    }

    func cerrarSesion() {
        accessToken = nil
    }
}
