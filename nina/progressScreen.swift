import SwiftUI
import AppKit

func openFinder(at path: String) {
    if let url = URL(string: path) {
        NSWorkspace.shared.open(url)
    }
}

struct ProgressScreen: View {
    @Binding var showProgressScreen: Bool
    @Binding var isLoading: Bool  // Track the loading status from the parent view

    @State private var bounce = false
    var folderPath: String
    @State private var progress = 0.5
    @State private var showSparkle = false
    let progressBarWidth: CGFloat = 350

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            if showSparkle {
                VStack {
                    Spacer()
                    Text("✨")
                        .font(.system(size: 72))
                        .foregroundColor(.blue)
                        .transition(.scale)
                    Spacer()
                    Button(action: {
                        // Replace with actual path when "Open in Finder" is clicked
                        openFinder(at: folderPath)
                    }) {
                        Label("Open in Finder", systemImage: "arrow.right.circle.fill")
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                    }
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
                    .frame(height: 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.clear, lineWidth: 0)
                    )
                    Spacer()
                }
            } else {
                VStack {
                    Spacer()

                    Text("📁")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                        .offset(y: bounce ? -10 : 10)
                        .onAppear { bounceAnimation() }
                    
                    Spacer()

              

                }
                .padding(.vertical, 50)
                .padding(.horizontal, 80)
            }
        }
        .onChange(of: isLoading) { loading in
            if !loading {
                // If not loading, trigger the sparkle after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showSparkle = true
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
        ProgressScreen(showProgressScreen: .constant(true), isLoading: .constant(false), folderPath: "")
    }
}
