//
//  AddHorarioView.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 14/01/25.
//
import SwiftUI

struct AddHorarioView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var nombreEmpleado = ""
    @State private var fechaInicio = Date()
    @State private var fechaFin = Date()
    @State private var selectedDates: Set<Date> = []

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // Sección de nombre del empleado
                    Section(header: Text("Información del Empleado")) {
                        TextField("Nombre del empleado", text: $nombreEmpleado)
                            .padding()
                    }
                    
                    // Sección de selección de fechas de trabajo
                    Section(header: Text("Seleccionar Fechas de Trabajo")) {
                        CalendarView2(selectedDates: $selectedDates)
                            .frame(height: 330)
                        
                        // Explicación de los días pico debajo del calendario
                        Text("Los días 15 y 30 son días pico y se destacan en rojo.")
                            .font(.footnote)
                            .foregroundColor(.purple)
                            .padding(.top, 10)
                    }

                    // Sección de selección de horario
                    Section(header: Text("Seleccionar Horario")) {
                        DatePicker("Hora de inicio", selection: $fechaInicio, displayedComponents: [.hourAndMinute])
                            .padding()
                        DatePicker("Hora de fin", selection: $fechaFin, displayedComponents: [.hourAndMinute])
                            .padding()
                    }
                }
                
                Spacer()
                
                // Botón para guardar
                Button(action: {
                    saveHorario()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Guardar")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                        .background(Color.black)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                }
                .disabled(nombreEmpleado.isEmpty || selectedDates.isEmpty) // Deshabilita si no hay nombre o fechas seleccionadas
            }
            .navigationTitle("Nuevo Horario")
            .navigationBarItems(leading: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func saveHorario() {
        // Solo guarda si el nombre del empleado no está vacío
        guard !nombreEmpleado.isEmpty else { return }
        
        // Guardar el horario para cada día seleccionado
        for dia in selectedDates {
            let horario = Horario(context: CoreDataManager.shared.context)
            horario.id = UUID()
            horario.nombreEmpleado = nombreEmpleado
            horario.fechaInicio = fechaInicio
            horario.fechaFin = fechaFin
            horario.esDiaPico = isDiaPico(date: dia)
            
            CoreDataManager.shared.saveContext()
            NotificationManager.shared.scheduleNotification(for: horario)
        }
    }
    
    private func isDiaPico(date: Date) -> Bool {
        let day = Calendar.current.component(.day, from: date)
        return day == 15 || day == 30
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

struct CalendarView2: View {
    @Binding var selectedDates: Set<Date>
    
    let calendar = Calendar.current
    @State private var displayedMonth = Date()

    var body: some View {
        VStack {
            // Mostrar el mes actual en el calendario
            Text("\(displayedMonth, formatter: monthFormatter)")
                .font(.headline)
                .padding()

            // Mostrar el calendario para el mes actual
            let daysInMonth = getDaysInMonth(for: displayedMonth)
            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysInMonth, id: \.self) { day in
                    let dayNumber = calendar.component(.day, from: day)
                    Text("\(dayNumber)")
                        .frame(width: 30, height: 30)
                        .background(self.selectedDates.contains(day) ? Color.black : (isDiaPico(date: day) ? Color.purple : Color.clear))
                        .foregroundColor(self.selectedDates.contains(day) ? .white : (isDiaPico(date: day) ? .white : .black))
                        .clipShape(Circle())
                        .onTapGesture {
                            toggleDateSelection(day)
                        }
                }
            }
            
            // Navegar entre meses
            monthNavigationButtons
        }
    }

    private func getDaysInMonth(for month: Date) -> [Date] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: startOfMonth) }
    }

    private func toggleDateSelection(_ date: Date) {
        if selectedDates.contains(date) {
            selectedDates.remove(date)
        } else {
            selectedDates.insert(date)
        }
    }

    private func isDiaPico(date: Date) -> Bool {
        let day = Calendar.current.component(.day, from: date)
        return day == 15 || day == 30
    }

    private var monthNavigationButtons: some View {
        HStack {
            Button(action: {
                displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
            }) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Button(action: {
                displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
            }) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title)
                    .foregroundColor(.black)
                
            }
        }
        .padding()
    }

    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

#Preview {
    AddHorarioView()
}
