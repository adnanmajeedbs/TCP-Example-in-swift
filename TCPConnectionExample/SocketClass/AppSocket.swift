//
//  AppSocket.swift
//  TCPConnectionExample
//
//  Created by Adnan Majeed on 31/05/2021.
//

import Foundation
import Network
protocol  AppSocketDelegate{
    func didConnected(Connected:Bool)
    func didsent(Connected:Bool)
    func RecievedData(data:Data)
}



@available(macOS 10.14, *)
class ServerConnection {
    //The TCP maximum package size is 64K 65536
  
    let MTU = 65536
    var delegate:AppSocketDelegate?
    private static var nextID: Int = 0
    var  connection: NWConnection!
    var id: Int!

init(nwConnection: NWConnection) {
    connection = nwConnection
    id = ServerConnection.nextID
    ServerConnection.nextID += 1
    }

    var didStopCallback: ((Error?) -> Void)? = nil

    func start(nwConnection: NWConnection) {
      
        print("connection \(id) will start")
        connection.stateUpdateHandler = self.stateDidChange(to:)
        setupReceive()
        connection.start(queue: .main)
    }

    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            self.delegate?.didConnected(Connected: false)
            connectionDidFail(error: error)
        case .ready:
            self.delegate?.didConnected(Connected: true)
            print("connection \(id) ready")
        case .failed(let error):
            self.delegate?.didConnected(Connected: false)
            connectionDidFail(error: error)
        default:
            break
        }
    }

    private func setupReceive() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: MTU) { (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
                self.delegate?.RecievedData(data: data)
                let message = String(data: data, encoding: .utf8)
                
                print("connection \(self.id) did receive, data: \(data as NSData) string: \(message ?? "-")")
                self.send(data: data)
            }
            if isComplete {
                self.connectionDidEnd()
            } else if let error = error {
                self.connectionDidFail(error: error)
            } else {
                self.setupReceive()
            }
        }
    }


    func send(data: Data) {
        self.connection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionDidFail(error: error)
                self.delegate?.didsent(Connected: false)
                return
            }
            self.delegate?.didsent(Connected: true)
            print("connection \(self.id) did send, data: \(data as NSData)")
        }))
    }

    func stop() {
        print("connection \(id) will stop")
    }



    private func connectionDidFail(error: Error) {
        print("connection \(id) did fail, error: \(error)")
        stop(error: error)
    }

    private func connectionDidEnd() {
        print("connection \(id) did end")
        stop(error: nil)
    }

    private func stop(error: Error?) {
        connection.stateUpdateHandler = nil
        connection.cancel()
        if let didStopCallback = didStopCallback {
            self.didStopCallback = nil
            didStopCallback(error)
        }
    }
}

@available(macOS 10.14, *)
class Server {
    var port: NWEndpoint.Port!
    var listener: NWListener!
    static var shared:Server = Server()
    var delegate:AppSocketDelegate?{
        didSet{
            for connect in self.connectionsByID {
                
                connect.value.delegate = self.delegate
            }
        }
    }
    private var connectionsByID: [Int: ServerConnection] = [:]
  
   private init() {
         }

    func start(port:UInt16 = UInt16(8080)) throws {
        self.port = NWEndpoint.Port(rawValue: port)!
        listener = try! NWListener(using: .tcp, on: self.port)
  
        print("Server starting...")
        listener.stateUpdateHandler = self.stateDidChange(to:)
        listener.newConnectionHandler = self.didAccept(nwConnection:)
        listener.start(queue: .main)
    }

    func stateDidChange(to newState: NWListener.State) {
        switch newState {
        case .waiting(let err):
            print(err)
//            delegate?.didConnected(Connected: true)
        case .ready:
//            delegate?.didConnected(Connected: true)
          print("Server ready.")
        case .failed(let error):
            delegate?.didConnected(Connected: false)
            print("Server failure, error: \(error.localizedDescription)")
         
        default:
            break
        }
    }

    private func didAccept(nwConnection: NWConnection) {
        let connection = ServerConnection(nwConnection: nwConnection)
        self.connectionsByID[connection.id] = connection
        connection.didStopCallback = { _ in
            self.connectionDidStop(connection)
        }
        connection.start(nwConnection: nwConnection)
        
        connection.delegate = self.delegate
        
        self.delegate?.didConnected(Connected: true)
        
       print("server did open connection \(connection.id)")
    }
    
    func  sendData(data:Data){
        for connect in self.connectionsByID {
            connect.value.send(data: data)
   
        }}

    private func connectionDidStop(_ connection: ServerConnection) {
        self.connectionsByID.removeValue(forKey: connection.id)
        print("server did close connection \(connection.id)")
    }

    private func stop() {
        self.listener.stateUpdateHandler = nil
        self.listener.newConnectionHandler = nil
        self.listener.cancel()
        for connection in self.connectionsByID.values {
            connection.didStopCallback = nil
            connection.stop()
        }
        self.connectionsByID.removeAll()
    }
}
@available(macOS 10.14, *)
class Client {
    var connection: ClientConnection!
    var host: NWEndpoint.Host!
    var port: NWEndpoint.Port!
    var ConnectionDelegate:AppSocketDelegate?{
        didSet{
            connection?.delegate = ConnectionDelegate
        }
    }
    static var shared:Client = Client()
   private init() {
       
    }

    func start(host: String = "127.0.0.1", port: UInt16 = UInt16(8080) ,ConnectionDelegate:AppSocketDelegate?) {
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(rawValue: port)!
        let nwConnection = NWConnection(host: self.host, port: self.port, using: .tcp)
        connection = ClientConnection(nwConnection: nwConnection,ConnectionDelegate: ConnectionDelegate)
        print("Client started \(host) \(port)")
        connection.didStopCallback = didStopCallback(error:)
        connection.start()
    }

    func stop() {
        connection.stop()
    }

    func send(data: Data) {
        connection.send(data: data)
    }

    func didStopCallback(error: Error?) {
        if error == nil {
         
        } else {
            print(error)
        }
    }
}

@available(macOS 10.14, *)
class ClientConnection {
    var delegate:AppSocketDelegate?
    let  nwConnection: NWConnection
    let queue = DispatchQueue(label: "Client connection Q")

    init(nwConnection: NWConnection,ConnectionDelegate:AppSocketDelegate?) {
        self.nwConnection = nwConnection
        delegate = ConnectionDelegate
    }

    var didStopCallback: ((Error?) -> Void)? = nil
    var didConnectedCallback: (() -> Void)? = nil

    func start() {
        print("connection will start")
        nwConnection.stateUpdateHandler = stateDidChange(to:)
        setupReceive()
        nwConnection.start(queue: queue)
    }

    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            connectionDidFail(error: error)
        case .ready:
            didConnectedCallback?()
            delegate?.didConnected(Connected: true)
            print("Client connection ready")
        case .failed(let error):
            delegate?.didConnected(Connected: false)
            connectionDidFail(error: error)
        default:
            break
        }
    }

    private func setupReceive() {
        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
                self.delegate?.RecievedData(data: data)
                let message = String(data: data, encoding: .utf8)
                print("connection did receive, data: \(data as NSData) string: \(message ?? "-" )")
            }
            if isComplete {
                self.connectionDidEnd()
            } else if let error = error {
                self.connectionDidFail(error: error)
            } else {
                self.setupReceive()
            }
        }
    }

    func send(data: Data) {
        nwConnection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionDidFail(error: error)
                self.delegate?.didsent(Connected: false)
                return
            }
            self.delegate?.didsent(Connected: true)
                print("connection did send, data: \(data as NSData)")
        }))
    }

    func stop() {
        print("connection will stop")
        stop(error: nil)
    }

    private func connectionDidFail(error: Error) {
        print("connection did fail, error: \(error)")
        self.stop(error: error)
    }

    private func connectionDidEnd() {
        print("connection did end")
        self.stop(error: nil)
    }

    private func stop(error: Error?) {
        self.nwConnection.stateUpdateHandler = nil
        self.nwConnection.cancel()
        if let didStopCallback = self.didStopCallback {
            self.didStopCallback = nil
            didStopCallback(error)
        }
    }
}
