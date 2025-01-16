//
//  Persistence.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 14/01/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Crea datos de ejemplo para la entidad "Horario"
        for i in 0..<10 {
            let nuevoHorario = Horario(context: viewContext)
            nuevoHorario.id = UUID()  // Usamos un UUID único
            nuevoHorario.nombreEmpleado = "Empleado \(i + 1)"  // Nombre del empleado
            nuevoHorario.fechaInicio = Calendar.current.date(byAdding: .day, value: i, to: Date()) ?? Date()  // Fecha de inicio
            nuevoHorario.fechaFin = Calendar.current.date(byAdding: .hour, value: 4, to: nuevoHorario.fechaInicio ?? Date())  // Fecha de fin (4 horas después)
            nuevoHorario.esDiaPico = (Calendar.current.component(.day, from: nuevoHorario.fechaInicio ?? Date()) == 15 || Calendar.current.component(.day, from: nuevoHorario.fechaInicio ?? Date()) == 30)  // Marcar como día pico si es el 15 o el 30 del mes

            // Si deseas agregar notificaciones, también podrías generar un valor aleatorio para el atributo `recordatorio`, pero lo eliminaré por ahora.
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GestorDeHorarios")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
