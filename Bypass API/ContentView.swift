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
    @State private var httpMethod: HTTPMethod = HTTPMethod.POST
    
    @State private var urlParameters: [KeyValuePair] = []
    
    @State private var headers: [KeyValuePair] = []
    
    @State private var bodyType: BodyType = BodyType.FORM_DATA
    @State private var formData: [KeyValuePair] = []
    @State private var rawBody: String = ""
    
    
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
                
                
                Section{
                    ForEach(urlParameters.indices, id: \.self) {
                        index in HStack {
                            TextField("Key", text: $urlParameters[index].key)
                            TextField("Value", text: $urlParameters[index].value)
                        }
                    }
                    Button(action: {urlParameters.append(KeyValuePair())}) {
                        Label("Add", systemImage: "plus")
                    }
                } header: {
                    Text("URL Parameters")
                }
                
                Section{
                    ForEach(headers.indices, id: \.self) {
                        index in HStack {
                            TextField("Key", text: $headers[index].key)
                            TextField("Value", text: $headers[index].value)
                        }
                    }
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
                        }
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(RequestsData())
    }
}
