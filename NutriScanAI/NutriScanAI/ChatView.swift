//
//  ChatView.swift
//  ScanApp
//
//  Created by Turma02-19 on 24/07/25.
//

import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let nome: String
    let value: String
}


struct ChatView: View {
    
    
    @State var userDialog : String = "";
    @State var chat: [ChatMessage] = [ChatMessage(nome:"NutrIA",value: "Salve meu amigo(a), tire sua duvida sobre alimentação comigo!")];
    @ObservedObject var cmd = Gemini()
    @State var isSending: Bool = false;
    
    var body: some View {
        VStack{
            
            Text("NutrIA Chat")
                .font(.system(size: 30))
                .bold()
                .padding(.top, 10)
            ScrollViewReader{ scrolling in
                
                ScrollView{
                    
                    
                    ForEach(Array(chat.enumerated()), id: \.element.id) { index, dialog in
                        
                        ChatDialogView(user: (dialog.nome != "Você" && dialog.nome != "NutrIA está pensando..." ? false : true ), dialog: dialog)
                        
                    }
                    
                    
                }
                .padding(.vertical,10)
                .onChange(of: chat.last?.id)
                {
                    if let lastID = chat.last?.id {
                        withAnimation {
                            scrolling.scrollTo(lastID, anchor: .bottom)
                            
                        }
                    }
                }
            }
            
                HStack{
                    TextField("Pergunte algo sua alimentação",text: $userDialog)
                        .padding()
                        .foregroundColor(.black)
                        .submitLabel(.send)
                        .onSubmit {
                            isSending = true
                            chat.append(ChatMessage(nome:"Você",value: userDialog))
                            
                            chat
                                .append(
                                    ChatMessage(nome: "NutrIA está pensando...", value: ""))
                            Task{
                                let response : String = await  cmd.chat(value: userDialog)
                                userDialog = "";
                                chat
                                    .removeLast()
                                chat.append(ChatMessage(nome:"NutrIA",value: response))
                                isSending = false
                            }
                            
                        }
                        .disabled(isSending)
                    Button(action: {
                        isSending = true;
                        chat.append(ChatMessage(nome:"Você",value: userDialog))
                        
                        chat
                            .append(
                                ChatMessage(nome: "NutrIA está pensando...", value: ""))
                        Task{
                            let response : String = await  cmd.chat(value: userDialog)
                            userDialog = "";
                            chat
                                .removeLast()
                            chat.append(ChatMessage(nome:"NutrIA",value: response))
                            isSending = false;
                        }
                        
                    }){
                        Image(systemName: "paperplane.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 30))
                            .padding()
                    }
                    
                    .disabled(isSending)
                }
                .frame(height: 70)
                .background(.white)
                .shadow(color: .gray.opacity(0.1), radius: 10, x: 0)
                
            }
        }
    }
    
    #Preview {
        ChatView()
    }
