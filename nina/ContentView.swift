//
//  ContentView.swift
//  nina
//
//  Created by Ishaan Arya on 09/03/24.
//



import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.white.opacity(0.95).edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(" ✨ NINA ✨ ")
                    .font(.system(size: 36, weight: .bold, design: .default))
                    .foregroundColor(.blue)
                    .padding(.top, 100) // Adjust this padding as needed
                
                AnimatedSearchBar()
                    .padding(.horizontal, 20)
                    .padding(.top, 125)
                
                Spacer()
                // Optionally, you can add padding to move the search bar up
                .padding(.bottom, 20) // Adjust this padding to move the search bar higher
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
    

