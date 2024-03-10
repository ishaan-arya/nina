import SwiftUI

struct ProgressScreen: View {
    @Binding var showProgressScreen: Bool
    @State private var bounce = false
    @State private var progress = 0.5
    @State private var showSparkle = false
    let progressBarWidth: CGFloat = 350

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            if showSparkle {
                Text("✨")
                    .font(.system(size: 72))
                    .foregroundColor(.blue)
                    .transition(.scale)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showProgressScreen = false
                        }
                    }
        
            } else {
                VStack {
                    Spacer()

                    Text("📁")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                        .offset(y: bounce ? -10 : 10)
                        .onAppear {
                            bounceAnimation()
                        }
                    
                    Spacer()

                    // Custom progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: progressBarWidth, height: 20)
                            .foregroundColor(Color.gray.opacity(0.2))

                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: progressBarWidth * CGFloat(progress), height: 20)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.3)]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10)
                    }
                    .frame(width: progressBarWidth, height: 20)
                    .animation(.linear(duration: 0.2), value: progress)

                    Spacer()
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 50)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation {
                            showSparkle = true
                        }
                    }
                }
            }
        }
    }

    private func bounceAnimation() {
        withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            bounce = true
        }
    }
}

struct ProgressScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProgressScreen(showProgressScreen: .constant(true))
    }
}
