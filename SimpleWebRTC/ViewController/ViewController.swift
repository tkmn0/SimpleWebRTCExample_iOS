//
//  ViewController.swift
//  SimpleWebRTC
//
//  Created by tkmngch on 2019/01/05.
//  Copyright © 2019年 tkmngch. All rights reserved.
//

import UIKit
import Starscream
import WebRTC

class ViewController: UIViewController, WebSocketDelegate, WebRTCClientDelegate {
    
    var webRTCClient: WebRTCClient!
    var socket: WebSocket!
    
    let ipAddress: String = "192.168.11.4"
    var wsStatusLabel: UILabel!
    let wsStatusMessageBase = "WebSocket: "
    var webRTCStatusLabel: UILabel!
    let webRTCStatusMesasgeBase = "WebRTC: "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webRTCClient = WebRTCClient()
        webRTCClient.delegate = self
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
        
        let remoteVideoView = webRTCClient.remoteVideoView()
        webRTCClient.setupRemoteViewFrame(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width()*0.7, height: ScreenSizeUtil.height()*0.7))
        remoteVideoView.center = remoteVideoViewContainter.center
        remoteVideoViewContainter.addSubview(remoteVideoView)
        
        let localVideoView = webRTCClient.localVideoView()
        webRTCClient.setupLocalViewFrame(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width()/3, height: ScreenSizeUtil.height()/3))
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
        callButton.addTarget(self, action: #selector(self.callButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(callButton)
        
        let hangupButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight))
        hangupButton.backgroundColor = .red
        hangupButton.layer.cornerRadius = buttonRadius
        hangupButton.layer.masksToBounds = true
        hangupButton.center.x = ScreenSizeUtil.width()/4 * 3
        hangupButton.center.y = callButton.center.y
        hangupButton.setTitle("hang up" , for: .normal)
        hangupButton.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        hangupButton.addTarget(self, action: #selector(self.hangupButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(hangupButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Events
    @objc func callButtonTapped(_ sender: UIButton){
        webRTCClient.connect(onSuccess: { (offerSDP: RTCSessionDescription) -> Void in
            self.sendSDP(sessionDescription: offerSDP)
        })
    }
    
    @objc func hangupButtonTapped(_ sender: UIButton){
        webRTCClient.disconnect()
    }
    
    // MARK: - WebRTC Signaling
    private func sendSDP(sessionDescription: RTCSessionDescription){
        var type = ""
        if sessionDescription.type == .offer {
            type = "offer"
        }else if sessionDescription.type == .answer {
            type = "answer"
        }
        
        let sdp = SDP.init(sdp: sessionDescription.sdp)
        let signalingMessage = SignalingMessage.init(type: type, sessionDescription: sdp, candidate: nil)
        do {
            let data = try JSONEncoder().encode(signalingMessage)
            let message = String(data: data, encoding: String.Encoding.utf8)!
            
            if self.socket.isConnected {
                self.socket.write(string: message)
            }
        }catch{
            print(error)
        }
    }
    
    private func sendCandidate(iceCandidate: RTCIceCandidate){
        let candidate = Candidate.init(sdp: iceCandidate.sdp, sdpMLineIndex: iceCandidate.sdpMLineIndex, sdpMid: iceCandidate.sdpMid!)
        let signalingMessage = SignalingMessage.init(type: "candidate", sessionDescription: nil, candidate: candidate)
        do {
            let data = try JSONEncoder().encode(signalingMessage)
            let message = String(data: data, encoding: String.Encoding.utf8)!
            
            if self.socket.isConnected {
                self.socket.write(string: message)
            }
        }catch{
            print(error)
        }
    }
    
}

// MARK: - WebSocket Delegate
extension ViewController {
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("-- websocket did connect --")
        wsStatusLabel.text = wsStatusMessageBase + "connected"
        wsStatusLabel.textColor = .green
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("-- websocket did disconnect --")
        wsStatusLabel.text = wsStatusMessageBase + "disconnected"
        wsStatusLabel.textColor = .red
        
        if !self.webRTCClient.isConnected {
            // MARK: Retry to connect websocket
            
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
        do{
            let signalingMessage = try JSONDecoder().decode(SignalingMessage.self, from: text.data(using: .utf8)!)
            
            if signalingMessage.type == "offer" {
                webRTCClient.receiveOffer(offerSDP: RTCSessionDescription(type: .offer, sdp: (signalingMessage.sessionDescription?.sdp)!), onCreateAnswer: {(answerSDP: RTCSessionDescription) -> Void in
                    self.sendSDP(sessionDescription: answerSDP)
                })
            }else if signalingMessage.type == "answer" {
                webRTCClient.receiveAnswer(answerSDP: RTCSessionDescription(type: .answer, sdp: (signalingMessage.sessionDescription?.sdp)!))
            }else if signalingMessage.type == "candidate" {
                let candidate = signalingMessage.candidate!
                webRTCClient.recieveCandidate(candidate: RTCIceCandidate(sdp: candidate.sdp, sdpMLineIndex: candidate.sdpMLineIndex, sdpMid: candidate.sdpMid))
            }
        }catch{
            print(error)
        }
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) { }
}

// MARK: - WebRTCClient Delegate
extension ViewController {
    func didGenerateCandidate(iceCandidate: RTCIceCandidate) {
        self.sendCandidate(iceCandidate: iceCandidate)
    }
    
    func didIceConnectionStateChanged(iceConnectionState: RTCIceConnectionState) {
        var state = ""
        
        switch iceConnectionState {
        case .checking:
            state = "checking..."
        case .closed:
            state = "closed"
        case .completed:
            state = "completed"
        case .connected:
            state = "connected"
        case .count:
            state = "count..."
        case .disconnected:
            state = "disconnected"
        case .failed:
            state = "failed"
        case .new:
            state = "new..."
        }
        self.webRTCStatusLabel.text = self.webRTCStatusMesasgeBase + state
    }
    
    func webRTCDidConnected() {
        self.webRTCStatusLabel.textColor = .green
        // MARK: Disconnect websocket
        
    }
    
    func webRTCDidDisconnected() {
        self.webRTCStatusLabel.textColor = .red
        // MRAK: Try to connect websocket
        
    }
    
}
