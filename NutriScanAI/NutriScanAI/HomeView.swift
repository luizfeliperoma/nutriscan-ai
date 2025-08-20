import SwiftUI

struct CalorieData {
    static var goal: Int = 2500
    static var consumed: Int = ViewModelAlimentos().totalCalorias

}

struct HomeView: View {
    @State private var botao = false
    @State private var goal: Int = CalorieData.goal

    @StateObject var info = ViewModelAlimentos()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Olá, Gabriel")
                    .font(.title).frame(maxWidth: .infinity, alignment: .leading).bold()

                Text("Como está sua alimentação hoje?")
                    .font(.title3).frame(maxWidth: .infinity, alignment: .leading)

                if info.isLoading {
                    Spacer()
                    ProgressView("Carregando dados...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .padding()
                    Spacer()
                } else {
                    VStack(spacing: 24) {
                        indicator(title: "NutriScan", subtitle: "Alimentando o futuro da sua saúde")

                        NavigationLink(destination: ChangeCaloriaView()) {
                            ZStack {
                                Circle().stroke(Color.gray.opacity(0.2), lineWidth: 12)
                                    .frame(width: 150, height: 150)
                                Circle()
                                    .trim(from: 0, to: min(CGFloat(info.totalCalorias) / CGFloat(goal), 1))
                                    .stroke(info.totalCalorias > goal ? Color.red : Color.green,
                                            style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 150, height: 150)

                                VStack {
                                    Text("\(info.totalCalorias)")
                                        .foregroundStyle(info.totalCalorias > goal ? .red : .blue)
                                        .font(.system(size: 36, weight: .bold))
                                    Text("de \(goal) kcal")
                                        .font(.subheadline).foregroundColor(.secondary)
                                    if info.totalCalorias > goal {
                                        Text("Excedeu \(info.totalCalorias - goal)")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    } else {
                                        Text("\(goal - info.totalCalorias) restantes")
                                            .font(.caption).foregroundColor(.green)
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Macronutrientes").font(.headline)
                            macroRow(name: "Proteínas", values: info.totalProteina, color: .yellow)
                            macroRow(name: "Carboidratos", values: info.totalCarboidrato, color: .orange)
                            macroRow(name: "Gorduras", values: info.totalGordura, color: .pink)
                        }
                    }

                    Button("DETALHES") {
                        botao = true
                    }
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.green).cornerRadius(12)
                    .sheet(isPresented: $botao) {
                        InfoAlimentos(date: .constant(Date()))
                    }
                }
            }
            .onAppear {
                goal = CalorieData.goal
                info.fetch()
            }
            .padding()
        }
    }

    @ViewBuilder
    func indicator(title: String, subtitle: String) -> some View {
        VStack {
            Text(title).font(.headline).foregroundStyle(.green)
            Text(subtitle).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity).padding().background(Color(.systemGray6)).cornerRadius(12)
    }

    @ViewBuilder
    func macroRow(name: String, values: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                Spacer()
                Text(String(format: "%.2fg", values))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            ProgressView(value: 10)
                .accentColor(color)
        }
    }
}

#Preview {
    HomeView()
}
