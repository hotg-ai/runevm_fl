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
  var isLibraryLoaded = false;

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "runevm_fl")
    channel.setMethodCallHandler(this)
    if(!isLibraryLoaded) {
      System.loadLibrary("rune_vm_loader");
      isLibraryLoaded = true;
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    println("##### method call ${call.method}");
    if (call.method == "load") {
      val wasmBytes = call.arguments as ByteArray
      println(wasmBytes.size)
      load(call, result, wasmBytes)
    }
    if (call.method == "getManifest") {
      manifest(call, result)
      //manifest(call, result)
    }
    if (call.method == "runRune") {
      run(call, result)
    }
    if (call.method == "addInputTensor") {
      addInput(call, result)
    }
    if (call.method == "getLogs") {
      logs(call, result)
    }
  }

  init {
    
  }

  private fun load(call: MethodCall, result:Result, bytes: ByteArray) {
    wasmBytes = bytes;
    return result.success(true) ;
  }

  private fun logs(call: MethodCall, result:Result) {
    val logsResult = getLogs();
    if(logsResult == null) {
      result.error("0", "Failed to get manifest", null)
    }
  
    return result.success(logsResult!!)
  }

  private fun manifest(call: MethodCall, result:Result) {
    val getManifestResult = getManifest(wasmBytes);

    if(getManifestResult == null) {
      result.error("0", "Failed to get manifest", null)
    }
  
    return result.success(getManifestResult!!)
  }

  private fun run(call: MethodCall, result:Result) {
    //runRune SDK functions
    val runRuneResult = this.runRune();
    if(runRuneResult == null) {
      result.error("0", "Failed to run rune", null)
    }

    return result.success(runRuneResult!!)
  }

  private fun addInput(call: MethodCall, result:Result) {
    //runRune SDK functions
    println(call.argument<Int>("nodeID")!!);
    val nodeID = call.argument<Int>("nodeID")!!;
    val bytes = call.argument<ByteArray>("bytes")!!;
    val type = call.argument<Int>("type")!!;
    val dimensions = (call.argument<List<Int>>("dimensions")!!).toIntArray();

    val addInputResult = this.addInputTensor(nodeID,bytes,type,dimensions,dimensions.size);
    if(addInputResult == null) {
      result.error("0", "Failed to addInput", null)
    }

    return result.success("")
  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  //declare SDK functions
  private external fun getLogs(): String?
  private external fun getManifest(wasm: ByteArray): String?
  private external fun addInputTensor(node_id: Int, input: ByteArray, type: Int, dimensions: IntArray, rank: Int );
  private external fun runRune(): String?
}
