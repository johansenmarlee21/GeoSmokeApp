import SwiftUI


struct TopView: View{
    
    
    
    var body: some View{
        NavigationStack{
            
            VStack{
                MapView()
                    .edgesIgnoringSafeArea(.all)
            }
            
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Text("GeoSmoke")
                        .font(.system(size: 22, weight: .bold))
                        .padding(.vertical, 25)
                }
                ToolbarItem(placement: .topBarTrailing){
                    Button(action: {
                        print("button preference")
                    }){
                        
                        VStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.white)
                                .padding(7)
                                .background(Color.darkGreen)
                                .clipShape(Circle())
                            
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing){
                    Button(action: {
                        print("hehehe")
                    }){
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.white)
                                .padding(7)
                                .background(Color.darkGreen)
                                .clipShape(Circle())
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing){
                    Button(action: {
                        print("sldhfds")
                    }){
                        Image(systemName: "smoke.fill")
                            .foregroundColor(.darkGreen)
                    }
                }
            }.toolbarBackground(.visible, for: .navigationBar)
                
        }
    }
}


 
#Preview {
    TopView()
}
