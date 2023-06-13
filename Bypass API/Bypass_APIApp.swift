//
//  Bypass_APIApp.swift
//  Bypass API
//
//  Created by Javier García on 2023/05/08.
//

import SwiftUI
import Requests

@main
struct Bypass_APIApp: App {
    @StateObject var requestsData = RequestsData()
        
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(requestsData)
        }
    }
}
