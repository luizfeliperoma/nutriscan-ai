import Foundation

class ViewModelAlimentos: ObservableObject {
    @Published var food: [alimentacao] = []
    @Published var isLoading = false

    @Published var totalProteina: Double = 0
    @Published var totalCarboidrato: Double = 0
    @Published var totalGordura: Double = 0
    @Published var totalCalorias: Int = 0

    func fetch() {
        guard let url = URL(string: "http://192.168.128.92:1880/alimentos") else { return }
        isLoading = true
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
            }
            guard let data = data, error == nil else { return }
            do {
                let parsed = try JSONDecoder().decode([alimentacao].self, from: data)
                DispatchQueue.main.async {
                    self.food = parsed
                    self.calculateTotals()
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }

    private func calculateTotals() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let hoje = formatter.string(from: Date())

        let deHoje = food.filter { $0.data == hoje }
        totalProteina = deHoje.map(\.proteina!).reduce(0, +)
        totalCarboidrato = deHoje.map(\.carboidrato!).reduce(0, +)
        totalGordura = deHoje.map(\.gordura!).reduce(0, +)
        totalCalorias = deHoje.map(\.calorias!).reduce(0, +)
    }
}
