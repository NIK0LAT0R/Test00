//
//  APIError.swift
//  Test00
//
//  Errores de red que podemos mostrar al usuario.
//

import Foundation

enum APIError: LocalizedError {
    case urlInvalida
    case respuestaInvalida
    case http(codigo: Int, mensaje: String)
    case decodificacion(Error)

    var errorDescription: String? {
        switch self {
        case .urlInvalida:
            return "La URL del servicio no es válida."
        case .respuestaInvalida:
            return "El servidor no devolvió una respuesta válida."
        case .http(_, let mensaje):
            return mensaje
        case .decodificacion:
            return "No se pudo leer la respuesta del servidor."
        }
    }
}

/// DummyJSON (y muchas APIs) envían errores así: { "message": "Invalid credentials" }
struct MensajeErrorAPI: Codable {
    let message: String?
}
