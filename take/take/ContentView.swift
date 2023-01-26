//
//  ContentView.swift
//  take
//
//  Created by Liam Edwards-Playne on 26/1/2023.
//

import Foundation
import SwiftUI

struct ContentView: View {

    var body: some View {
                
        TabView {
            FeedView()
//                .badge(2)
                .tabItem {
                    Label("TAKES", systemImage: "bolt.fill")
                }
            FavesView()
                .tabItem {
                    Label("BAGS", systemImage: "bag.fill")
                }
//            AccountView()
//                .badge("!")
//                .tabItem {
//                    Label("Account", systemImage: "person.crop.circle.fill")
//                }
        }

    }

}


struct Previews_ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
