import Foundation
import GoogleGenerativeAI



enum APIKey {
    static var `default`: String {
        guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist") else {
            fatalError("Sem Key na Variavel de Ambiente")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Key com nome incorreto ou tipo incorreto")
        }
        if value.starts(with: "_") {
            fatalError("Ver Doc")
        }
        return value
    }
}


enum APIError: Error, LocalizedError {
    case invalidURL
    case emptyOrInvalidData
    case networkError(Error)
    case decodingError(Error)
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL inválida fornecida."
        case .emptyOrInvalidData: return "Dados vazios ou formato inválido recebido."
        case .networkError(let error): return "Erro de rede: \(error.localizedDescription)"
        case .decodingError(let error): return "Erro ao decodificar dados: \(error.localizedDescription)"
        }
    }
}



class Gemini : ObservableObject {
    
    @Published var inputUser : String = "";
    
    private let model = GenerativeModel(name: "gemini-2.0-flash", apiKey: APIKey.default)
    
    init() {}
    
    func chat(value: String) async -> String {
        do {
            let response = try await model.generateContent("Você é um chatbot apelidado de 'NutrIA. Responda a pergunta como um nutricionista especialista em nutrição humana, de modo didatico e informal, informando valores nutricionais se necessario, imitando um dialogo humando simples, faça em apenas 1 paragrafo e no maxímo 150 caracteres, sempre em português e em texto plano, e caso a pergunta não for relacionado ao tema, ignorar respondendo como default 'Desculpe! Não sei nada sobre isso, tente me perguntar algo sobre nutrição e alimentação', se a pergunta estiver vazia, peça para perguntar novamente. Não terminar com quebra de linha ou '\n'!. A pergunta é : \(value)")
            
            
            return response.text ?? "Error"
        } catch {
            return "Error na interação com Gemini: \(error.localizedDescription)"
        }
    }
}
