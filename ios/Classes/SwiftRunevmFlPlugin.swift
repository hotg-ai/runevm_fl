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
        if call.method == "load" {
            let uintInt8List =  call.arguments as! FlutterStandardTypedData
            
            self.bytes = [UInt8](uintInt8List.data)
            result(true)
        }
        else if call.method == "getManifest" {
            let manifest = self.getManifest()
            result(manifest)
        }
        else if call.method == "getLogs" {
            let logs = self.getLogs()
            result(logs)
        }
        else if call.method == "addInputTensor" {
            let args = call.arguments as! Dictionary<String, Any>
            let nodeID =  args["nodeID"] as! Int32
            let inputData =  args["bytes"] as! FlutterStandardTypedData
            let type =  args["type"] as! Int32
            let dimensions =  args["dimensions"] as! [Int32]
            let response: Void = ObjcppBridge.addInputTensor(nodeID, input: inputData.data, type: type, dimensions: dimensions)
            result(true)
        }
        else if call.method == "runRune" {
            let response = self.runRune()
            result(response)
        }
        else {
            result("Unknown call to swift " + UIDevice.current.systemVersion)
        }
        //
    }
    
    func runRune() -> String {
        guard let result = ObjcppBridge.callRune() else {
            return "error"
        }
        return result
    }
    
    func getLogs() -> String {
        let bytes_len = Int32(bytes.count)
        guard let result = ObjcppBridge.getLogs() else {
            print("No Result!");
            return "[]";
        }
        return result
    }
    
    func getManifest() -> String {
        let bytes_len = Int32(bytes.count)
        guard let result = ObjcppBridge.loadManifest(withBytes: bytes, ofLength: bytes_len) else {
            print("No Result!");
            return "[]";
        }
        return result
    }
}
