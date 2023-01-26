//
//  Api.swift
//  take
//
//  Created by Liam Edwards-Playne on 24/1/2023.
//

import Foundation



class TakeStore: ObservableObject {
    @Published var takes: [Take] = []
    
    func load() async throws -> [Take] {
        //                let url = URL(string: "http://localhost:3000/api/v0/feed")!
        let url = URL(string: "https://take-xyz.vercel.app/api/v0/feed")!
        let urlSession = URLSession.shared
        
        do {
            let (data, _) = try await urlSession.data(from: url)
            
            let takes = try JSONDecoder().decode([Take].self, from: data)
            return takes
            
        } catch {
            // Error handling in case the data couldn't be loaded
            // For now, only display the error on the console
            debugPrint("Error loading \(url): \(String(describing: error))")
            throw error
        }
    }

    
    func load2(completion: @escaping (Result<[Take], Error>)->Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            Task {
//                let url = URL(string: "http://localhost:3000/api/v0/feed")!
                let url = URL(string: "https://take-xyz.vercel.app/api/v0/feed")!
                let urlSession = URLSession.shared
                
                do {
                    let (data, _) = try await urlSession.data(from: url)
                    
                    let takes = try JSONDecoder().decode([Take].self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(takes))
                    }
                } catch {
                    // Error handling in case the data couldn't be loaded
                    // For now, only display the error on the console
                    debugPrint("Error loading \(url): \(String(describing: error))")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}

