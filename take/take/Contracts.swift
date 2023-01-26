//
//  Contracts.swift
//  take
//
//  Created by Liam Edwards-Playne on 26/1/2023.
//

import Foundation
import Web3
import Web3PromiseKit
import Web3ContractABI


/*
 {
     "safeLow": {
         "maxPriorityFee": 37.181444553750005,
         "maxFee": 326.2556979087
     },
     "standard": {
         "maxPriorityFee": 49.575259405,
         "maxFee": 435.00759721159994
     },
     "fast": {
         "maxPriorityFee": 61.96907425625,
         "maxFee": 543.7594965144999
     },
     "estimatedBaseFee": 275.308812719,
     "blockTime": 6,
     "blockNumber": 23948420
 }

 */
struct PolygonFeeData: Codable {
    var safeLow: PolygonFeeDataEntry
    var standard: PolygonFeeDataEntry
    var fast: PolygonFeeDataEntry
    var estimatedBaseFee: Int
    
    enum CodingKeys: String, CodingKey {
        case safeLow
        case standard
        case fast
        case estimatedBaseFee
    }
}

struct PolygonFeeDataEntry: Codable {
    var maxPriorityFee: Int
    var maxFee: Int
    
    enum CodingKeys: String, CodingKey {
        case maxPriorityFee
        case maxFee
    }
}

class Contracts {
    @Published var Take: DynamicContract?
    @Published var web3: Web3
    
    init() {
        self.web3 = Web3(rpcURL: "https://polygon-rpc.com")
        
        firstly {
            web3.clientVersion()
        }.done { version in
            print(version)
        }.catch { error in
            print("Error")
        }
        
        self.Take = nil
        do {
            let takeV3Address = try EthereumAddress(hex: "0x8aBb83aBc180Ad1E96f75884CA24d45CC7560af2", eip55: true)
            let takeV3ABI: Data
            
            if let path = Bundle.main.path(forResource: "Data/Take", ofType: "json") {
                do {
                    takeV3ABI = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let Take = try web3.eth.Contract(json: takeV3ABI, abiKey: nil, address: takeV3Address)
                    print(Take.methods.count)
                    
                    self.Take = Take
                } catch {
                    // handle error
                    return
                }
            }
            
        } catch {
            debugPrint("Error making contract: \(String(describing: error))")
        }
        
    }
    
    func getFeeData() async throws -> PolygonFeeData {
        let url = URL(string: "https://take-xyz.vercel.app/api/v0/polygon/fee")!
//        let url = URL(string: "http://localhost:3000/api/v0/polygon/fee")!
        let urlSession = URLSession.shared
        
        do {
            let (data, _) = try await urlSession.data(from: url)
            
            let data2 = try JSONDecoder().decode(PolygonFeeData.self, from: data)
            return data2
//            DispatchQueue.main.async {
//                completion(.success(data2))
//            }
        } catch {
            // Error handling in case the data couldn't be loaded
            // For now, only display the error on the console
            debugPrint("Error loading \(url): \(String(describing: error))")
            throw error
//            DispatchQueue.main.async {
//                completion(.failure(error))
//            }
        }
        
//        DispatchQueue.global(qos: .background).async {
//            Task {
//
//            }
//        }

    }
    
    // Specify the standard library Result type
    // This is the type that will be returned by the load function
    // @escaping (Result<[Take], Error>)->Void
    
}
