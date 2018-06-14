# swiftSDK

## First
pod 'swiftSDK'

## Attention: 
add use_frameworks! in podfile

## After pod install
import swiftSDK in white file you want to use

## Attention: 
add "openapp.nasnano" for white list so you can jump to NAS nano

## Usage

```swift
import swiftSDK
```

### 1. Debug mode

```swift
NASSmartContracts.debug(debug: true) // use the debug net
```

### 2. Check wallet APP

```swift
if NASSmartContracts.nasNanoInstalled() {
    // if wallet APP is not installed, go to AppStore.
    NASSmartContracts.goToNasNanoAppStore()
}
```

### 3. Pay

```swift
    sn = NASSmartContracts.randomCodeWithLength(length: 32)
    let error = NASSmartContracts.payNasWith(nas: 0.000001,
                                        address: "n1a4MqSPPND7d1UoYk32jXqKb5m5s3AN6wB",
                                             sn: sn,
                                           name: "test1",
                                           desc: "desc")
    if error != nil {
        print("\(String(describing: error?.userInfo["msg"]))")
        NASSmartContracts.goToNasNanoAppStore()
    }
```

### 4. Call contract function

```swift
sn = NASSmartContracts.randomCodeWithLength(length: 32)
let error = NASSmartContracts.callWith(nas: 0,
method: "save",
args: ["key111","value111"],
address: "n1zVUmH3BBebksT4LD5gMiWgNU9q3AMj3se",
sn: sn,
name: "test2",
desc: "desc2")
if error != nil {
print("\(String(describing: error?.userInfo["msg"]))")
NASSmartContracts.goToNasNanoAppStore()
}
```

### 5. Check status

```swift
NASSmartContracts.checkStatusWith(sn: sn, headler: { (dic) in
print(dic)
}) { (code, msg) in
print("code:\(code),msg:\(msg)")
}
```
