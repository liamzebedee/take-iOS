
//
//  ContentView.swift
//  take
//
//  Created by Liam Edwards-Playne on 21/1/2023.
//

import SwiftUI
import CoreData

import WebKit

struct WebView: UIViewRepresentable {
    var url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}




struct TakeView: View {
    let take: Take
    
    @State private var isRemixPopoverOpen = false
//    @Binding var isRemixPopoverOpen: Bool
    
    @State private var mintButtonDisabled = false
    @State private var newTakeText = ""

    var body: some View {
            
            VStack(alignment: .leading) {
                Text(take.owner!)
                    .font(.subheadline)
                
                Text(take.description!)
                    .font(.title2)
                
                
                // https://www.hackingwithswift.com/articles/237/complete-guide-to-sf-symbols
                HStack(spacing: 20) {
                    Button(action: likeTake) {
                        Text("\(Image(systemName: "heart")) Like")
                            .foregroundColor(Theme().brandColor)
                    }
                    
                    Button(action: remixTake) {
                        Text("\(Image(systemName: "theatermask.and.paintbrush.fill")) Remix")
                            .foregroundColor(Theme().brandColor)
                    }
                    
                    ShareLink(
                        item: "https://takexyz.vercel.app/t/-" + String(take.id!),
                        message: Text(take.description!)
                    )
                    .foregroundColor(Theme().brandColor)
                    
                }
                .padding(20)
            }.padding()
        
            .popover(isPresented: $isRemixPopoverOpen) {
                RemixTakePopover(takeTemplate: take, close: self.closeRemixPopover)
            }
        
    }
        
    

        
    
    private func likeTake() {}
    
    private func remixTake() {
        self.isRemixPopoverOpen = true
//        self.isShowingPopover = true
    }
    
    func closeRemixPopover() {
        self.isRemixPopoverOpen = false
    }

}


struct Previews_TakeView_Previews: PreviewProvider {
    static func getMockTake() -> Take {
        var take = Take()
        take.id = 1
        take.description = "[xx] is swag"
        take.owner = "0x"
        take.refs = [0,0,0];
        return take
    }
    
    static var previews: some View {
        TakeView(take: getMockTake())
    }
}
