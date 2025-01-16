//
//  ContentView.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 14/01/25.
import SwiftUI
import CoreData

struct ContentView: View {
    @State private var showingAddHorario = false
    @State private var showingCalendar = false  // Variable para controlar la vista de calendario
    @FetchRequest var horarios: FetchedResults<Horario>
    
    init() {
        // Fecha actual
        let today = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: today)  // Comienza el día a medianoche
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!  // Termina el día a las 23:59
        
        // Predicado para filtrar los horarios que ocurren en el día actual
        let predicate = NSPredicate(format: "(fechaInicio >= %@ AND fechaInicio < %@) OR (fechaFin > %@ AND fechaFin <= %@)", startOfDay as CVarArg, endOfDay as CVarArg, startOfDay as CVarArg, endOfDay as CVarArg)
        
        // Inicializamos el FetchRequest con el predicado
        _horarios = FetchRequest(
            entity: Horario.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Horario.fechaInicio, ascending: true)],
            predicate: predicate
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo gris claro para la vista
                Color.gray.opacity(0.1).ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    // Encabezado con fecha actual y icono
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(.yellow)
                                .font(.title2)
                            Text("Bienvenido")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        
                        Text(formattedDate(Date()))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()

                    // Botón del calendario
                    Button(action: {
                        showingCalendar = true
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.title2)
                            Text("Calendario")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    
                    // Lista de horarios con diseño moderno
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(horarios) { horario in
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(horario.nombreEmpleado ?? "Sin nombre")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        
                                        Text("Inicio: \(formattedDate(horario.fechaInicio))")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        Text("Fin: \(formattedDate(horario.fechaFin))")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    
                                    // Checkmark para marcar la asistencia
                                    Image(systemName: horario.asistencia ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(horario.asistencia ? .green : .gray)
                                        .font(.title2)
                                        .onTapGesture {
                                            // Cambiar el estado de la asistencia
                                            toggleAsistencia(for: horario)
                                        }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(0.2), Color.gray.opacity(0.2)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                )
                                .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
                                .padding(.horizontal)
                            }
                            .onDelete(perform: deleteHorario)
                        }
                        .padding(.vertical)
                    }
                }
                .padding(.top)

                // Botón flotante para agregar
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddHorario = true
                        }) {
                            Label("Agregar", systemImage: "plus")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(50)
                                .shadow(radius: 5)
                        }
                        .padding()
                    }
                }
            }
            .sheet(isPresented: $showingAddHorario) {
                AddHorarioView()
            }
            .sheet(isPresented: $showingCalendar) {
                CalendarView(horarios: horarios)
            }
        }
    }
    
    private func deleteHorario(at offsets: IndexSet) {
        offsets.forEach { index in
            let horario = horarios[index]
            CoreDataManager.shared.delete(horario: horario)
        }
    }
    
    private func toggleAsistencia(for horario: Horario) {
        // Cambiar el estado de "asistencia"
        horario.asistencia.toggle()
        CoreDataManager.shared.saveContext()  // Guardar cambios
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
