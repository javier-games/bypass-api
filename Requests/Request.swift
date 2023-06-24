//
//  Request.swift
//  Requests
//
//  Created by Francisco Javier García Gutiérrez on 2023/06/24.
//

import Foundation

public struct Request: Codable {
    public let id: UUID
    public var name: String
    public var url: String
    public var httpMethod: HTTPMethod
    public var urlParams: [KeyValuePair]
    public var headers: [KeyValuePair]
    public var bodyType: BodyType
    public var formData: [KeyValuePair]
    public var rawBody: String
    
    public init(
        id: UUID = UUID(),
        name: String,
        url: String,
        httpMethod: HTTPMethod,
        urlParams: [KeyValuePair] = [],
        headers: [KeyValuePair] = [],
        bodyType: BodyType = BodyType.FORM_DATA,
        formData: [KeyValuePair] = [],
        rawBody: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.url = url
        self.httpMethod = httpMethod
        self.urlParams = urlParams
        self.headers = headers
        self.bodyType = bodyType
        self.formData = formData
        self.rawBody = rawBody
    }
    
    public func sendRequest() async throws -> String {
        return try await withCheckedThrowingContinuation {
            continuation in
            
            // Prepare the URL
            guard let url = URL(string: self.url) else {
                continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return
            }
            
            // Prepare the request
            var request = URLRequest(url: url)
            request.httpMethod = self.httpMethod.rawValue
            
            // Add headers to the request
            for keyValuePair in self.headers {
                request.addValue(keyValuePair.value, forHTTPHeaderField: keyValuePair.key)
            }
            
            // Add body
            switch self.bodyType {
                
            case .FORM_DATA:
                
                // Create the boundary and set the content type
                let boundary = "Boundary-\(UUID().uuidString)"
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
                // Prepare the body
                var body = ""
                for keyValuePair in self.formData {
                    body += "--\(boundary)\r\n"
                    body += "Content-Disposition: form-data; name=\"\(keyValuePair.key)\"\r\n\r\n"
                    body += "\(keyValuePair.value)\r\n"
                }
                body += "--\(boundary)--\r\n"
                
                // Set the request body
                request.httpBody = body.data(using: .utf8)
                
            case .JSON:
                
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                if let jsonData = self.rawBody.data(using: .utf8) {
                    request.httpBody = jsonData
                } else {
                    print("Failed to convert JSON string to data.")
                }
                
            case .NONE:
                print("No body data required.")
            }
            
            // Create a URLSession and send the request
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    if let str = String(data: data, encoding: .utf8) {
                        continuation.resume(returning: str)
                    } else {
                        continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data could not be converted to string"]))
                    }
                } else {
                    continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                }
            }
            
            // Start the data task
            task.resume()
            
        }
    }
    
    public func serialize() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(self)
            
            // Generate encryption key
            guard let keyData = Request.getEncryptionKey() else {
                print("Failed to generate encryption key.")
                return nil
            }
            
            // Encrypt
            guard let encryptedData = AesEncryption.aesEncrypt(data: data, keyData: keyData) else {
                print("Failed to encrypt data.")
                return nil
            }
            
            return encryptedData.base64EncodedString()
        } catch {
            print("Failed to encode or encrypt Request: \(error)")
            return nil
        }
    }
    
    public static func deserialize(from string: String) -> Request? {
        guard let keyData = Request.getEncryptionKey() else {
            print("Failed to generate encryption key.")
            return nil
        }
        
        guard let encryptedData = Data(base64Encoded: string),
              let decryptedData = AesEncryption.aesDecrypt(data: encryptedData, keyData: keyData) else {
            print("Failed to decrypt data.")
            return nil
        }
        
        let decoder = JSONDecoder()
        if let request = try? decoder.decode(Request.self, from: decryptedData) {
            return request
        } else {
            return nil
        }
    }
    
    private static func getEncryptionKey() -> Data?{
        
        // Generate encryption key
        guard let keyData = AesEncryption.generateEncryptionKey(password: EncryptionData.password, salt: EncryptionData.salt) else {
            print("Failed to generate encryption key.")
            return nil
        }
        
        return keyData
    }
}
