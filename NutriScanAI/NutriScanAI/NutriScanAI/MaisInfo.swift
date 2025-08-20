//
//  MaisInfo.swift
//  AulaTeste
//
//  Created by Turma02-27 on 25/07/25.
//

import SwiftUI

// MaisInfo.swift
struct MaisInfo: View {
    var id: UUID
    var alimentos: [alimentacao]
    var onClose: () -> Void
    
    var alimentoSelecionado: alimentacao? {
        alimentos.first(where: { $0.id == id })
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            
            if let alimento = alimentoSelecionado {
                Text("🍽️ \(alimento.alimento ?? "N/A")")
                    .font(.title3)
                    .bold()
                
                Text("🕒 \(alimento.horario ?? "N/A")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                Text("🔥 Calorias: \(alimento.calorias ?? 0) kcal").foregroundStyle(.blue).bold()
                Text(String(format: "🥩 Proteína: %.1f g", alimento.proteina ?? 0.0)).foregroundStyle(.yellow).bold()
                Text(String(format: "🥑 Gordura: %.1f g", alimento.gordura ?? 0.0)).foregroundStyle(.red).bold()
                Text(String(format: "🍞 Carboidrato: %.1f g", alimento.carboidrato ?? 0.0)).foregroundStyle(.orange).bold()
            } else {
                Text("Alimento não encontrado")
                    .foregroundColor(.red).bold()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
        .frame(maxHeight: 300)
        .transition(.move(edge: .top))
        .zIndex(1)
    }
}



#Preview {
    MaisInfo(id: UUID(), alimentos: [], onClose: {})
}
