//
//  LoadingOverlay.swift
//  Test00
//
//  Diálogo de carga. La prueba pide mostrarlo mientras se consumen los servicios.
//

import SwiftUI

struct LoadingOverlay: View {
    var mensaje: String = "Cargando..."

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                Text(mensaje)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            .padding(28)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(mensaje)
    }
}

extension View {
    func overlayDeCarga(_ visible: Bool, mensaje: String = "Cargando...") -> some View {
        overlay {
            if visible {
                LoadingOverlay(mensaje: mensaje)
            }
        }
        .disabled(visible)
    }
}
