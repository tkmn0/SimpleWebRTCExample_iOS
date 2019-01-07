//
//  ViewController.swift
//  SimpleWebRTC
//
//  Created by tkmngch on 2019/01/05.
//  Copyright © 2019年 tkmngch. All rights reserved.
//

import UIKit
import Starscream

class ViewController: UIViewController, WebSocketDelegate {
    
    var webRTCClient: WebRTCClient!
    var socket: WebSocket!
    
    let ipAddress: String = "192.168.11.4"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webRTCClient = WebRTCClient()
        webRTCClient.setup()
        
        socket = WebSocket(url: URL(string: "ws://" + ipAddress + ":8080/")!)
        socket.delegate = self
        socket.connect()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let localVideoView = webRTCClient.localVideoView()
        localVideoView.center.y = self.view.center.y
        self.view.addSubview(localVideoView)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - WebSocket Delegate
extension ViewController {

    func websocketDidConnect(socket: WebSocketClient) {
        print("-- websocket did connect --")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("-- websocket did disconnect --")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}
