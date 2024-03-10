import SwiftUI
import AppKit

func openFinder(at path: String) {
    if let url = URL(string: path) {
        NSWorkspace.shared.open(url)
    }
}

struct ProgressScreen: View {
    @Binding var showProgressScreen: Bool
    @State private var bounce = false
    @State private var progress = 0.5
    @State private var showSparkle = false
    let progressBarWidth: CGFloat = 350

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            VStack {
                if showSparkle {
                    Spacer()
                    Text("✨")
                        .font(.system(size: 72))
                        .foregroundColor(.blue)
                        .transition(.scale)
                    Spacer()
                    Button(action: {
                        openFinder(at: "file:///Users/ishaanarya/Documents/")
                    }) {
                        Label("Open in Finder", systemImage: "arrow.right.circle.fill")
                            .foregroundColor(.white)
                            .padding(.vertical, 5) // Reduced vertical padding to decrease button height
                    }
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.3)]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
                    .frame(height: 30) // Fixed height for the button
                    .overlay(
                        RoundedRectangle(cornerRadius: 10) // This overlay ensures no border is applied
                            .stroke(Color.clear, lineWidth: 0)
                    )
                    Spacer()
                } else {
                VStack {
                    Spacer()

                    Text("📁")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
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
                        .padding(.horizontal, 50)
                        .onAppear {
                            if !showSparkle {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    withAnimation {
                                        showSparkle = true
                                    }
                                }
                            }
                        }
                    }
                    .background(Color.white.edgesIgnoringSafeArea(.all))
                }

    private func bounceAnimation() {
        withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            bounce = true
        }
    }
}

struct HorizontalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .imageScale(.large)
                .foregroundColor(.white)
            configuration.title
        }
    }
}

struct ProgressScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProgressScreen(showProgressScreen: .constant(true))
    }
}
