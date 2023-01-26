//
//  NewTakePopover.swift
//  take
//
//  Created by Liam Edwards-Playne on 26/1/2023.
//

import Foundation
import SwiftUI
import Web3
import PromiseKit

struct TemplateSpan: Identifiable {
    let id = UUID()
    var text: String
    var isVar: Bool
}

// Renders a highlighted form of the take template, where [xx], [yy], and [zz] are coloured variables.
// And the values are replaced by the bindings in self.xx, self.yy, and self.zz.
struct TakeTemplateText: View {
    @State var take: String
    @Binding var xx: String
    @Binding var yy: String
    @Binding var zz: String
    
    func renderTemplateTake() -> [TemplateSpan] {
        // Replace [xx], [yy], and [zz]
        let xx1 = self.xx == "" ? "[xx]" : self.xx
        let yy2 = self.yy == "" ? "[yy]" : self.yy
        let zz3 = self.zz == "" ? "[zz]" : self.zz
        
        var spans: [TemplateSpan] = []
        var currentSpan = ""
        var isVar = false
        
        let text2 = self.take
            .replacingOccurrences(of: "[xx]", with: xx1, options: .literal)
            .replacingOccurrences(of: "[yy]", with: yy2, options: .literal)
            .replacingOccurrences(of: "[zz]", with: zz3, options: .literal)

        
        for (i, c) in text2.enumerated() {
//            print(i, currentSpan)
            if(c == "[") {
                // End previous span.
                spans.append(TemplateSpan(text: currentSpan, isVar: isVar))
                currentSpan = ""
                
                // Begin new span.
                isVar = true
                currentSpan += "" + String(c)
                
            } else if(c == "]") {
                // End span.
                currentSpan += "" + String(c)
                
//                if(currentSpan == "[xx]") {
//                    currentSpan = xx1
//                }
//                if(currentSpan == "[yy]") {
//                    currentSpan = yy2
//                }
                
                spans.append(TemplateSpan(text: currentSpan, isVar: isVar))
                
                // Begin new span.
                isVar = false
                currentSpan = ""
            } else if(isVar) {
                currentSpan += "" + String(c)
            } else {
                currentSpan += "" + String(c)
            }
        }
        
        spans.append(TemplateSpan(text: currentSpan, isVar: isVar))
        
        return spans
    }
    
    var body: some View {
        HStack(spacing: 0) {
            renderTemplateTake().reduce(
                Text(""),
                {
                    $0 + Text($1.text)
                        .foregroundColor($1.isVar
                                         ? Theme().brandColor
                                         : .black)
                }
            )

//            ForEach(renderTemplateTake()) { span in
//                Text(span.text)
//                    .foregroundColor(span.isVar
//                                     ? Theme().brandColor
//                                     : .black)
//                    .lineLimit(1)
//            }
//            .lineLimit(4)
//            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct RemixTakePopover: View {
    @StateObject private var store = TakeStore()
    
    @State var takeTemplate: Take
    @State var close: () -> ()
    
//    @State private var isShowingPopover = false
    @State private var mintButtonDisabled = false
    @State private var xx = ""
    @State private var yy = ""
    @State private var zz = ""
    
    var body: some View {
        VStack {
            Text("Remix take")
                .font(.title2)
                .padding(.bottom)
            
            TakeTemplateText(
                take: takeTemplate.description!,
                xx: $xx,
                yy: $yy,
                zz: $zz
            )
            
            TextField(
                "",
                text: $xx,
                axis: .vertical
            )
            .lineLimit(2, reservesSpace: true)
            .textFieldStyle(.roundedBorder)
            .padding()
            .textInputAutocapitalization(.never)
            
            TextField(
                "",
                text: $yy,
                axis: .vertical
            )
            .lineLimit(2, reservesSpace: true)
            .textFieldStyle(.roundedBorder)
            .padding()
            .textInputAutocapitalization(.never)
            
            
            TextField(
                "",
                text: $zz,
                axis: .vertical
            )
            .lineLimit(2, reservesSpace: true)
            .textFieldStyle(.roundedBorder)
            .padding()
            .textInputAutocapitalization(.never)
            
            
            Button(action: {
                Task { await mintTake() }
            }, label: {
                Text("Remix")
                    .font(.callout)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 10,
                            style: .continuous
                        )
                        .fill(mintButtonDisabled
                              ? Theme().brandColor.opacity(0.4)
                              : Theme().brandColor)
                    )
                    .disabled(mintButtonDisabled)
            })
            .padding()
            
            Button(action: self.close) {
                // show label with system image
                Text("Cancel")
            }
        }
    }
    
    func mintTake() async {
        let takeText = takeTemplate
            .description!
            .replacingOccurrences(of: "[xx]", with: xx)
            .replacingOccurrences(of: "[yy]", with: yy)
            .replacingOccurrences(of: "[zz]", with: zz)
        print(takeText)
        
        self.mintButtonDisabled = true
        
        let myPrivateKey = try! EthereumPrivateKey(hexPrivateKey: KKK)
        //        Contracts().Take!.methods["mint"]("asdsadasd")
        let refs = [0,0,0];
        
        //        get nonce
        let web3 = Contracts().web3
        
        let nonce = try! await Contracts().web3.eth.getTransactionCount(address: myPrivateKey.address, block: .latest).async()
        let gasPrice = try! await web3.eth.gasPrice().async()
        
        let feeData = try! await Contracts().getFeeData()
        
        let maxFeePerGas = EthereumQuantity(quantity: feeData.standard.maxFee.gwei)
        let maxPriorityFeePerGas = EthereumQuantity(quantity: feeData.standard.maxPriorityFee.gwei)
        
        // TODO
        // $newTakeText.wrappedValue
        guard let tx = Contracts().Take!["mint"]?(takeText, refs).createTransaction(
            nonce: nonce,
            gasPrice: maxFeePerGas,
            maxFeePerGas: maxFeePerGas,
            maxPriorityFeePerGas: maxPriorityFeePerGas,
            gasLimit: 1500000,
            from: myPrivateKey.address,
            value: 0,
            accessList: [:],
            transactionType: .eip1559
        ) else {
            return
        }
        
        do {
            let polygonChainId = EthereumQuantity(integerLiteral: 137)
            let signedTx = try tx.sign(with: myPrivateKey, chainId: polygonChainId)
            //            web3.eth.estimateGas(call: <#T##EthereumCall#>, response: { gas
            //            })
            let txHash = try await Contracts().web3.eth.sendRawTransaction(transaction: signedTx).async()
            print(txHash)
            self.close()
//            Task {
//                await loadTakes()
//            }
            
        } catch {
            print(error)
        }
        
        
    }
    
    
    func remixTake() {
        
    }
    
    
    private func openNewTakePopover() {
        self.mintButtonDisabled = false
//        self.isShowingPopover = true
    }
    
}

struct Previews_RemixTakePopover_Previews: PreviewProvider {
    static func getMockTake() -> Take {
        var take = Take()
        take.id = 1
        take.description = "[xx] is the name of my [yy] cover band"
        take.owner = "0x"
        take.refs = [0,0,0];
        return take
    }
    
    
    static var previews: some View {
        RemixTakePopover(
            takeTemplate: getMockTake(),
            close: {
            }
        )
    }
}

