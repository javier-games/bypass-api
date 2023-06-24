//
//  RequestData.swift
//  Requests
//
//  Created by Francisco Javier García Gutiérrez on 2023/06/24.
//

import Foundation

public class RequestsData: ObservableObject {
    
    @Published public var requests: [Request] {
        didSet {
            saveRequests()
        }
    }
    
    public init() {
        let sharedUserDefaults = UserDefaults(suiteName: "group.games.javier.bypass-api")
        if let savedRequests = sharedUserDefaults?.data(forKey: "SavedRequests") {
            let decoder = JSONDecoder()
            if let loadedRequests = try? decoder.decode([Request].self, from: savedRequests) {
                self.requests = loadedRequests
            } else {
                self.requests = []
            }
        } else {
            self.requests = []
        }
    }
    
    func saveRequests() {
        let sharedUserDefaults = UserDefaults(suiteName: "group.games.javier.bypass-api")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(requests) {
            sharedUserDefaults?.set(encoded, forKey: "SavedRequests")
        }
    }
    
    func loadRequests() -> [Request] {
        let sharedUserDefaults = UserDefaults(suiteName: "group.games.javier.bypass-api")
        if let savedRequests = sharedUserDefaults?.data(forKey: "SavedRequests") {
            let decoder = JSONDecoder()
            if let loadedRequests = try? decoder.decode([Request].self, from: savedRequests) {
                return loadedRequests
            }
        }
        return []
    }
}
