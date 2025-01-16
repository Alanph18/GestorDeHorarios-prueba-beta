//
//  CoreDataManager.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 14/01/25.
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    var context: NSManagedObjectContext {
        return PersistenceController.shared.container.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    func delete(horario: Horario) {
        context.delete(horario)
        saveContext()
    }
    
    // Fetch horarios
    func fetchHorarios() -> [Horario] {
        let request: NSFetchRequest<Horario> = Horario.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch horarios: \(error)")
            return []
        }
    }
}

