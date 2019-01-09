WebRTC iOS Build Example Flow

just flow official page
[iOS | WebRTC](https://webrtc.org/native-code/ios/)

```
mkdir webrtc_build
```

```
cd webrtc_build
```

```
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
```

```
export PATH=`pwd`/depot_tools:"$PATH"
```

```
fetch --nohooks webrtc_ios
```

```
ls
depot_tools src
```

```
cd src
```

check branches
```
git branch -a

* (HEAD detached at origin/master)
  master
  .
  .
  .
  remotes/branch-heads/69
  remotes/branch-heads/70
  remotes/branch-heads/71
  remotes/branch-heads/72
  remotes/branch-heads/phoglund-test
  remotes/origin/HEAD -> origin/master
  remotes/origin/infra/config
```

checkout M72
```
git checkout remotes/branch-heads/72
```

```
gclient sync
```

```
git new-branch local_dev_72
```

for 64bit 
```
gn gen out/ios_64 --args='target_os="ios" target_cpu="arm64" is_debug=false ios_enable_code_signing=false'
```

for 32bit 
```
gn gen out/ios_32 --args='target_os="ios" target_cpu="arm" is_debug=false ios_enable_code_signing=false'
```

for simulator
```
gn gen out/ios_sim --args='target_os="ios" target_cpu="x64" is_debug=false ios_enable_code_signing=false'
``` 

#### Compile with ninja
```
ninja -C out/ios_64 AppRTCMobile
ninja -C out/ios_32 AppRTCMobile
ninja -C out/ios_sim AppRTCMobile
```

#### Combine them(64, 32, sim)
```
mkdir out/ios
```

```
cp -R out/ios_64/WebRTC.framework/ out/ios/WebRTC.framework
```

```
lipo -create out/ios_64/WebRTC.framework/WebRTC out/ios_32/WebRTC.framework/WebRTC out/ios_sim/WebRTC.framework/WebRTC -output out/ios/WebRTC.framework/WebRTC
```

`out/ios/WebRTC.framework`
this is our goal!! 





