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
    var wsStatusLabel: UILabel!
    let wsStatusMessageBase = "websocket: "
    var webRTCStatusLabel: UILabel!
    let webRTCStatusMesasgeBase = "WebRTC: "
    
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
        
        let remoteVideoViewContainter = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width(), height: ScreenSizeUtil.height()*0.7))
        remoteVideoViewContainter.backgroundColor = .gray
        self.view.addSubview(remoteVideoViewContainter)
        
        let localVideoView = webRTCClient.localVideoView()
        localVideoView.center.y = self.view.center.y
        self.view.addSubview(localVideoView)
        
        wsStatusLabel = UILabel(frame: CGRect(x: 0, y: remoteVideoViewContainter.bottom, width: ScreenSizeUtil.width(), height: 30))
        wsStatusLabel.textAlignment = .center
        self.view.addSubview(wsStatusLabel)
        webRTCStatusLabel = UILabel(frame: CGRect(x: 0, y: wsStatusLabel.bottom, width: ScreenSizeUtil.width(), height: 30))
        webRTCStatusLabel.textAlignment = .center
        self.view.addSubview(webRTCStatusLabel)
        webRTCStatusLabel.text = webRTCStatusMesasgeBase + "initialized"
        
        let buttonWidth = ScreenSizeUtil.width()*0.4
        let buttonHeight: CGFloat = 60
        let buttonRadius: CGFloat = 30
        let callButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight))
        callButton.backgroundColor = .blue
        callButton.layer.cornerRadius = buttonRadius
        callButton.layer.masksToBounds = true
        callButton.center.x = ScreenSizeUtil.width()/4
        callButton.center.y = webRTCStatusLabel.bottom + (ScreenSizeUtil.height() - webRTCStatusLabel.bottom)/2
        callButton.setTitle("Call", for: .normal)
        callButton.titleLabel?.font = UIFont.systemFont(ofSize: 23)
        self.view.addSubview(callButton)
        
        let hungupButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight))
        hungupButton.backgroundColor = .red
        hungupButton.layer.cornerRadius = buttonRadius
        hungupButton.layer.masksToBounds = true
        hungupButton.center.x = ScreenSizeUtil.width()/4 * 3
        hungupButton.center.y = callButton.center.y
        hungupButton.setTitle("Hung up" , for: .normal)
        hungupButton.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        self.view.addSubview(hungupButton)
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
        wsStatusLabel.text = wsStatusMessageBase + "connected"
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("-- websocket did disconnect --")
        wsStatusLabel.text = wsStatusMessageBase + "disconnected"
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}
