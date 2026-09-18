//
//  UserListViewModel.swift
//  Test00
//
//  Lista, crea, actualiza y elimina usuarios.
//  DummyJSON simula POST/PUT/DELETE: responde OK pero no persiste.
//  Por eso, si el servicio responde bien, actualizamos la lista en memoria.
//

import Foundation

@Observable
final class UserListViewModel {
    var usuarios: [Usuario] = []
    var estaCargando = false
    var mensajeCarga = "Cargando usuarios..."
    var mensajeError: String?

    private let servicio: UsuarioService

    init(servicio: UsuarioService = UsuarioService()) {
        self.servicio = servicio
    }

    @MainActor
    func cargar(token: String) async {
        mensajeError = nil
        mensajeCarga = "Cargando usuarios..."
        estaCargando = true
        defer { estaCargando = false }

        do {
            usuarios = try await servicio.listar(token: token)
        } catch {
            mensajeError = error.localizedDescription
        }
    }

    @MainActor
    func crear(nombre: String, username: String, password: String, token: String) async -> Bool {
        mensajeError = nil
        mensajeCarga = "Creando usuario..."
        estaCargando = true
        defer { estaCargando = false }

        do {
            var nuevo = try await servicio.crear(
                nombre: nombre,
                username: username,
                password: password,
                token: token
            )
            if nuevo.fechaCreacion == nil {
                nuevo.fechaCreacion = FechaHelper.ahoraISO()
            }
            usuarios.insert(nuevo, at: 0)
            return true
        } catch {
            mensajeError = error.localizedDescription
            return false
        }
    }

    @MainActor
    func actualizar(_ usuario: Usuario, token: String) async -> Bool {
        mensajeError = nil
        mensajeCarga = "Actualizando usuario..."
        estaCargando = true
        defer { estaCargando = false }

        do {
            let actualizado = try await servicio.actualizar(usuario, token: token)
            if let indice = usuarios.firstIndex(where: { $0.id == usuario.id }) {
                // La API de demo a veces no devuelve todos los campos; mezclamos con lo que editó el usuario.
                usuarios[indice] = Usuario(
                    id: actualizado.id,
                    nombre: actualizado.nombre.isEmpty ? usuario.nombre : actualizado.nombre,
                    username: actualizado.username.isEmpty ? usuario.username : actualizado.username,
                    password: actualizado.password ?? usuario.password,
                    fechaCreacion: actualizado.fechaCreacion ?? usuario.fechaCreacion
                )
            }
            return true
        } catch {
            mensajeError = error.localizedDescription
            return false
        }
    }

    @MainActor
    func eliminar(id: Int, token: String) async {
        mensajeError = nil
        mensajeCarga = "Eliminando usuario..."
        estaCargando = true
        defer { estaCargando = false }

        do {
            try await servicio.eliminar(id: id, token: token)
            usuarios.removeAll { $0.id == id }
        } catch {
            mensajeError = error.localizedDescription
        }
    }
}
