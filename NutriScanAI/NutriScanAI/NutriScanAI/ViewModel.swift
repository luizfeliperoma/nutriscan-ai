import Foundation

class ViewModelAlimentos2: ObservableObject {
    @Published var food: [alimentacao] = []
    @Published var isLoading = false
    
    func fetch(completion: (() -> Void)? = nil) {
        isLoading = true
        guard let url = URL(string: "http://192.168.128.92:1880/alimentos") else {
            isLoading = false
            completion?()
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    self?.isLoading = false
                    completion?()
                    return
                }

                do {
                    let parsed = try JSONDecoder().decode([alimentacao].self, from: data)
                    self?.food = parsed
                } catch {
                    print(error)
                }

                self?.isLoading = false
                completion?()
            }
        }

        task.resume()
    }
    
    func saveFood(alimento: String, calorias: Int, proteina: Double, gordura: Double, carboidrato: Double, completion: @escaping (Bool) -> Void) {
        isLoading = true
        guard let url = URL(string: "http://192.168.128.92:1880/alimentos") else {
            isLoading = false
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let data = dateFormatter.string(from: Date())
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let horario = timeFormatter.string(from: Date())
        
        let foodData = [
            "data": data,
            "horario": horario,
            "calorias": calorias,
            "alimento": alimento,
            "proteina": proteina,
            "gordura": gordura,
            "carboidrato": carboidrato
        ] as [String : Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: foodData)
        } catch {
            isLoading = false
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        
        task.resume()
    }
}
