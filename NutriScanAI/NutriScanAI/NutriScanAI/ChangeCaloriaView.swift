import SwiftUI

struct ChangeCaloriaView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var novaMeta: String = String(CalorieData.goal)
    @State private var showAlert = false

    var body: some View {
        ScrollView {
            
        
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 72, height: 72)
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 4)
                    .frame(width: 60, height: 60)
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    .frame(width: 40, height: 40)
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
            }
            .padding(.top, 40)

            VStack(spacing: 4) {
                Text("Meta Diária de Calorias")
                    .font(.title2)
                    .bold()
                Text("Ajuste sua meta diária")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Nova meta (kcal)")
                    .font(.headline)
                TextField("", text: $novaMeta)
                    .font(.title)
                    .bold()
                    .keyboardType(.numberPad)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .submitLabel(.done)
                    .background(Color(white: 0.95))
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
                    
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Dicas:")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 4) {
                    Text("• A meta ideal varia de pessoa por pessoa")
                    Text("• Considere seu objetivo")
                    Text("• Consulte um nutricionista")
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.gray)
                .font(.subheadline)
                .padding()
                .background(Color(white: 0.95))
                .cornerRadius(8)
            }


            HStack {
                Button("Salvar Meta") {
                    if let nova = Int(novaMeta), nova > 0 && nova > CalorieData.consumed{
                        CalorieData.goal = nova
                        dismiss()
                    }
                    else {
                        showAlert = true
                    }
                
                }
                .alert("Atenção", isPresented: $showAlert) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text("Digite uma quantidade válida.")
                        }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
                
            }
            .padding(.bottom, 40)
        }
        .padding()
        .navigationTitle("Meta de Calorias")
        .navigationBarTitleDisplayMode(.inline)
    }
}
}

#Preview {
        ChangeCaloriaView()
    
}
