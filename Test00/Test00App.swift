//
//  Test00App.swift
//  Test00
//
//  Punto de entrada. Navigation: Login -> Lista de usuarios.
//

import SwiftUI

@main
struct Test00App: App {
    @State private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
        }
    }
}

/// Elige Login o Lista según si hay sesión.
struct RootView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        if session.estaLogueado {
            UserListView()
        } else {
            LoginView()
        }
    }
}


/*
View
    ↓
ViewModel
    ↓
Service
    ↓
HTTPClient
    ↓
RutaAPI
    ↓
Servidor



Servidor
    ↓
HTTPClient decodifica
    ↓
Service adapta
    ↓
ViewModel actualiza estado
    ↓
View se redibuja
*/
