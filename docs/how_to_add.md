## How to add your WebRTC.framework to your xcode project

You can get WebRTC.framework as flowing three ways. 
1. ~~You can download WebRTC.framework from [here](https://github.com/tkmn0/SimpleWebRTCExample_iOS/releases)~~ THIS IS REMOVED. please build on your own.
2. You can build official WebRTC.framework. see [how to build](https://github.com/tkmn0/SimpleWebRTCExample_iOS/blob/master/docs/BuildWebRTCFrameworkFlow.md)
3. You can use cocoapods.

If you choosed 3, I'm not sure this example works, because the framework versions may be different.(this sample code is currently M72).    
If you choosed 1 or 2, you can add your WebRTC.framework to your xcode project as follows.

- Just drag & drop WebRTC.framework to SimpleWebRTC > TARGETS > SimpleWebRTC > General > Embedded Binaries
- Check `Copy items if needed` and click finish.
- It's done!
 
![result](https://raw.githubusercontent.com/tkmn0/SimpleWebRTCExample_iOS/master/media/how_to_add.gif)
