WIP

# SimpleWebRTCExample
This is simple WebRTC Exmaple project for iOS written in Swift.
![result](https://raw.githubusercontent.com/tkmn0/SimpleWebRTCExample_iOS/master/media/sample.gif)
# Dependency
- Xcode version 10.1
- Swift version 4.2.1
- WebRTC framework

# Setup
- You need to add WebRTC.framework to your xcode project. see [how_to_add](https://github.com/tkmn0/SimpleWebRTCExample_iOS/blob/master/docs/how_to_add.md)
- You need to setup signaling server.     
  This project includes simple one at `SimpleWebRTCExample_iOS/SignalingServer/`.    
  You can setup node.js as folows.
  - `cd SimpleWebRTCExample_iOS/SignalingServer`
  - `npm install`

# Usage
- Firstly, run the signaling server as folows.
  - `cd SimpleWebRTCExample_iOS/SignalingServer`
  - `node server.js`
  node.js server will start at 8000 port.
- Then, run SinmpleWebRTC on your device or simulator. This example need totaly two devices(simulator & simulator is OK)
- Check websocket connection state on your device. If it is connected, you can tap call button. WebRTC will be connected.
- You can send like with like button. 
  You can send plain messages with message button.
- Enjoy.

# Licence
This software is released under the MIT License, see LICENSE.

# References
