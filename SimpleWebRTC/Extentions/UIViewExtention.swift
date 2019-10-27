//
//  UIViewExtention.swift
//  SimpleWebRTC
//
//  Created by n0 on 2019/01/08.
//  Copyright © 2019 n0. All rights reserved.
//

import UIKit

extension UIView {
    
    var top : CGFloat{
        get{
            return self.frame.origin.y
        }
        set{
            var frame       = self.frame
            frame.origin.y  = newValue
            self.frame      = frame
        }
    }
    
    var bottom : CGFloat{
        get{
            return frame.origin.y + frame.size.height
        }
        set{
            var frame       = self.frame
            frame.origin.y  = newValue - self.frame.size.height
            self.frame      = frame
        }
    }
    
    var right : CGFloat{
        get{
            return self.frame.origin.x + self.frame.size.width
        }
        set{
            var frame       = self.frame
            frame.origin.x  = newValue - self.frame.size.width
            self.frame      = frame
        }
    }
    
    var left : CGFloat{
        get{
            return self.frame.origin.x
        }
        set{
            var frame       = self.frame
            frame.origin.x  = newValue
            self.frame      = frame
        }
    }
}
