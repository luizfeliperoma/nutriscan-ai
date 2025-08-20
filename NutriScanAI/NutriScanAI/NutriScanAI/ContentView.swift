//
//  ContentView.swift
//  NutriScan
//
//  Created by Turma02-25 on 23/07/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack{

            TabView{
                HomeView()
                    .tabItem {
                        Label("Início", systemImage: "house")
                            
                    }
                    
                AddView()
                    .tabItem {
                        Label("Adicionar", systemImage: "plus")
                    }
                
                CalendarView()
                    .tabItem {
                        Label("Calendário", systemImage: "calendar")
                    }
                
                ChatView()
                    .tabItem {
                        Label("Chat", systemImage: "message")
                            
                    }
                    
            }.accentColor(.green)


            
        }
    }
}

#Preview {
    ContentView()
}
