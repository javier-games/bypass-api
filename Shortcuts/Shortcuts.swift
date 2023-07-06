//
//  Shortcurts.swift
//
//  Created by Javier García on 2023/05/08.
//

import AppIntents
import Requests

struct AppError: Error {
    var message: String
}

struct ServiceResponse: IntentResult {
    var value: Never?
    var response: String
    static var success: ServiceResponse { .init(response: "Success") }
}

struct SendRequest: AppIntent {
    
    static var title: LocalizedStringResource = "Send Request"
    static var description: IntentDescription? = "Makes a call to the selected service."
    static var parameterSummary: some ParameterSummary{
        Summary("Send \(\.$selectedService) request")
    }
    
    @Parameter(title: "Service")
    var selectedService: String
    
    var requestsData = RequestsData()
    
    @MainActor
    func perform() async throws -> some IntentResult  {
    
        guard let request = requestsData.requests.first(where: { $0.name == selectedService }) else {
            return .result(value: "\(selectedService) service not found.")
        }
        
        var response : String
        response = "Fail on send request."
        do {
            response = try await request.sendRequest()
            return .result(value: response)
        } catch {
            return .result(value: response)
        }
    }
}

struct SendRequestWithVariable: AppIntent {
    
    static var title: LocalizedStringResource = "Send Request with Variable"
    static var description: IntentDescription? = "Makes a call to the selected service with variables."
    static var parameterSummary: some ParameterSummary{
        Summary("Send \(\.$selectedService) request with \(\.$variableKey) as \(\.$variableValue)")
    }
    
    @Parameter(title: "Service")
    var selectedService: String
    
    @Parameter(title: "Variable Key")
    var variableKey: String
    
    @Parameter(title: "Variable Value")
    var variableValue: String
    
    var requestsData = RequestsData()
    
    @MainActor
    func perform() async throws -> some IntentResult  {
    
        guard let request = requestsData.requests.first(where: { $0.name == selectedService }) else {
            return .result(value: "\(selectedService) service not found.")
        }
        
        let requestWithParams = replaceWithVariables(from: request, variableKey: variableKey, variableValue: variableValue)
        
        var response : String
        response = "Fail on send request."
        do {
            response = try await requestWithParams.sendRequest()
            return .result(value: response)
        } catch {
            return .result(value: response)
        }
    }
}

struct SendRequestWithJsonBody: AppIntent {
    
    static var title: LocalizedStringResource = "Send Request with Json Body"
    static var description: IntentDescription? = "Makes a call to the selected service with the given JSONbody."
    static var parameterSummary: some ParameterSummary{
        Summary("Send \(\.$selectedService) request with \(\.$jsonBody)")
    }
    
    @Parameter(title: "Service")
    var selectedService: String
    
    @Parameter(title: "Body")
    var jsonBody: String
    
    var requestsData = RequestsData()
    
    @MainActor
    func perform() async throws -> some IntentResult  {
    
        guard let request = requestsData.requests.first(where: { $0.name == selectedService }) else {
            return .result(value: "\(selectedService) service not found.")
        }
        
        var newRequest = replaceJsonBody(from: request, body: jsonBody)
        
        var response : String
        response = "Fail on send request."
        do {
            response = try await newRequest.sendRequest()
            return .result(value: response)
        } catch {
            return .result(value: response)
        }
    }
}

struct SendEncryptedRequest: AppIntent {
    
    static var title: LocalizedStringResource = "Send Encrypted Request"
    static var description: IntentDescription? = "Sends a request with an ecrypted data. Usefull to share requests with tokens."
    
    static var parameterSummary: some ParameterSummary{
        Summary("Send request"){
            \.$encryptedService
        }
    }
    
    @Parameter(title: "Encrypted Service")
    var encryptedService: String
    
    func perform() async throws -> some IntentResult  {
     
        let request = Request.deserialize(from: encryptedService)
        var response : String
        response = "Fail on send request."
        do {
            response = try await request!.sendRequest()
            return .result(value: response)
        } catch {
            return .result(value: response)
        }
    }
}

struct SendEncryptedRequestWithVariable: AppIntent {
    
    static var title: LocalizedStringResource = "Send Encrypted Request with Variable"
    static var description: IntentDescription? = "Sends a request with an ecrypted data. Usefull to share requests with tokens."
    
    static var parameterSummary: some ParameterSummary{
        Summary("Send request with \(\.$variableKey) as \(\.$variableValue)"){
            \.$encryptedService
        }
    }
    
    @Parameter(title: "Encrypted Service")
    var encryptedService: String
    
    @Parameter(title: "Variable Key")
    var variableKey: String
    
    @Parameter(title: "Variable Value")
    var variableValue: String
    
    func perform() async throws -> some IntentResult  {
     
        let requestWithParams = replaceWithVariables(from: Request.deserialize(from: encryptedService)!, variableKey: variableKey, variableValue: variableValue)
        var response : String
        response = "Fail on send request."
        do {
            response = try await requestWithParams.sendRequest()
            return .result(value: response)
        } catch {
            return .result(value: response)
        }
    }
}

struct SendEncryptedRequestWithJsonBody: AppIntent {
    
    static var title: LocalizedStringResource = "Send Encrypted Request with the given JSON body."
    static var description: IntentDescription? = "Sends a request with an ecrypted data. Usefull to share requests with tokens."
    
    static var parameterSummary: some ParameterSummary{
        Summary("Send request with \(\.$jsonBody)"){
            \.$encryptedService
        }
    }
    
    @Parameter(title: "Encrypted Service")
    var encryptedService: String
    
    @Parameter(title: "Body")
    var jsonBody: String
    
    func perform() async throws -> some IntentResult  {
     
        let request = replaceJsonBody(from: Request.deserialize(from: encryptedService)!, body: jsonBody)
        var response : String
        response = "Fail on send request."
        do {
            response = try await request.sendRequest()
            return .result(value: response)
        } catch {
            return .result(value: response)
        }
    }
}

struct UnescapeJSON: AppIntent {
    
    static var title: LocalizedStringResource = "Unescape Value"
    static var description: IntentDescription? = "Unescapes the input text."
    
    static var parameterSummary: some ParameterSummary{
        Summary("Unescape \(\.$textToUnescape)")
    }
    
    @Parameter(title: "Text")
    var textToUnescape: String
    
    func perform() async throws -> some IntentResult  {
        return .result(value: jsonUnescape(json: textToUnescape))
    }
}

func replaceJsonBody(from request: Request, body: String) -> Request{
    var newRequest = request
    
    newRequest.bodyType = .JSON
    newRequest.rawBody = body
    
    return newRequest
}

func replaceWithVariables(from request: Request, variableKey: String, variableValue: String) -> Request {
    let stringToLook = "{{\(variableKey)}}"
    var newRequest = request
    
    if variableKey.isEmpty {
        return newRequest
    }
    
    newRequest.url = replaceUrlSubstring(input: request.url, substring: stringToLook, replacement: variableValue)
    
    if request.bodyType == .JSON{
        newRequest.rawBody = replaceJsonSubstring(input: request.rawBody, substring: stringToLook, replacement: variableValue)
    }
    
    return newRequest
}

func replaceUrlSubstring(input: String, substring: String, replacement: String) -> String {
    if input.contains(substring) {
        let replaced = input.replacingOccurrences(of: substring, with: urlEscape(string: replacement)!)
        return replaced
    } else {
        return input
    }
}

func urlEscape(string: String) -> String? {
    return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
}

func urlUnescape(string: String) -> String? {
    return string.removingPercentEncoding
}

func replaceJsonSubstring(input: String, substring: String, replacement: String) -> String {
    if input.contains(substring) {
        let replaced = input.replacingOccurrences(of: substring, with: jsonEscape(json: replacement))
        return replaced
    } else {
        return input
    }
}

func jsonEscape(json: String) -> String {
    var escapedJson = json.replacingOccurrences(of: "\\", with: "\\\\")
    escapedJson = escapedJson.replacingOccurrences(of: "\"", with: "\\\"")
    escapedJson = escapedJson.replacingOccurrences(of: "\n", with: "\\n")
    escapedJson = escapedJson.replacingOccurrences(of: "\r", with: "\\r")
    escapedJson = escapedJson.replacingOccurrences(of: "\t", with: "\\t")
    return escapedJson
}

func jsonUnescape(json: String) -> String {
    var unescapedJson = json.replacingOccurrences(of: "\\\"", with: "\"")
    unescapedJson = unescapedJson.replacingOccurrences(of: "\\n", with: "\n")
    unescapedJson = unescapedJson.replacingOccurrences(of: "\\r", with: "\r")
    unescapedJson = unescapedJson.replacingOccurrences(of: "\\t", with: "\t")
    unescapedJson = unescapedJson.replacingOccurrences(of: "\\\\", with: "\\")
    return unescapedJson
}
