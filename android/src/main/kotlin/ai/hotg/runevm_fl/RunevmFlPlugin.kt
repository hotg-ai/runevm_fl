package ai.hotg.runevm_fl

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** RunevmFlPlugin */
class RunevmFlPlugin: FlutterPlugin, MethodCallHandler {

  companion object {
    var wasmBytes:ByteArray = ByteArray(0);
  }

  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "runevm_fl")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "load") {
      val wasmBytes = call.arguments as ByteArray
      println(wasmBytes.size)
      load(call, result, wasmBytes)
    }
    if (call.method == "getManifest") {
      getManifest(call, result)
    }
    if (call.method == "runRune") {
      runRune(call, result)
    }
  }

  init {
    System.loadLibrary("rune_vm_loader")
  }

  private fun load(call: MethodCall, result:Result, bytes: ByteArray) {
    wasmBytes = bytes;
    return result.success(true) ;
  }

  private fun getManifest(call: MethodCall, result:Result) {
    val getManifestResult = this.getManifest(wasmBytes);
    if(getManifestResult == null) {
      result.error("0", "Failed to get manifest", null)
    }

    return result.success(getManifestResult!!)
  }

  private fun runRune(call: MethodCall, result:Result) {
    //runRune SDK functions

    val lengths = (call.argument<List<Int>>("lengths")!!).toIntArray();

    val runRuneResult = this.runRune(call.argument<ByteArray>("bytes")!!,lengths);
    if(runRuneResult == null) {
      result.error("0", "Failed to run rune", null)
    }

    return result.success(runRuneResult!!)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  //declare SDK functions
  private external fun getManifest(wasm: ByteArray): String?
  private external fun runRune(input: ByteArray, lengths: IntArray): String?
}
