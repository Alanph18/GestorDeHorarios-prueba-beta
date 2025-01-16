//
//  CalendarView.swift
//  GestorDeHorarios
//
//  Created by Josue Alan Pablo Hernández on 14/01/25.
//
import SwiftUI
import CoreData

struct CalendarView: View {
    var horarios: FetchedResults<Horario> // Acepta FetchedResults<Horario> directamente
    
    @State private var currentDate = Date()
    @State private var selectedDate: Date? = nil
    @State private var selectedHorarios: [Horario] = []
    
    // Cálculo de los meses a mostrar (por ejemplo, los próximos 6 meses)
    private var monthsToShow: [Date] {
        let calendar = Calendar.current
        var months: [Date] = []
        
        // Mostrar los próximos 6 meses desde el mes actual
        for offset in 0..<6 {
            if let monthDate = calendar.date(byAdding: .month, value: offset, to: currentDate) {
                months.append(monthDate)
            }
        }
        return months
    }
    
    var body: some View {
        VStack {
            // Título de la vista
            Text("Calendario de Trabajo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            // ScrollView vertical para mostrar los meses
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(monthsToShow, id: \.self) { month in
                        MonthView(monthDate: month, horarios: horarios, selectedDate: $selectedDate, selectedHorarios: $selectedHorarios)
                    }
                }
                .padding(.horizontal)
            }
            
            // Mostrar horarios del día seleccionado
            if let selectedDate = selectedDate {
                VStack(alignment: .leading) {
                    let formattedSelectedDate = formatDate(selectedDate)
                    Text("Empleados que trabajan para \(formattedSelectedDate.fullDate)") // Mostrar fecha completa
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)
                    
                    // Mostrar la lista de empleados
                    ForEach(selectedHorarios, id: \.self) { horario in
                        let formattedStart = formatDate(horario.fechaInicio ?? Date())
                        let formattedEnd = formatDate(horario.fechaFin ?? Date())
                        Text("\(horario.nombreEmpleado ?? "Desconocido") - \(formattedStart.day) a \(formattedEnd.day)") // Mostrar nombre y horarios
                            .font(.body)
                            .padding(.bottom, 2)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(Color.white) // Fondo blanco para el calendario
        .cornerRadius(0) // Sin bordes redondeados
        .padding(.top, 10) // Margen superior
        .padding(.bottom, 20) // Margen inferior
    }
    
    private func formatDate(_ date: Date) -> (day: String, fullDate: String) {
        let formatter = DateFormatter()
        
        // Formato para solo el día (día numérico)
        formatter.dateFormat = "d"
        let day = formatter.string(from: date)
        
        // Formato completo (mes, día, año)
        formatter.dateFormat = "MMMM dd, yyyy"
        let fullDate = formatter.string(from: date)
        
        return (day, fullDate)
    }
    
    private func formatMonthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct MonthView: View {
    var monthDate: Date
    var horarios: FetchedResults<Horario>
    @Binding var selectedDate: Date?
    @Binding var selectedHorarios: [Horario]
    
    private var daysInMonth: [Date] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    var body: some View {
        VStack {
            Text(formatMonthString(from: monthDate))
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 5)
            
            // Grid de fechas del mes
            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysInMonth, id: \.self) { date in
                    let formattedDate = formatDate(date) // Ahora usamos el formateo aquí
                    let isSelected = selectedDate == date
                    let filteredHorarios = horarios.filter { Calendar.current.isDate($0.fechaInicio ?? Date(), inSameDayAs: date) }
                    
                    VStack {
                        Text(formattedDate.day)
                            .font(.system(size: 28, weight: .bold)) // Tamaño de fuente más grande, similar a iOS
                            .frame(width: 50, height: 70) // Aumenta el tamaño de las celdas
                            .background(
                                isSelected ? Color.purple : Color.clear
                            )
                            .foregroundColor(isSelected ? Color.white : Color.black)
                            
                            .onTapGesture {
                                selectedDate = date
                                selectedHorarios = filteredHorarios
                            }
                        
                        // Si hay horarios, mostrar un pequeño círculo verde debajo
                        if !filteredHorarios.isEmpty {
                            Circle()
                                .frame(width: 16, height: 4) // Aumenta el tamaño del círculo
                                .foregroundColor(.black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private func formatDate(_ date: Date) -> (day: String, fullDate: String) {
        let formatter = DateFormatter()
        
        // Formato para solo el día (día numérico)
        formatter.dateFormat = "d"
        let day = formatter.string(from: date)
        
        // Formato completo (mes, día, año)
        formatter.dateFormat = "MMMM dd, yyyy"
        let fullDate = formatter.string(from: date)
        
        return (day, fullDate)
    }
    
    private func formatMonthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

