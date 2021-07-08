//
//  ServerSelectionView.swift
//  ABJC
//
//  Created by Noah Kamara on 26.03.21.
//

import SwiftUI
import JellyfinAPI

class ServerSelectionViewModel : ViewModel {
    
    func setServer(url: URL, completion: @escaping () -> ()) {
        ServerEnvironment.current.create(with: url.absoluteString)
            .trackActivity(loading)
            .sink(receiveCompletion: { result in
                switch result {
                    case let .failure(error):
                        self.errorMessage = error.localizedDescription
                    default:
                        break
                }
            }, receiveValue: { _ in
                completion()
            })
            .store(in: &cancellables)
    }
    
}


struct ServerSelectionView: View {
    /// Servers Discovered By ServerLookup
    @State var servers: [ServerDiscovery.ServerLookupResponse] = []
    
    @State var searching = false
    
    private let locator: ServerDiscovery = ServerDiscovery()
    
    @State private var serverSelected = false
    
    @StateObject var viewModel = ServerSelectionViewModel()
        
    
    var body: some View {
        
        GeometryReader { geometry in
            HStack {
                VStack {
                    Image("logo_wide")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(0.75)
                }
                .frame(width: geometry.size.width * 1/2)
                
                VStack(alignment: .center) {
                    
                    VStack {
                        HStack(spacing: 5) {
                            Spacer()
                                .frame(width: 200)
                            Text("Server Selection")
                                .font(.title2).bold()
                            ProgressView()
                                .frame(width: 200)
                                .hidden(!searching)
                            
                        }
                        
                        Group {
                            ScrollView {
                                VStack(spacing: 10) {
                                    
                                    if self.servers.count > 0 {
                                        ForEach(self.servers, id:\.id) { server in
                                            Button {
                                                let url = URL(string: "http://\(server.host):\(server.port)")!
                                                viewModel.setServer(url: url) {
                                                    self.serverSelected = true
                                                }
                                            } label: {
                                                ServerCardView(server)
                                            }
                                            .background(
                                                NavigationLink(
                                                    destination: ServerUserListView(),
                                                    isActive: $serverSelected)
                                                {
                                                    EmptyView()
                                                }
                                                .buttonStyle(PlainButtonStyle()))
                                        }
                                        .padding()
                                    }
                                    
                                    NavigationLink(destination: ServerSelectionView.ManualView())
                                    {
                                        ServerCardView("Connect Manually",
                                                       "Enter server details manually")
                                    }
                                    .padding()
                                    
                                }
                            }
                            
                        }
                    }
                    .frame(maxHeight: .infinity)
                    
                    
                }
                .frame(width: geometry.size.width * 1/2)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: Color.backgroundGradient),
                startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all))
        .onAppear(perform: discover)
    }
    
    /// Discover Servers
    func discover() {
        searching = true
        
        // Timeout after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.searching = false
        }
        
        locator.locateServer { [self] (server) in
            if let server = server, !servers.contains(server) {
                servers.append(server)
            }
            searching = false
        }
    }
}

