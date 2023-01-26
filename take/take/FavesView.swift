//
//  File.swift
//  take
//
//  Created by Liam Edwards-Playne on 24/1/2023.
//

import Foundation
import SwiftUI

struct FavesView: View {
    var body: some View {
        NavigationView {
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text("420 HYPE")
                        .font(.largeTitle)
                    Spacer()
                }
                
                Spacer()
                
            }
            .padding()
            
            
            
            .navigationBarTitle(
                Text("Portfolio")
            )
        }
        
    }
}

struct Previews_FavesView_Previews: PreviewProvider {
    static var previews: some View {
        FavesView()
    }
}
