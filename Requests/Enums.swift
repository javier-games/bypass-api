//
//  Enums.swift
//  Requests
//
//  Created by Javier García on 2023/05/24.
//

import Foundation

public enum HTTPMethod:String, CaseIterable, Identifiable, Codable {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    public var id: String { self.rawValue }
}

public enum BodyType:String, CaseIterable, Identifiable, Codable {
    case NONE = "No Body"
    case FORM_DATA = "Form Data"
    case JSON = "JSON"
    public var id: String { self.rawValue }
}
