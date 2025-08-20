//
//  InfoAlimentos.swift
//  AulaTeste
//
//  Created by Turma02-27 on 24/07/25.
//

import SwiftUI

struct InfoAlimentos: View {
    @Binding var date: Date
    @State private var animateKcal = false
    @State private var animateDate = false
    @State private var animateRectangule = false
    @State private var animateText = false
    
    @State var sheetDown = false
    @State private var selectedId: UUID? = nil
    @State private var showNotification = false
    
    @StateObject var foods = ViewModelAlimentos()
    
    // Formata a data para "25 de julho de 2025"
    func formatarData(_ data: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "d 'de' MMMM 'de' yyyy"
        return formatter.string(from: data)
    }
    
    // Converte String ISO8601 para Date
    func converterStringParaDate(_ dataString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // formato do JSON
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: dataString)
    }
    
    // Compara só o dia, mês e ano de duas datas
    func ehMesmaData(_ data1: Date, _ data2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(data1, inSameDayAs: data2)
    }
    
    // Computed property que filtra os alimentos da data selecionada
    var alimentosDoDia: [alimentacao] {
        let formatarData = DateFormatter()
        formatarData.dateFormat = "HH:mm"
        formatarData.locale = Locale(identifier: "en_US_POSIX")
        
        return foods.food.filter { info in
            guard let dataRegistro = converterStringParaDate(info.data ?? "")
            else{
                return false
            }
            return ehMesmaData(dataRegistro, date)
        }.sorted{ a, b in
            guard
                let h1 = a.horario, let d1 = formatarData.date(from: h1),
                let h2 = b.horario, let d2 = formatarData.date(from: h2)
            else{
                return false
            }
            return d1 < d2
        }
    }
    
    // Soma calorias apenas dos alimentos do dia filtrados
    var somaCalorias: Int {
        alimentosDoDia.reduce(0) { $0 + ($1.calorias ?? 0) }
    }
    
    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea().opacity(0.2)
            
            if foods.isLoading {
                ProgressView("Carregando dados...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .green))
                    .scaleEffect(1.5)
            }
            else {
                VStack {
                    Text(formatarData(date))
                        .font(.title)
                        .bold()
                        .offset(x: animateDate ? 0 : -UIScreen.main.bounds.width)
                        .animation(.easeOut(duration: 1), value: animateDate)
                        .onAppear { animateDate = true }
                        .padding()
                    
                    if alimentosDoDia.isEmpty {
                        Spacer()
                        Text("Nenhum alimento registrado para esta data")
                            .font(.title3)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    else {
                        VStack {
                            Text("\(somaCalorias) Kcal")
                                .font(.title)
                                .offset(x: animateKcal ? 0 : -UIScreen.main.bounds.width)
                                .animation(.easeOut(duration: 1), value: animateKcal)
                                .onAppear { animateKcal = true }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding()
                        
                        ScrollView(.vertical) {
                            ForEach(alimentosDoDia, id: \.id) { info in
                                
                                ZStack {
                                    Button(action: {
                                        botaoAlimentoAction(id: info.id)
                                    }) {
                                        Rectangle()
                                            .frame(width: 360, height: 70)
                                            .foregroundColor(.green)
                                            .opacity(0.4)
                                            .offset(x: animateRectangule ? 0 : -UIScreen.main.bounds.width)
                                            .animation(.easeOut(duration: 1), value: animateRectangule)
                                            .onAppear { animateRectangule = true }
                                    }
                                    VStack {
                                        HStack {
                                            Image(systemName: "clock.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 15, height: 15)
                                                .offset(x: animateText ? 0 : -UIScreen.main.bounds.width)
                                                .animation(.easeOut(duration: 1), value: animateText)
                                                .onAppear { animateText = true }
                                            
                                            Text(info.horario ?? "")
                                                .foregroundStyle(.black)
                                                .bold()
                                                .offset(x: animateText ? 0 : -UIScreen.main.bounds.width)
                                                .animation(.easeOut(duration: 1), value: animateText)
                                                .onAppear { animateText = true }
                                            
                                            Spacer().frame(width: 210)
                                            
                                            Text("\(info.calorias ?? 0) Kcal")
                                                .foregroundStyle(.black)
                                                .bold()
                                                .offset(x: animateText ? 0 : -UIScreen.main.bounds.width)
                                                .animation(.easeOut(duration: 1), value: animateText)
                                                .onAppear { animateText = true }
                                        }
                                        Text(info.alimento ?? "")
                                            .foregroundStyle(.black)
                                            .bold()
                                            .frame(maxWidth: 350, alignment: .leading)
                                            .offset(x: animateText ? 0 : -UIScreen.main.bounds.width)
                                            .animation(.easeOut(duration: 1), value: animateText)
                                            .onAppear { animateText = true }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if showNotification, let selectedId = selectedId {
                MaisInfo(id: selectedId, alimentos: alimentosDoDia) {
                    withAnimation {
                        showNotification = false
                    }
                }
                .transition(.move(edge: .top))
                .zIndex(1)
            }
        }
        .onAppear {
            foods.fetch()
        }
    }
    
    func botaoAlimentoAction(id: UUID) {
        selectedId = id
        withAnimation {
            showNotification = true
        }
    }

}
#Preview {
    InfoAlimentos(date: .constant(Date()))
}
