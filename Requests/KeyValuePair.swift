//
//  KeyValuePair.swift
//  Requests
//
//  Created by Francisco Javier García Gutiérrez on 2023/06/24.
//

import Foundation

public struct KeyValuePair: Codable {
    public var key: String
    public var value: String
    
    public init() {
        self.key = ""
        self.value = ""
    }
    
    public init(key: String, value: String){
        self.key = key
        self.value = value
    }
}
