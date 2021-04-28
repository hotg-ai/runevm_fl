import Flutter
import UIKit

public class SwiftRunevmFlPlugin: NSObject, FlutterPlugin {

  var bytes:[UInt8]=[]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "runevm_fl", binaryMessenger: registrar.messenger())
    let instance = SwiftRunevmFlPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "loadWASM" {
            let uintInt8List =  call.arguments as! FlutterStandardTypedData

            self.bytes = [UInt8](uintInt8List.data)
            result(true)
        }
        else if call.method == "getManifest" {
                let manifest = self.getManifest()
                result(manifest)
        }
        else if call.method == "runRune" {
            let uintInt8List =  call.arguments as! FlutterStandardTypedData
            
            //this is specific to accel
            
            let out =  [UInt8](uintInt8List.data)
                let response = self.runRune(input: out)
                result(response)
        }
        else {
          result("Unknown call to swift " + UIDevice.current.systemVersion)
        }
    //
  }

    func runRune(input:[UInt8]) -> String {
        let input_len = Int32(input.count)
        guard let result = ObjcppBridge.callRunewithInput(input, ofLength: input_len) else {
            return "error"
        }
        
        print("ObjcppBridge.callRunewithInput return result: " + result)
        return result
    }
    
    func getManifest() -> [Any] {
        let bytes_len = Int32(bytes.count)
        guard let result = ObjcppBridge.loadManifest(withBytes: bytes, ofLength: bytes_len) else {
            return []
        }
        
        for cap in result {
            print("ObjcppBridge.loadManifest returned capability: " + String(cap as! Int))
        }
        
        return result
    }
}
