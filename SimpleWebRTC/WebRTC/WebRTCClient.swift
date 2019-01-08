//
//  WebRTCClient.swift
//  SimpleWebRTC
//
//  Created by tkmngch on 2019/01/06.
//  Copyright © 2019年 tkmngch. All rights reserved.
//

import UIKit
import WebRTC

protocol WebRTCClientDelegate {
    func didGenerateCandidate(iceCandidate: RTCIceCandidate)
}

class WebRTCClient: NSObject, RTCPeerConnectionDelegate, RTCVideoViewDelegate {
    
    private var peerConnectionFactory: RTCPeerConnectionFactory!
    private var peerConnection: RTCPeerConnection!
    private var videoCapturer: RTCVideoCapturer!
    private var localVideoTrack: RTCVideoTrack!
    private var localRenderView: RTCEAGLVideoView?
    private var localView: UIView!
    private var remoteRenderView: RTCEAGLVideoView?
    private var remoteView: UIView!
    private var remoteStream: RTCMediaStream?
    var delegate: WebRTCClientDelegate?
    
    func localVideoView() -> UIView {
        return localView
    }
    
    func remoteVideoView() -> UIView {
        return remoteView
    }
    
    override init() {
        super.init()
        print("WebRTC Client initialize")
    }
    
    deinit {
        print("WebRTC Client Deinit")
        self.peerConnectionFactory = nil
        self.peerConnection = nil
    }
    
    // MARK: - public functions
    func setup(){
        print("set up")
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        self.peerConnectionFactory = RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
        
        self.peerConnection = setupPeerConnection()
        setupView()
        setupLocalTracks()
        
        startCaptureLocalVideo(cameraPositon: .front, videoWidth: 640, videoHeight: 640*16/9, videoFps: 30)
        
        self.localVideoTrack?.add(self.localRenderView!)
    }
    
    func setupLocalViewFrame(frame: CGRect){
        localView.frame = frame
        localRenderView?.frame = localView.frame
    }
    
    func setupRemoteViewFrame(frame: CGRect){
        remoteView.frame = frame
        remoteRenderView?.frame = remoteView.frame
    }
    
    // MARK: signaling
    func makeOffer(onSuccess: @escaping (RTCSessionDescription) -> Void) {
        
        self.peerConnection.offer(for: RTCMediaConstraints.init(mandatoryConstraints: nil, optionalConstraints: nil)) { (sdp, err) in
            if let error = err {
                print("error with make offer")
                print(error)
                return
            }
            
            if let offerSDP = sdp {
                print("make offer, created local sdp")
                self.peerConnection.setLocalDescription(offerSDP, completionHandler: { (err) in
                    if let error = err {
                        print("error with set local offer sdp")
                        print(error)
                        return
                    }
                    print("succeed to set local offer SDP")
                    onSuccess(offerSDP)
                })
            }
            
        }
    }
    
    func recieveOffer(offerSDP: RTCSessionDescription, onCreateAnswer: @escaping (RTCSessionDescription) -> Void){
        self.peerConnection.setRemoteDescription(offerSDP) { (err) in
            if let error = err {
                print("failed to set remote offer SDP")
                print(error)
                return
            }
            
            print("succeed to set remote offer SDP")
            self.peerConnection.answer(for: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil), completionHandler: { (answerSessionDescription, err) in
                if let error = err {
                    print("failed to create local answer SDP")
                    print(error)
                    return
                }
                
                print("succeed to create local answer SDP")
                if let answerSDP = answerSessionDescription{
                    self.peerConnection.setLocalDescription( answerSDP, completionHandler: { (err) in
                        if let error = err {
                            print("failed to set local ansewr SDP")
                            print(error)
                            return
                        }
                        
                        print("succeed to set local answer SDP")
                        onCreateAnswer(answerSDP)
                    })
                }
            })
        }
    }
    
    func recieveAnswer(answerSDP: RTCSessionDescription){
        self.peerConnection.setRemoteDescription(answerSDP) { (err) in
            if let error = err {
                print("failed to set remote answer SDP")
                print(error)
                return
            }
        }
    }
    
    func recieveCandidate(candidate: RTCIceCandidate){
        self.peerConnection.add(candidate)
    }
    
    // MARK: - private functions
    private func setupPeerConnection() -> RTCPeerConnection{
        let rtcConf = RTCConfiguration()
        rtcConf.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])]
        let mediaConstraints = RTCMediaConstraints.init(mandatoryConstraints: nil, optionalConstraints: nil)
        
        let pc = self.peerConnectionFactory.peerConnection(with: rtcConf, constraints: mediaConstraints, delegate: self)
        
        return pc
    }
    
    private func setupView(){
        localRenderView = RTCEAGLVideoView()
        localRenderView!.delegate = self
        localView = UIView()
        localView.addSubview(localRenderView!)
        
        remoteRenderView = RTCEAGLVideoView()
        remoteRenderView?.delegate = self
        remoteView = UIView()
        remoteView.addSubview(remoteRenderView!)
    }
    
    private func setupLocalTracks(){
        self.peerConnection.add(createAudioTrack(), streamIds: ["stream0"])
        self.localVideoTrack = createVideoTrack()
        self.peerConnection.add(localVideoTrack, streamIds: ["stream0"])
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = self.peerConnectionFactory.audioSource(with: audioConstrains)
        let audioTrack = self.peerConnectionFactory.audioTrack(with: audioSource, trackId: "audio0")
        audioTrack.source.volume = 10.0
        return audioTrack
    }
    
    private func createVideoTrack() -> RTCVideoTrack {
        let videoSource = self.peerConnectionFactory.videoSource()
        if TARGET_OS_SIMULATOR != 0 {
            self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        }
        else {
            self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        }
        let videoTrack = self.peerConnectionFactory.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }
    
    func startCaptureLocalVideo(cameraPositon: AVCaptureDevice.Position, videoWidth: Int, videoHeight: Int?, videoFps: Int) {
        guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else {
            return
        }
        
        var targetDevice: AVCaptureDevice?
        var targetFormat: AVCaptureDevice.Format?
        
        // find target device
        let devicies = RTCCameraVideoCapturer.captureDevices()
        devicies.forEach { (device) in
            if device.position ==  cameraPositon{
                targetDevice = device
            }
        }
        
        // find target format
        let formats = RTCCameraVideoCapturer.supportedFormats(for: targetDevice!)
        formats.forEach { (format) in
            for _ in format.videoSupportedFrameRateRanges {
                let description = format.formatDescription as CMFormatDescription
                let dimensions = CMVideoFormatDescriptionGetDimensions(description)
                
                if dimensions.width == videoWidth && dimensions.height == videoHeight ?? 0{
                    targetFormat = format
                } else if dimensions.width == videoWidth {
                    targetFormat = format
                }
            }
        }
        
        capturer.startCapture(with: targetDevice!,
                              format: targetFormat!,
                              fps: videoFps)
    }
    
}

// MARK: PeerConnection Delegeate
extension WebRTCClient {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        var state = ""
        if stateChanged == .stable{
            state = "stable"
        }
        
        if stateChanged == .closed{
             state = "closed"
        }
        
        print("signaling state changed: ", state)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        if newState == .connected {
            print("ice connection state is connected")
        }
        if newState == .completed {
            print("ice completed")
        }
        if newState == .failed {
            print("ice failed")
        }
        if newState == .closed {
            print("ice closed")
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("ice gathering state changed: ", newState)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("did add stream")
        self.remoteStream = stream
        
        if let track = stream.videoTracks.first {
            print("video track faund")
            track.add(remoteRenderView!)
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("did remove stream")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        self.delegate?.didGenerateCandidate(iceCandidate: candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print("peer connection should negotiate")
    }
    
}

// MARK: RTCVideoView Delegate
extension WebRTCClient{
    
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        if videoView.isEqual(localRenderView){
            print("local video size changed")
        }
        
        if videoView.isEqual(remoteRenderView!){
            print("remote video size changed")
        }
    }
}
