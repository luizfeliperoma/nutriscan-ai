import SwiftUI
import GoogleGenerativeAI
import UIKit

struct AddView: View {
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var showResultSheet = false
    @State private var iaResponse = ""
    @State private var isAnalyzing = false

    @State private var iaResponseText: [String] = []

    @StateObject private var viewModel = ViewModelAlimentos2()

    @State private var showAlert = false
    @State private var alertMessage = ""

    @State private var showTextSheet = false
    @State private var userFoodText = ""

    let model = GenerativeModel(name: "gemini-2.0-flash", apiKey: APIKey.default)

    private func extractNumber(from text: String) -> Double {
        let cleanText = text
            .replacingOccurrences(of: "g", with: "")
            .replacingOccurrences(of: "kcal", with: "")
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: "\n", with: "")

        return Double(cleanText) ?? 0.0
    }

    func analyzeImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            iaResponse = "Erro ao converter imagem."
            showResultSheet = true
            return
        }
        iaResponse = ""
        isAnalyzing = true

        Task {
            do {
                let prompt = "Analise a imagem e identifique o alimento ou prato de comida ou bebida, considerando o tamanho ou quantidade visível (por exemplo, uma fatia, um prato com varios alimentos ou bebidas, uma lata, um copo, uma porção, etc).Se o alimento ou bebida for de tamanho ou proporção padrão (como uma lata, uma garrafa, uma barra, etc), pesquise na internet o valor calórico, gordura, carboidrato e proteínas correspondente à unidade apresentada.Informe apenas a estimativa de calorias, gordura, carboidrato e proteínas correspondente à porção apresentada na foto.Seja objetivo e responda apenas com os valores aproximados.Se você identificar que esse alimento ou bebida não possui calorias, retorne que esse alimento não possui nenhuma caloria. Responda no seguinte formato: [nome do alimento ou bebida]; [calorias]; [gordura, (valor em gramas)]; [carboidrato, (valor em gramas)]; [Proteínas, (valor em gramas)] (separado por ponto e vírgula, exemplo: Banana; 205; 2.2g; 56g; 4g). Se não for possível identificar, responda apenas: Não foi possível identificar o alimento ou bebida."

                let parts: [ModelContent.Part] = [
                    .data(mimetype: "image/jpeg", imageData),
                    .text(prompt)
                ]
                let input = ModelContent(parts: parts)
                let response = try await model.generateContent([input])
                iaResponse = response.text ?? "Não consegui analisar a imagem."

            } catch {
                iaResponse = "Erro: \(error.localizedDescription)"
            }
            isAnalyzing = false
            showResultSheet = true
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.956, green: 0.956, blue: 0.961)
                .ignoresSafeArea()

            VStack {
                Text("Adicionar Comida")
                    .bold()
                    .font(.system(size: 30))
                    .foregroundColor(.black)
                    .padding(.top, 10)
                

                Text("Escolha como deseja registrar sua refeição:")
                    .foregroundStyle(.gray)
                    .padding(.top, 2)

                Spacer()

                VStack {
                    VStack(spacing: 16) {
                        // Botão de Foto
                        Button(action: {
                            showCamera = true
                        }) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.2))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "camera")
                                        .foregroundColor(Color(red: 0, green: 0.5, blue: 0))
                                        .font(.system(size: 24))
                                }
                                VStack(alignment: .leading) {
                                    Text("Foto")
                                        .bold()
                                        .foregroundColor(.black)
                                        .font(.system(size: 20))
                                    Text("Tire uma foto do seu prato")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 18))
                                }
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        .disabled(isAnalyzing)

                        // Botão de Texto
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.8, green: 0.65, blue: 0.0).opacity(0.2))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "pencil")
                                    .foregroundColor(Color(red: 0.8, green: 0.65, blue: 0.0))
                                    .font(.system(size: 24, weight: .bold))
                            }
                            VStack(alignment: .leading) {
                                Text("Texto")
                                    .bold()
                                    .foregroundColor(.black)
                                    .font(.system(size: 20))
                                Text("Digite a descrição do alimento")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 18))
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .onTapGesture {
                            showTextSheet = true
                        }
                        .disabled(isAnalyzing)
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }

            // LOADING OVERLAY
            if isAnalyzing {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                ProgressView("Analisando...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
            }
        }

        // Sheet de Resultado
        .sheet(isPresented: $showResultSheet) {
            VStack(spacing: 24) {
                Capsule()
                    .frame(width: 40, height: 5)
                    .foregroundColor(.gray.opacity(0.3))
                    .padding(.top, 8)
                Text("Informação nutricional.")
                    .font(.headline)
                    .foregroundStyle(.black)

                VStack(alignment: .leading, spacing: 16) {
                    if iaResponseText.count >= 5 {
                        HStack {
                            Text(iaResponseText[0].trimmingCharacters(in: .whitespaces).capitalized)
                                .font(.title)
                                .bold()
                            Spacer()
                        }
                        Divider()
                        HStack {
                            Label("Calorias", systemImage: "flame.fill")
                                .foregroundColor(.blue)
                            Spacer()
                            Text("\(iaResponseText[1].trimmingCharacters(in: .whitespaces)) kcal")
                                .bold()
                        }
                        HStack {
                            Label("Gordura", systemImage: "drop.fill")
                                .foregroundColor(.red)
                            Spacer()
                            Text("\(iaResponseText[2].trimmingCharacters(in: .whitespaces)) ")
                        }
                        HStack {
                            Label("Carboidrato", systemImage: "leaf.fill")
                                .foregroundColor(.orange)
                            Spacer()
                            Text("\(iaResponseText[3].trimmingCharacters(in: .whitespaces)) ")
                        }
                        HStack {
                            Label("Proteínas", systemImage: "bolt.fill")
                                .foregroundColor(.yellow)
                            Spacer()
                            Text("\(iaResponseText[4].trimmingCharacters(in: .whitespaces)) ")
                        }
                    } else {
                        Text("Dados insuficientes para exibir.")
                            .foregroundColor(.red)
                            .bold()
                    }
                }
                .padding()
                .foregroundColor(.primary)

                if viewModel.isLoading {
                    ProgressView("Salvando...")
                        .padding()
                        .foregroundColor(.black)
                }

                Button(action: {
                    guard iaResponseText.count >= 5 else { return }

                    let alimento = iaResponseText[0].trimmingCharacters(in: .whitespaces)
                    let calorias = Int(extractNumber(from: iaResponseText[1]))
                    let gordura = extractNumber(from: iaResponseText[2])
                    let carboidrato = extractNumber(from: iaResponseText[3])
                    let proteina = extractNumber(from: iaResponseText[4])

                    viewModel.saveFood(
                        alimento: alimento,
                        calorias: calorias,
                        proteina: proteina,
                        gordura: gordura,
                        carboidrato: carboidrato
                    ) { success in
                        alertMessage = success
                            ? "Alimento salvo com sucesso!"
                            : "Erro ao salvar alimento. Tente novamente."
                        showAlert = true
                        if success {
                            showResultSheet = false
                            capturedImage = nil
                        }
                    }
                }) {
                    Text(viewModel.isLoading ? "Salvando..." : "Adicionar")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isLoading ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal)

                Spacer()
            }
            .background(Color(.systemGray5).opacity(0.7))
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                    iaResponseText = iaResponse.components(separatedBy: ";")
                }
            }
        }

        // Sheet de Texto
        .sheet(isPresented: $showTextSheet) {
            VStack(spacing: 24) {
                Capsule()
                    .frame(width: 40, height: 5)
                    .foregroundColor(.gray.opacity(0.3))
                    .padding(.top, 8)
                Text("Descreva o alimento")
                    .font(.headline)
                    .foregroundStyle(.black)
                TextEditor(text: $userFoodText)
                    .frame(height: 120)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .font(.system(size: 18))
                Button("Analisar") {
                    let prompt = """
                    Analise o texto abaixo e identifique todos os alimentos, pratos de comida ou bebidas mencionados, considerando o tamanho ou quantidade se houver. Se o texto mencionar mais de um alimento, prato ou bebida, some os valores aproximados de calorias, gordura (em gramas), carboidrato (em gramas) e proteínas (em gramas) de todos eles, e coloque todos os nomes juntos, separados por vírgula, no campo "nome do alimento ou prato". Use o nome completo de cada item, conforme mencionado no texto.

                    Responda exatamente no seguinte formato, separando cada campo por ponto e vírgula (;) e sem adicionar quebras de linha no final: nome do alimento ou prato (com todos os itens mencionados, separados por vírgula); calorias; gordura (em gramas); carboidrato (em gramas); proteínas (em gramas)

                    Exemplo para um alimento:
                    Banana; 205; 2.2g; 56g; 4g

                    Exemplo para mais de um alimento:
                    Arroz, feijão, bife e salada; 500; 20g; 45g; 32g

                    Se não for possível identificar, responda apenas: Não foi possível identificar o alimento ou bebida.

                    Texto: \(userFoodText)
                    """
                    iaResponse = ""
                    isAnalyzing = true
                    showTextSheet = false
                    Task {
                        do {
                            let response = try await model.generateContent(prompt)
                            iaResponse = response.text ?? "Não consegui analisar o texto."
                        } catch {
                            iaResponse = "Erro: \(error.localizedDescription)"
                        }
                        isAnalyzing = false
                        showResultSheet = true
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(userFoodText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Spacer()
            }
            .padding()
            .background(Color(.gray).opacity(0.6))
            .presentationDetents([.medium, .large])
        }

        // Sheet da Câmera
        .sheet(isPresented: $showCamera, onDismiss: {
            if let image = capturedImage {
                analyzeImage(image)
            }
        }) {
            ImagePicker(sourceType: .camera, selectedImage: $capturedImage)
        }

        // Alerta de resultado
        .alert("Resultado", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
}

#Preview {
    AddView()
}
