//
//  ModelAlimento.swift
//  AulaTeste
//
//  Created by Turma02-27 on 24/07/25.
//

import Foundation

struct alimentacao: Decodable, Hashable{
    let id = UUID()
    let data: String?
    let horario: String?
    let calorias: Int?
    let alimento: String?
    let proteina: Double?
    let gordura: Double?
    let carboidrato: Double?
    
}
