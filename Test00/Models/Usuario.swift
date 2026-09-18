//
//  Usuario.swift
//  Test00
//
//  Modelo que representa a un usuario de la API.
//  Codable: convierte JSON <-> Swift
//  Identifiable: permite usar el usuario en List de SwiftUI
//

import Foundation

struct Usuario: Identifiable, Codable, Hashable {
    let id: Int
    /// Nombre visible (en DummyJSON llega como firstName).
    var nombre: String
    var username: String
    /// La API de listado a veces incluye el password; al editar lo mandamos de nuevo.
    var password: String?
    /// Fecha de creación. DummyJSON no siempre la envía; ver init(from:).
    var fechaCreacion: String?

    /// Texto listo para mostrar en la lista (nombre, usuario, fecha).
    var fechaCreacionTexto: String {
        FechaHelper.textoParaMostrar(fechaCreacion)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case nombre = "firstName"
        case username
        case password
        case fechaCreacion = "createdAt"
        /// DummyJSON trae birthDate en el GET /users. Lo usamos solo si no hay createdAt.
        case birthDate
    }

    init(
        id: Int,
        nombre: String,
        username: String,
        password: String? = nil,
        fechaCreacion: String? = nil
    ) {
        self.id = id
        self.nombre = nombre
        self.username = username
        self.password = password
        self.fechaCreacion = fechaCreacion
    }

    init(from decoder: Decoder) throws {
        let contenedor = try decoder.container(keyedBy: CodingKeys.self)
        id = try contenedor.decode(Int.self, forKey: .id)
        nombre = try contenedor.decodeIfPresent(String.self, forKey: .nombre) ?? ""
        username = try contenedor.decodeIfPresent(String.self, forKey: .username) ?? ""
        password = try contenedor.decodeIfPresent(String.self, forKey: .password)
        // Preferimos createdAt (requisito de la prueba). Si no viene, usamos birthDate
        // para poder mostrar una fecha en la lista con la API de demostración.
        fechaCreacion = try contenedor.decodeIfPresent(String.self, forKey: .fechaCreacion)
            ?? contenedor.decodeIfPresent(String.self, forKey: .birthDate)
    }

    func encode(to encoder: Encoder) throws {
        var contenedor = encoder.container(keyedBy: CodingKeys.self)
        try contenedor.encode(id, forKey: .id)
        try contenedor.encode(nombre, forKey: .nombre)
        try contenedor.encode(username, forKey: .username)
        try contenedor.encodeIfPresent(password, forKey: .password)
        try contenedor.encodeIfPresent(fechaCreacion, forKey: .fechaCreacion)
    }
}

/// Respuesta de GET /users: DummyJSON envuelve el array en "users".
struct ListaUsuariosRespuesta: Codable {
    let users: [Usuario]
}

enum FechaHelper {
    /// Convierte distintos formatos de fecha de la API a un texto legible (dd/MM/yyyy).
    static func textoParaMostrar(_ crudo: String?) -> String {
        guard let crudo, !crudo.isEmpty else {
            return "Sin fecha"
        }

        let formatos = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd",
            "yyyy-M-d"
        ]

        let lector = DateFormatter()
        lector.locale = Locale(identifier: "en_US_POSIX")
        lector.timeZone = TimeZone(secondsFromGMT: 0)

        for formato in formatos {
            lector.dateFormat = formato
            if let fecha = lector.date(from: crudo) {
                let escritor = DateFormatter()
                escritor.locale = Locale(identifier: "es_CO")
                escritor.dateFormat = "dd/MM/yyyy"
                return escritor.string(from: fecha)
            }
        }

        return crudo
    }

    /// Fecha actual en ISO 8601 para enviarla al crear un usuario.
    static func ahoraISO() -> String {
        ISO8601DateFormatter().string(from: Date())
    }
}
