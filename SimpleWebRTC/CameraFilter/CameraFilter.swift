//
//  CameraFilter.swift
//  SimpleWebRTC
//
//  Created by n0 on 2019/10/27.
//  Copyright © 2019 n0. All rights reserved.
//

import Foundation
import AVFoundation
import CoreImage

class CameraFilter {
    
    private let filter: CIFilter
    private let context: CIContext
    
    init() {
        self.filter = CIFilter(name: "CISepiaTone")!
        self.context = CIContext()
    }
    
    func apply(_ sampleBuffer: CVPixelBuffer) -> CVPixelBuffer?{
        let ciimage = CIImage(cvPixelBuffer: sampleBuffer)
        self.filter.setValue(ciimage, forKey: kCIInputImageKey)
        self.filter.setValue(0.8, forKey: "inputIntensity")
        
        let size: CGSize = ciimage.extent.size
        
        let filtered = self.filter.outputImage
        var pixelBuffer: CVPixelBuffer? = nil
        
        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: kCFBooleanTrue
            ] as [String : Any]
        
        let status: CVReturn = CVPixelBufferCreate(kCFAllocatorDefault,
                                                   Int(size.width),
                                                   Int(size.height),
                                                   kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
                                                   options as CFDictionary?,
                                                   &pixelBuffer)
        
        if (status == kCVReturnSuccess && pixelBuffer != nil) {
            self.context.render(filtered!, to: pixelBuffer!)
        }
        return pixelBuffer
    }
}
