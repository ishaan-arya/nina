import SwiftUI

struct ExtractedContentView: View {
    var body: some View {
        ZStack {
            Color.white.opacity(0.95).edgesIgnoringSafeArea(.all)

            VStack {
                Text("✨ NINA ✨")
                    .font(.system(size: 36, weight: .bold, design: .default))
                    .foregroundColor(.blue)
                    .padding(.top, 100)

                AnimatedSearchBar()
                    .padding(.horizontal, 20)
                    .padding(.top, 125)

                Spacer()
            }
        }
    }
}

struct ExtractedContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExtractedContentView()
    }
}
