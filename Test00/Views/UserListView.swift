//
//  UserListView.swift
//  Test00
//
//  Requisito 2: lista nombre, usuario y fecha de creación.
//  Requisito 3: mensaje de carga antes de mostrar la lista.
//  Requisito 6: eliminar usuario.
//  Al tocar una celda se abre el formulario de actualización.
//

import SwiftUI

struct UserListView: View {
    @Environment(SessionStore.self) private var session
    @State private var viewModel = UserListViewModel()
    @State private var mostrarCrear = false
    @State private var usuarioAEditar: Usuario?
    @State private var usuarioAEliminar: Usuario?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.usuarios.isEmpty && !viewModel.estaCargando {
                    ContentUnavailableView(
                        "Sin usuarios",
                        systemImage: "person.3",
                        description: Text("Pulsa + para crear uno o recarga la lista.")
                    )
                } else {
                    List {
                        ForEach(viewModel.usuarios) { usuario in
                            Button {
                                usuarioAEditar = usuario
                            } label: {
                                fila(usuario)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    usuarioAEliminar = usuario
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .refreshable {
                        if let token = session.accessToken {
                            await viewModel.cargar(token: token)
                        }
                    }
                }
            }
            .navigationTitle("Usuarios")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Salir") {
                        session.cerrarSesion()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        mostrarCrear = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Crear usuario")
                }
            }
            .overlayDeCarga(viewModel.estaCargando, mensaje: viewModel.mensajeCarga)
            .task {
                if let token = session.accessToken {
                    await viewModel.cargar(token: token)
                }
            }
            .sheet(isPresented: $mostrarCrear) {
                UserFormView(modo: .crear) { nombre, username, password in
                    guard let token = session.accessToken else { return false }
                    return await viewModel.crear(
                        nombre: nombre,
                        username: username,
                        password: password,
                        token: token
                    )
                }
            }
            .sheet(item: $usuarioAEditar) { usuario in
                UserFormView(modo: .editar(usuario)) { nombre, username, password in
                    guard let token = session.accessToken else { return false }
                    var editado = usuario
                    editado.nombre = nombre
                    editado.username = username
                    editado.password = password
                    return await viewModel.actualizar(editado, token: token)
                }
            }
            .alert("No se pudo completar", isPresented: errorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.mensajeError ?? "")
            }
            .alert(
                "Eliminar usuario",
                isPresented: Binding(
                    get: { usuarioAEliminar != nil },
                    set: { if !$0 { usuarioAEliminar = nil } }
                ),
                presenting: usuarioAEliminar
            ) { usuario in
                Button("Eliminar", role: .destructive) {
                    Task {
                        if let token = session.accessToken {
                            await viewModel.eliminar(id: usuario.id, token: token)
                        }
                    }
                }
                Button("Cancelar", role: .cancel) {}
            } message: { usuario in
                Text("¿Seguro que quieres eliminar a \(usuario.nombre)?")
            }
        }
    }

    /// Celda con los 3 datos que pide la prueba: nombre, usuario y fecha de creación.
    private func fila(_ usuario: Usuario) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(usuario.nombre)
                .font(.headline)
                .foregroundStyle(.primary)
            Text("@\(usuario.username)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Creado: \(usuario.fechaCreacionTexto)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.mensajeError != nil },
            set: { if !$0 { viewModel.mensajeError = nil } }
        )
    }
}

#Preview {
    UserListView()
        .environment(SessionStore())
}
