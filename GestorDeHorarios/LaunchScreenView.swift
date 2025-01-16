//
//  LaunchScreenView.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 14/01/25.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var showMainView = false
    
    var body: some View {
        VStack {
            if showMainView {
                ContentView()  // Mostrar la vista principal después de la pantalla de inicio
            } else {
                // Pantalla de inicio con logo
                VStack {
                    Image("Logo")  // Asegúrate de tener un logo en tus recursos
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                    
                    Text("Gestor de Horarios")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding()
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .onAppear {
                    // Simula un retraso antes de mostrar la vista principal
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {  // 2 segundos de espera
                        withAnimation {
                            showMainView = true  // Cambiar a la vista principal
                        }
                    }
                }
            }
        }
    }
}

