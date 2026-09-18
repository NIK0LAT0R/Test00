//
//  HTTPClient.swift
//  Test00
//
//  Capa de red. Todas las pantallas pasan por aquí para hablar con la API.
//  Usamos URLSession nativo + async/await (sin Alamofire).
//

import Foundation

final class HTTPClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    /// GET (u otras rutas) sin body.
    func enviar<Respuesta: Decodable>(
        ruta: RutaAPI,
        token: String? = nil
    ) async throws -> Respuesta {
        try await enviar(ruta: ruta, cuerpo: DatosVacios?.none, token: token)
    }

    /// Petición genérica. `Cuerpo` es lo que enviamos, `Respuesta` es lo que esperamos.
    func enviar<Cuerpo: Encodable, Respuesta: Decodable>(
        ruta: RutaAPI,
        cuerpo: Cuerpo?,
        token: String? = nil
    ) async throws -> Respuesta {
        let (datos, respuesta) = try await ejecutar(ruta: ruta, cuerpo: cuerpo, token: token)
        try validarHTTP(datos: datos, respuesta: respuesta)
        do {
            return try decoder.decode(Respuesta.self, from: datos)
        } catch {
            throw APIError.decodificacion(error)
        }
    }

    /// DELETE (y otros) a veces no traen un JSON útil. Solo validamos el código HTTP.
    func enviarSinRespuesta(ruta: RutaAPI, token: String? = nil) async throws {
        let (datos, respuesta) = try await ejecutar(
            ruta: ruta,
            cuerpo: DatosVacios?.none,
            token: token
        )
        try validarHTTP(datos: datos, respuesta: respuesta)
    }

    private func ejecutar<Cuerpo: Encodable>(
        ruta: RutaAPI,
        cuerpo: Cuerpo?,
        token: String?
    ) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: ruta.url)
        request.httpMethod = ruta.metodo
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let cuerpo {
            request.httpBody = try encoder.encode(cuerpo)
        }

        return try await session.data(for: request)
    }

    private func validarHTTP(datos: Data, respuesta: URLResponse) throws {
        guard let http = respuesta as? HTTPURLResponse else {
            throw APIError.respuestaInvalida
        }

        guard (200...299).contains(http.statusCode) else {
            let mensaje = (try? decoder.decode(MensajeErrorAPI.self, from: datos))?.message
                ?? "Error del servidor (\(http.statusCode))."
            throw APIError.http(codigo: http.statusCode, mensaje: mensaje)
        }
    }
}

/// Placeholder cuando no enviamos body.
struct DatosVacios: Encodable {}
