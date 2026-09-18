//
//  Servicios.swift
//  Test00
//
//  Servicios de dominio: login y CRUD de usuarios.
//  Los ViewModels NO hablan con URLSession directo; usan estas clases.
//

import Foundation

// MARK: - Login

struct LoginCuerpo: Encodable {
    let username: String
    let password: String
}

struct LoginRespuesta: Decodable {
    let id: Int
    let username: String
    let firstName: String?
    let accessToken: String
}

final class AuthService {
    private let cliente: HTTPClient

    init(cliente: HTTPClient = HTTPClient()) {
        self.cliente = cliente
    }

    func login(usuario: String, password: String) async throws -> LoginRespuesta {
        try await cliente.enviar(
            ruta: .login,
            cuerpo: LoginCuerpo(username: usuario, password: password)
        )
    }
}

// MARK: - Usuarios (CRUD)

struct UsuarioEscritura: Encodable {
    let firstName: String
    let username: String
    let password: String
    let createdAt: String
}

final class UsuarioService {
    private let cliente: HTTPClient

    init(cliente: HTTPClient = HTTPClient()) {
        self.cliente = cliente
    }

    func listar(token: String) async throws -> [Usuario] {
        let respuesta: ListaUsuariosRespuesta = try await cliente.enviar(
            ruta: .listarUsuarios,
            token: token
        )
        return respuesta.users
    }

    func crear(nombre: String, username: String, password: String, token: String) async throws -> Usuario {
        let cuerpo = UsuarioEscritura(
            firstName: nombre,
            username: username,
            password: password,
            createdAt: FechaHelper.ahoraISO()
        )
        return try await cliente.enviar(ruta: .crearUsuario, cuerpo: cuerpo, token: token)
    }

    func actualizar(_ usuario: Usuario, token: String) async throws -> Usuario {
        let cuerpo = UsuarioEscritura(
            firstName: usuario.nombre,
            username: usuario.username,
            password: usuario.password ?? "",
            createdAt: usuario.fechaCreacion ?? FechaHelper.ahoraISO()
        )
        return try await cliente.enviar(
            ruta: .actualizarUsuario(id: usuario.id),
            cuerpo: cuerpo,
            token: token
        )
    }

    func eliminar(id: Int, token: String) async throws {
        try await cliente.enviarSinRespuesta(
            ruta: .eliminarUsuario(id: id),
            token: token
        )
    }
}
