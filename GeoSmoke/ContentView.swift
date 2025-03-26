import SwiftUI

struct ContentView: View {
    
    @State private var showModal = false
  
    var body: some View{
        ZStack{
            TopView()
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showModal = true
            }
        }
        .sheet(isPresented: $showModal){
            BottomModalView()
                .presentationDetents([.medium, .fraction(0.15)])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
        }
        
    }
    
    }

#Preview {
    ContentView()
}
