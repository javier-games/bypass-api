//
//  ContentView.swift
//  Bypass API
//
//  Created by Javier García on 2023/05/08.
//

import SwiftUI
import Requests

struct ContentView: View {
    
    @EnvironmentObject var requestsData: RequestsData
    @State var isPresenting = false
    @State var selectedRequest: Request? = nil
    
    var body: some View {
        NavigationView {
            List {
                
                Section{
                    ForEach(requestsData.requests, id: \.id) {
                        request in Text(request.name).onTapGesture {
                            isPresenting = true
                            selectedRequest = request
                        }
                    }.onDelete(
                        perform: delete
                    )
                } header: {
                    if !requestsData.requests.isEmpty {
                        Text("Form Requests")
                    }
                } footer: {
                    if requestsData.requests.isEmpty {
                        Text("The requests you create will be displayed here.")
                    }
                }
                
                Button {
                    isPresenting = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
                
                Button(action: {
                    if let clipboardString = UIPasteboard.general.string,
                       let request = Request.deserialize(from: clipboardString) {
                        requestsData.requests.append(request)
                    }
                }) {
                    Label("Paste from Clipboard", systemImage: "doc.on.clipboard")
                }
                
            }.navigationBarTitle(
                "Requests",
                displayMode: .automatic
            ).sheet(
                isPresented: $isPresenting,
                onDismiss: { print("Dismissed") },
                content: { RequestView(requestsData: requestsData, selectedRequest: $selectedRequest) }
            )
        }
    }
    
    func delete(at offsets: IndexSet) {
        requestsData.requests.remove(atOffsets: offsets)
    }
}


struct RequestView: View {
    
    @ObservedObject var requestsData: RequestsData
    @Binding var selectedRequest: Request?
    
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var url: String = ""
    @State private var httpMethod: HTTPMethod = HTTPMethod.GET
    
    @State private var urlParameters: [KeyValuePair] = []
    
    @State private var headers: [KeyValuePair] = []
    
    @State private var bodyType: BodyType = BodyType.NONE
    @State private var formData: [KeyValuePair] = []
    @State private var rawBody: String = ""
    
    @State private var isAlertVisible: Bool = false
    @State private var resultMessage: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                
                Section{
                    TextField("Name", text: $name)
                    TextField("URL", text: $url)
                    Picker("Method", selection: $httpMethod) {
                        ForEach(HTTPMethod.allCases) {
                            method in Text(method.rawValue).tag(method)
                        }
                    }
                }
                
//                Section{
//                    ForEach(urlParameters.indices, id: \.self) {
//                        index in HStack {
//                            TextField("Key", text: $urlParameters[index].key)
//                            TextField("Value", text: $urlParameters[index].value)
//                        }
//                    }
//                    Button(action: {urlParameters.append(KeyValuePair())}) {
//                        Label("Add", systemImage: "plus")
//                    }
//                } header: {
//                    Text("URL Parameters")
//                }
                
                Section{
                    ForEach(headers.indices, id: \.self) {
                        index in HStack {
                            TextField("Key", text: $headers[index].key)
                            TextField("Value", text: $headers[index].value)
                        }
                    }.onDelete(perform: deleteHeader)
                    Button(action: {headers.append(KeyValuePair())}) {
                        Label("Add", systemImage: "plus")
                    }
                } header: {
                    Text("Headers")
                }
                
                
                Section{
                    Picker("Body Type", selection: $bodyType) {
                        ForEach(BodyType.allCases) {
                            method in Text(method.rawValue).tag(method)
                        }
                    }

                    if bodyType == BodyType.FORM_DATA{
                        ForEach(formData.indices, id: \.self) {
                            index in HStack {
                                TextField("Key", text: $formData[index].key)
                                TextField("Value", text: $formData[index].value)
                            }
                        }.onDelete(perform: deleteFormData)
                        Button(action: {formData.append(KeyValuePair())}) {
                            Label("Add", systemImage: "plus")
                        }
                    }

                    else if bodyType == BodyType.JSON{
                        TextEditor(text: $rawBody)
                            .frame(height: 200)
                            .border(Color.gray, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)

                    }

                } header: {
                    Text("Body")
                }
                
                Section {
                    
                    Button(action: {
                        if !name.isEmpty && !url.isEmpty {
                            sendRequest {
                                result in
                                self.resultMessage = result
                                self.isAlertVisible = true
                            }
                        }
                    }){
                        Text("Send Request")
                    }.disabled(name.isEmpty || url.isEmpty)
                    
                    Button(action: {
                        if !name.isEmpty && !url.isEmpty {
                            copyRequest()
                        }
                    }){
                        Text("Copy Request")
                    }.disabled(name.isEmpty || url.isEmpty)
                    
                }.alert(isPresented: $isAlertVisible) {
                    Alert(title: Text("Request Result"), message: Text(resultMessage), dismissButton: .default(Text("OK")))
                }
                
            }
            
            .navigationBarTitle("New Request", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {dismiss()},
                trailing: Button("Save") {
                    if name.isEmpty || url.isEmpty{
                        dismiss()
                        return
                    }
                    
                    let newRequest = Request(
                        id: selectedRequest?.id ?? UUID(),
                        name: name,
                        url: url,
                        httpMethod: httpMethod,
                        urlParams: urlParameters,
                        headers: headers,
                        bodyType: bodyType,
                        formData: formData,
                        rawBody: rawBody
                    )
                    
                    if let selectedRequest = selectedRequest,
                        let index = requestsData.requests.firstIndex(where: { $0.id == selectedRequest.id }) {
                        requestsData.requests[index] = newRequest
                    } else {
                        requestsData.requests.append(newRequest)
                    }
                    
                    dismiss()
                    
                }
            )
        }.onAppear {
            if let request = selectedRequest {
                name = request.name
                url = request.url
                httpMethod = request.httpMethod
                urlParameters = request.urlParams
                headers = request.headers
                bodyType = request.bodyType
                formData = request.formData
                rawBody = request.rawBody
            }
        }
    }
    
    func deleteHeader(at offsets: IndexSet) {
        headers.remove(atOffsets: offsets)
    }
    
    func deleteFormData(at offsets: IndexSet) {
        formData.remove(atOffsets: offsets)
    }
    
    func sendRequest(completion: @escaping (String) -> Void) {
        let newRequest = Request(
            id: selectedRequest?.id ?? UUID(),
            name: name,
            url: url,
            httpMethod: httpMethod,
            urlParams: urlParameters,
            headers: headers,
            bodyType: bodyType,
            formData: formData,
            rawBody: rawBody
        )

        // Send the request asynchronously
        Task {
            do {
                let result = try await newRequest.sendRequest()
                DispatchQueue.main.async {
                    completion(result)
                }
            } catch {
                DispatchQueue.main.async {
                    completion("Request failed with error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func copyRequest(){
        let newRequest = Request(
            id: selectedRequest?.id ?? UUID(),
            name: name,
            url: url,
            httpMethod: httpMethod,
            urlParams: urlParameters,
            headers: headers,
            bodyType: bodyType,
            formData: formData,
            rawBody: rawBody
        )

        if let requestString = newRequest.serialize() {
            UIPasteboard.general.string = requestString
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(RequestsData())
    }
}
