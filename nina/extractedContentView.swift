import SwiftUI

struct ExtractedContentView: View {

    @Binding var isShowing: Bool

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
                    .padding(.top, 100)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.overlay(
            Button(action: {
                self.isShowing = false
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.blue)
                    .shadow(color: .blue, radius: 2, x: 0, y: 0)

            }
            .padding([.top, .leading], 16), alignment: .topLeading
            
        )
    }
}


struct ExtractedContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExtractedContentView(isShowing: .constant(true))

                    .padding(.top, 125)

                Spacer()
            }
        }
    }
}


