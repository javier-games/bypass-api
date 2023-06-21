//
//  Shortcuts.swift
//  Shortcuts
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
    
    static var title: LocalizedStringResource = "SendRequest"
    static var description: IntentDescription? = "Makes a call to the selected service."
    
    @Parameter(title: "Service")
    var selectedService: String
    
    var requestsData = RequestsData()
    
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

struct SendEncryptedRequest: AppIntent {
    
    static var title: LocalizedStringResource = "Send Encrypted Request"
    static var description: IntentDescription? = "Sends a request with an ecrypted data. Usefull to share requests with tokens."
    
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
