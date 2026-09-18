//
//  UserFormView.swift
//  Test00
//
//  Formulario para crear (req. 4) y actualizar (req. 5).
//  Campos: nombre, usuario y contraseña.
//

import SwiftUI

enum ModoFormularioUsuario {
    case crear
    case editar(Usuario)
}

struct UserFormView: View {
    let modo: ModoFormularioUsuario
    var onGuardar: (String, String, String) async -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var nombre = ""
    @State private var username = ""
    @State private var password = ""
    @State private var estaGuardando = false

    private var titulo: String {
        switch modo {
        case .crear: return "Nuevo usuario"
        case .editar: return "Editar usuario"
        }
    }

    private var textoBoton: String {
        switch modo {
        case .crear: return "Crear"
        case .editar: return "Guardar cambios"
        }
    }

    private var formularioValido: Bool {
        !nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !password.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Datos") {
                    TextField("Nombre", text: $nombre)
                    TextField("Usuario", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("Contraseña", text: $password)
                }
            }
            .navigationTitle(titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(textoBoton) {
                        Task { await guardar() }
                    }
                    .disabled(!formularioValido || estaGuardando)
                }
            }
            .overlayDeCarga(estaGuardando, mensaje: "Guardando...")
            .onAppear { precargarSiEdita() }
        }
    }

    private func precargarSiEdita() {
        if case .editar(let usuario) = modo {
            nombre = usuario.nombre
            username = usuario.username
            password = usuario.password ?? ""
        }
    }

    private func guardar() async {
        estaGuardando = true
        let ok = await onGuardar(
            nombre.trimmingCharacters(in: .whitespacesAndNewlines),
            username.trimmingCharacters(in: .whitespacesAndNewlines),
            password
        )
        estaGuardando = false
        if ok {
            dismiss()
        }
    }
}
