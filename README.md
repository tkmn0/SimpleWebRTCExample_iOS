# SimpleWebRTCExample

This is simple WebRTC Exmaple project for iOS written in Swift.
![result](https://raw.githubusercontent.com/tkmn0/SimpleWebRTCExample_iOS/master/media/sample.gif)

# Feature

- Super simple WebRTC example project written in Swift.
- Example command lines to build WebRTC.framework.[here](https://github.com/tkmn0/SimpleWebRTCExample_iOS/blob/master/docs/BuildWebRTCFrameworkFlow.md)
- ~~Includes prebuild WebRTC.framework [here](https://github.com/tkmn0/SimpleWebRTCExample_iOS/releases). (This is for TEST ONLY.)~~ THIS IS REMOVED.
- Datachannel implementation (text and bytes).
- File Source implementation.
- Camera position switching(tap local camera view.)
- Includes super simple signaling server written in node.js.

# Dependency

- Xcode version 10.3
- Swift version 5
- [GoogleWebRTC](https://cocoapods.org/pods/GoogleWebRTC)
- [Starscream](https://github.com/daltoniam/starscream) (for websocket)

# Setup
- ~~You need to add WebRTC.framework to your xcode project. see [how_to_add](https://github.com/tkmn0/SimpleWebRTCExample_iOS/blob/master/docs/how_to_add.md)~~ If you want to build WebRTC.framework and use it, see [how_to_add](https://github.com/tkmn0/SimpleWebRTCExample_iOS/blob/master/docs/how_to_add.md). Currently, this project uses GoogleWebRTC installed via pod.
- `pod install`
- You need to setup signaling server.  
  This project includes simple one at `SimpleWebRTCExample_iOS/SignalingServer/`.  
  You can setup node.js as folows.
  - `cd SimpleWebRTCExample_iOS/SignalingServer`
  - `npm install`

# Usage

- Firstly, run the signaling server as folows.
  - `cd SimpleWebRTCExample_iOS/SignalingServer`
  - `node server.js`
    node.js server will start at 8080 port.
- Change signaling server url ( the `ipAddress` String vallue) to your case in [ViewController.swift](./SimpleWebRTC/ViewController/ViewController.swift). You can find your signaling server url in signaling server log.
- Then, run SinmpleWebRTC on your device or simulator. This example need totaly two devices(simulator & simulator is OK)
- Check websocket connection state on your device. If it is connected, you can tap call button. WebRTC will be connected.
- You can send like with like button.
  You can send plain messages with message button.
- Enjoy.

# Licence

This software is released under the MIT License, see LICENSE.
