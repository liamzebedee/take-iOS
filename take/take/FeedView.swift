//
//  FeedView.swift
//  take
//
//  Created by Liam Edwards-Playne on 24/1/2023.
//

import Foundation
import SwiftUI
import Web3
import PromiseKit


struct MyButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(
                RoundedRectangle(
                    cornerRadius: 10,
                    style: .continuous
                )
                .fill(!isEnabled
                      ? Theme().brandColor.opacity(0.50)
                      : Theme().brandColor)
            )
            
    }
}


struct FeedView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject private var store = TakeStore()

    @State private var isShowingPopover = false
    @State private var isRemixPopoverOpen = false
    @State private var mintButtonDisabled = false
    @State private var newTakeText = ""
    @State var takes = [Take]()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        NavigationView {
            VStack {
//                WebView(url: URL(string: "http://localhost:3000")!)
//                WebView(url: URL(string: "https://take-xyz.vercel.app")!)

                List {
                    ForEach(self.takes) { take in
                        NavigationLink {
                            TakeView(take: take)
                        } label: {
                            Text(take.description!)
                        }
                        
                    }
                }
                .refreshable {
                    await loadTakes()
                }
                .toolbar {
                    ToolbarItem {
                        Button(action: openNewTakePopover) {
                            Text("New take ✍️")
//                                .foregroundColor(Color(hex: 0xff2a8d))
                                .foregroundColor(Theme().brandColor)
                        }
                    }
                }


            }
            .navigationBarTitle(
                Text("Feed")
            )

        }
        .popover(isPresented: $isShowingPopover) {
            VStack {
                Text("New take")
                    .font(.largeTitle)

                TextField(
                    "goats milk is better than breast milk change my mind",
                    text: $newTakeText,
                    axis: .vertical
                )
                    .lineLimit(6, reservesSpace: true)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .textInputAutocapitalization(.never)

                Button(action: {
                    Task { await mintTake() }
                }, label: {
                    Text("Mint")
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
//                .foregroundColor(Theme().brandColor)
//                .buttonStyle(.borderedProminent)
//
//                Button(action: mintTake) {
//                    Text("Mint")
//                        .padding()
//                    Spacer()
//                }
//                .foregroundColor(Theme().brandColor)
//                .buttonStyle(.borderedProminent)

                Button(action: closeNewTakePopover) {
                    // show label with system image
                    Text("Cancel")
                }
            }
        }
        .onAppear() {
            Task {
                await loadTakes()
            }
        }
    }
    
    func loadTakes() async {
        self.takes = try! await TakeStore().load()
    }
    
    func mintTake() async {
        self.mintButtonDisabled = true
        
        let myPrivateKey = try! EthereumPrivateKey(hexPrivateKey: KKK)
        //        Contracts().Take!.methods["mint"]("asdsadasd")
        let refs = [0,0,0];
        print($newTakeText)
        print(Contracts().Take!)
        
        //        get nonce
        let web3 = Contracts().web3
        
        let nonce = try! await Contracts().web3.eth.getTransactionCount(address: myPrivateKey.address, block: .latest).async()
        let gasPrice = try! await web3.eth.gasPrice().async()
        print(gasPrice)
    
        let feeData = try! await Contracts().getFeeData()
        
        print(feeData)
        print(String(describing: feeData.standard.maxFee))
//        print(try! BigUInt.init(stringLiteral: String(feeData.standard.maxFee)))
//        let maxFeePerGas = try! BigUInt.init(stringLiteral: String(feeData.standard.maxFee))
//        let maxPriorityFeePerGas = try! BigUInt.init(stringLiteral: String(feeData.standard.maxPriorityFee))
        let maxFeePerGas = EthereumQuantity(quantity: feeData.standard.maxFee.gwei)
        let maxPriorityFeePerGas = EthereumQuantity(quantity: feeData.standard.maxPriorityFee.gwei)
        
        
        
        //         get gas details
        guard let tx = Contracts().Take!["mint"]?($newTakeText.wrappedValue, refs).createTransaction(
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
            self.closeNewTakePopover()
            Task {
                await loadTakes()
            }
            
        } catch {
            print(error)
        }
        
        
    }
    
    private func openNewTakePopover() {
        self.mintButtonDisabled = false
        self.isShowingPopover = true
    }
    private func closeNewTakePopover() {
        self.isShowingPopover = false
    }
}

struct Previews_FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
