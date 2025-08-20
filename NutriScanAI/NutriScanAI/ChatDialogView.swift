
import SwiftUI

struct ChatDialogView: View {
    
    var user : Bool;
    var dialog: ChatMessage;
    
    var body: some View {
        
        HStack{
            
            VStack{
                HStack{
                    Text(dialog.nome)
                        .font(.headline)
                }
                .padding(.horizontal)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: (!user ? .trailing : .leading))
                
                Text(dialog.value)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                
                
            }
            .padding()
            .frame(alignment: (user ? .trailing : .leading))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                    .padding(.horizontal, 10)
            )
        }
        
    }
}

#Preview {
    ChatDialogView(user:false, dialog: ChatMessage(nome: "Teste", value: "Testando essas merdas"))
}
