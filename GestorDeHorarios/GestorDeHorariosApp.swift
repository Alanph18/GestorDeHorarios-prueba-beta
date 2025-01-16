//
//  GestorDeHorariosApp.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 14/01/25.
//

import SwiftUI

@main
struct GestorDeHorariosApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            LaunchScreenView()  // Pantalla de inicio
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
