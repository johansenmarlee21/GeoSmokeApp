import SwiftUI

struct SplashScreenView: View {
    @State private var showGreenLogo = false

    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                if showGreenLogo {
                    Image("LogoSplashGreen")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                        .transition(.opacity.combined(with: .scale))
                } else {
                    Image("LogoSplashOrange")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.easeInOut(duration: 0.6), value: showGreenLogo)
            .padding(.bottom, 0)

            Text("GeoSmoke")
                .font(.system(size: 40))
                .fontWeight(.bold)
                .foregroundColor(Color.black)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showGreenLogo = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
