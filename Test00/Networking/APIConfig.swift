//
//  APIConfig.swift
//  Test00
//
//  Aquí se configura la API. Para la prueba usamos DummyJSON, que sí tiene
//  login con usuario/contraseña y CRUD de usuarios (las escrituras son
//  simuladas: responden 200 pero no se guardan en el servidor).
//
//  Cuando el equipo de arquitectura entregue la colección de Postman,
//  cambia `baseURL` y las rutas de `RutaAPI`.
//
//  Credenciales de prueba DummyJSON:
//  usuario: emilys
//  contraseña: emilyspass
//

import Foundation

enum APIConfig {
    static let baseURL = URL(string: "https://dummyjson.com")!
}

/// Rutas de los servicios que pide la prueba.
enum RutaAPI {
    case login
    case listarUsuarios
    case crearUsuario
    case actualizarUsuario(id: Int)
    case eliminarUsuario(id: Int)

    var metodo: String {
        switch self {
        case .login, .crearUsuario:
            return "POST"
        case .listarUsuarios:
            return "GET"
        case .actualizarUsuario:
            return "PUT"
        case .eliminarUsuario:
            return "DELETE"
        }
    }

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .listarUsuarios:
            return "/users?limit=30"
        case .crearUsuario:
            return "/users/add"
        case .actualizarUsuario(let id):
            return "/users/\(id)"
        case .eliminarUsuario(let id):
            return "/users/\(id)"
        }
    }

    var url: URL {
        // Las rutas con query (?limit=30) no se pueden pegar directo a baseURL + path
        // con appendingPathComponent, por eso usamos URL(string:relativeTo:).
        URL(string: path, relativeTo: APIConfig.baseURL)!.absoluteURL
    }
}
