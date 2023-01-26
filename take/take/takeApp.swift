//
//  takeApp.swift
//  take
//
//  Created by Liam Edwards-Playne on 21/1/2023.
//

import SwiftUI

@main
struct takeApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        persistenceController.container.viewContext.automaticallyMergesChangesFromParent = true
        persistenceController.container.viewContext.refreshAllObjects()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
