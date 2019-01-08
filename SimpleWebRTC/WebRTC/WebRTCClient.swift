//
//  WebRTCClient.swift
//  SimpleWebRTC
//
//  Created by tkmngch on 2019/01/06.
//  Copyright © 2019年 tkmngch. All rights reserved.
//

import UIKit
import WebRTC

class WebRTCClient: NSObject, RTCPeerConnectionDelegate, RTCVideoViewDelegate {
    
    private var peerConnectionFactory: RTCPeerConnectionFactory!
    private var peerConnection: RTCPeerConnection!
    private var videoCapturer: RTCVideoCapturer!
    private var localVideoTrack: RTCVideoTrack!
    private var localRenderView: RTCEAGLVideoView?
    private var localView: UIView!
    
    func localVideoView() -> UIView {
        return localView
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
        setupLocalView()
        setupLocalTracks()

        startCaptureLocalVideo(cameraPositon: .front, videoWidth: 640, videoHeight: nil, videoFps: 30)
        
        self.localVideoTrack?.add(self.localRenderView!)
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
    
    // MARK: - private functions
    private func setupPeerConnection() -> RTCPeerConnection{
        let rtcConf = RTCConfiguration()
        rtcConf.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])]
        let mediaConstraints = RTCMediaConstraints.init(mandatoryConstraints: nil, optionalConstraints: nil)
        
        let pc = self.peerConnectionFactory.peerConnection(with: rtcConf, constraints: mediaConstraints, delegate: self)
        
        return pc
    }
    
    private func setupLocalView(){
        localRenderView = RTCEAGLVideoView()
        localRenderView!.delegate = self
        localView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width()/3, height: ScreenSizeUtil.height()/3))
        localRenderView!.frame = localView.frame
        localView.addSubview(localRenderView!)
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
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        
    }
    
}

// MARK: RTCVideoView Delegate
extension WebRTCClient{
    
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        
    }
}
