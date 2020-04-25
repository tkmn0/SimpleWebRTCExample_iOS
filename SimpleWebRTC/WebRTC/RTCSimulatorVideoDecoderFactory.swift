//
//  SimlatorVideoEncoderFactory.swift
//  SimpleWebRTC
//
//  Created by n0 on 2020/04/25.
//  Copyright © 2020 n0. All rights reserved.
//

import Foundation
import WebRTC


class RTCSimulatorVideoDecoderFactory: RTCDefaultVideoDecoderFactory {
    
    override init() {
        super.init()
    }
    
    override func supportedCodecs() -> [RTCVideoCodecInfo] {
        var codecs = super.supportedCodecs()
        codecs = codecs.filter{$0.name != "H264"}
        return codecs
    }
}
