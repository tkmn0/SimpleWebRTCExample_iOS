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
import UIKit

public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}

class ViewController: UIViewController, WebSocketDelegate, WebRTCClientDelegate {
    
    var webRTCClient: WebRTCClient!
    var socket: WebSocket!
    var tryToConnectWebSocket: Timer!
    
    // Constants
    let ipAddress: String = "192.168.11.4"
    let wsStatusMessageBase = "WebSocket: "
    let webRTCStatusMesasgeBase = "WebRTC: "
    enum messageType {
        case greet
        case introduce
        
        func text() -> String {
            switch self {
            case .greet:
                return "Hello!"
            case .introduce:
                return "I'm " + UIDevice.modelName
            }
        }
        
    }
    // UI
    var wsStatusLabel: UILabel!
    var webRTCStatusLabel: UILabel!
    var webRTCMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webRTCClient = WebRTCClient()
        webRTCClient.delegate = self
        webRTCClient.setup(videoTrack: true, audioTrack: true, dataChannel: true)
        
        socket = WebSocket(url: URL(string: "ws://" + ipAddress + ":8080/")!)
        socket.delegate = self
        
        tryToConnectWebSocket = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            if self.webRTCClient.isConnected || self.socket.isConnected {
                return
            }
            
            self.socket.connect()
        })
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
        
        let likeButton = UIButton(frame: CGRect(x: remoteVideoViewContainter.right - 50, y: remoteVideoViewContainter.bottom - 50, width: 40, height: 40))
        likeButton.backgroundColor = UIColor.purple
        likeButton.addTarget(self, action: #selector(self.likeButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(likeButton)
        let messageButton = UIButton(frame: CGRect(x: likeButton.left - 220, y: remoteVideoViewContainter.bottom - 50, width: 210, height: 40))
        messageButton.backgroundColor = UIColor.green
        messageButton.addTarget(self, action: #selector(self.sendMessageButtonTapped(_:)), for: .touchUpInside)
        messageButton.titleLabel?.adjustsFontSizeToFitWidth = true
        messageButton.setTitle(messageType.greet.text(), for: .normal)
        self.view.addSubview(messageButton)
        
        wsStatusLabel = UILabel(frame: CGRect(x: 0, y: remoteVideoViewContainter.bottom, width: ScreenSizeUtil.width(), height: 30))
        wsStatusLabel.textAlignment = .center
        self.view.addSubview(wsStatusLabel)
        webRTCStatusLabel = UILabel(frame: CGRect(x: 0, y: wsStatusLabel.bottom, width: ScreenSizeUtil.width(), height: 30))
        webRTCStatusLabel.textAlignment = .center
        webRTCStatusLabel.text = webRTCStatusMesasgeBase + "initialized"
        self.view.addSubview(webRTCStatusLabel)
        webRTCMessageLabel = UILabel(frame: CGRect(x: 0, y: webRTCStatusLabel.bottom, width: ScreenSizeUtil.width(), height: 30))
        webRTCMessageLabel.textAlignment = .center
        self.view.addSubview(webRTCMessageLabel)
        
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
    
    @objc func sendMessageButtonTapped(_ sender: UIButton){
        webRTCClient.sendMessge(message: (sender.titleLabel?.text!)!)
        if sender.titleLabel?.text == messageType.greet.text() {
            sender.setTitle(messageType.introduce.text(), for: .normal)
        }else if sender.titleLabel?.text == messageType.introduce.text() {
            sender.setTitle(messageType.greet.text(), for: .normal)
        }
    }
    
    @objc func likeButtonTapped(_ sender: UIButton){
        print("send like")
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
                webRTCClient.receiveCandidate(candidate: RTCIceCandidate(sdp: candidate.sdp, sdpMLineIndex: candidate.sdpMLineIndex, sdpMid: candidate.sdpMid))
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
    
    func didConnectWebRTC() {
        self.webRTCStatusLabel.textColor = .green
        // MARK: Disconnect websocket
        self.socket.disconnect()
    }
    
    func didDisconnectWebRTC() {
         self.webRTCStatusLabel.textColor = .red
    }
    
    func didOpenDataChannel() {
        print("did open data channel")
    }
    
    func didReceiveData(data: Data) {
        
    }
    
    func didReceiveMessage(message: String) {
        self.webRTCMessageLabel.text = message
    }
}
