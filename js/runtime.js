import { KnownCapabilities, KnownOutputs, } from "./imports.js";


export default class Runtime {
    parameters;
    data;
    instance;
    models;

    constructor(instance, params, models, data) {
        this.instance = instance;
        this.parameters = params;
        this.data = data;
        this.models = models;
    }

    setInput(input) {

    }
    getCapabilities() {
        let cap = [];
        this.parameters.forEach((param) => {
            if (param.function == "request_capability") {
                cap.push(param);
            }
        });
        return cap;
    }

    getParameters() {
        let params = [];
        this.parameters.forEach((param) => {
            if (param.function == "request_capability_set_param") {
                params.push(param);
            }
        });
        return params;
    }

    getModels() {
        return this.models;
    }

    static async load(mod, imports, modelConstructor = loadTensorflowJSModel) {
        let parameters = [];
        let data = { "input": [], "output": [] };

        let memory;
        const [hostFunctions, finaliseModels, getParams, id] = importsToHostFunctions(imports, () => memory, () => parameters, () => data, modelConstructor);

        const instance = await WebAssembly.instantiate(mod, hostFunctions);
        if (!isRuneExports(instance.exports)) {
            throw new Error("Invalid Rune exports");
        }

        memory = instance.exports.memory;

        console.log("manifest!!!");
        instance.exports._manifest();
        // now we've asked for all the models to be loaded, let's wait until
        // they are done before continuing
        await finaliseModels();
        return new Runtime(instance, parameters, id, data);
    }

    manifest() {
        //return 1;
        return this.exports._manifest();
    }



    call() {
        this.exports._call(0, 0, 0);
    }

    get parameters() {
        return this.params;
    }

    get exports() {
        // Note: checked inside Runtime.load() and exports will never change.
        return this.instance.exports;
    }
}
function constructFromNameTable(nextId, nameTable, constructors) {
    const instances = new Map();
    function create(type) {
        const name = nameTable[type];
        if (!name) {
            throw new Error(`type ${type} is unknown`);
        }
        const constructor = constructors[name];
        if (!constructor) {
            throw new Error(`No constructor for type ${type} called \"${name}\"`);
        }
        const instance = constructor();
        const id = nextId();
        instances.set(id, instance);
        return id;
    }
    return [instances, create];
}
function importsToHostFunctions(imports, getMemory, getParameters, getData, modelConstructor) {
    const memory = () => {
        const m = getMemory();
        if (!m)
            throw new Error("WebAssembly memory wasn't initialized");

        return new Uint8Array(m.buffer);
    };
    const parameters = () => {
        const p = getParameters();
        if (!p)
            throw new Error("Parameters wasn't initialized");

        return p;
    };
    const data = () => {
        const d = getData();
        if (!d)
            throw new Error("Data wasn't initialized");

        return d;
    }

    const ids = counter();
    const [outputs, createOutput] = constructFromNameTable(ids, KnownOutputs, imports.outputs);
    const [capabilities, createCapability] = constructFromNameTable(ids, KnownCapabilities, imports.capabilities);
    const pendingModels = [];
    const models = new Map();
    const utf8 = new TextDecoder();
    // Annoyingly, this needs to be an object literal instead of a class.
    const env = {
        _debug(msg, len) {
            console.log("_debug");
            const raw = memory().subarray(msg, msg + len);
            const message = utf8.decode(raw);
            console.log(message);
        },
        request_output(type) {
            console.log("request output");
            return createOutput(type);
        },
        consume_output(id, buffer, len) {
            console.log("consume_output");
            const output = outputs.get(id);
            if (output) {
                const data = memory().subarray(buffer, buffer + len);
                output.consume(data);
            }
            else {
                throw new Error("Invalid output");
            }
        },
        request_capability(type) {
            parameters().push({ "function": "request_capability", "id": type, "capability": KnownCapabilities[type] })
            return createCapability(type);
        },
        request_capability_set_param() {
            //let bytes = [];
            const id = arguments[0];
            const key = memory().subarray(arguments[1], arguments[1] + arguments[2]);
            const value = memory().subarray(arguments[3], arguments[3] + arguments[4]);
            const valueType = KnownOutputs[arguments[5]];
            parameters().push({ "function": "request_capability_set_param", "id": id, "key": String.fromCharCode.apply(String, key), "value": new Uint32Array(value)[0], "valueType": valueType })
        },
        request_provider_response(buffer, len, id) {
            console.log("request_provider_response");
            const cap = capabilities.get(id);
            if (!cap) {
                throw new Error("Invalid capabiltiy");
            }
            const dest = memory().subarray(buffer, buffer + len);

            cap.generate(dest);
            console.log("Setting data Input");
            data()["float32"] = Array.from(dest).map(function (element) {
                return element * 1.0 / 255;
            });;
            console.log("Setting data Input", data().input);
        },
        async tfm_preload_model(data, len, _) {
            console.log("model:", data, len);
            const modelData = memory().subarray(data, data + len);

            const pending = modelConstructor(modelData, getParameters());
            const id = ids();
            pendingModels.push(pending.then(model => [id, model]));
            console.log(id, pendingModels);
            return id;
        },
        tfm_model_invoke(id, inputPtr, inputLen, outputPtr, outputLen) {

            console.log("model invoke ", id);
            const model = models.get(id + 1);
            if (!model) {
                throw new Error("Invalid model");
            }

            // HACK to bypass normalisaTION
            //const input = memory().subarray(inputPtr, inputPtr + inputLen);
            //REMOVE 
            const input = convertTypedArray(Float32Array.from(data()["float32"]), Uint8Array);

            const output = memory().subarray(outputPtr, outputPtr + outputLen);
            model.transform(input, output);
        },
    };
    async function synchroniseModelLoading() {
        const loadedModels = await Promise.all(pendingModels);
        pendingModels.length = 0;
        loadedModels.forEach(([id, model]) => {
            models.set(id, model);
        });
    }
    return [{ env }, synchroniseModelLoading, parameters, models];
}

function counter() {
    let value = 0;
    return () => value++;
}
function isRuneExports(obj) {
    return (obj &&
        obj.memory instanceof WebAssembly.Memory &&
        obj._call instanceof Function &&
        obj._manifest instanceof Function);
}
async function loadTensorflowJSModel(bytes, parameters = []) {
    let utf16String = '';
    var len = bytes.byteLength;
    for (var i = 0; i < len; i++) {
        utf16String += String.fromCharCode(bytes[i]);
    }
    let decodedString = decodeURIComponent(escape(utf16String));

    await modelToIndexedDB(decodedString);
    const model_name = "imagenet_mobilenet_v3";
    const model = await tf.loadGraphModel('indexeddb://' + model_name);
    return {
        transform(input, output) {
            let capabilities = getCapabilities(parameters);
            let params = getParameters(parameters);

            // IMAGE
            if (capabilities.includes("image")) {
                var inputTyped = convertTypedArray(input, Float32Array);
                console.log(inputTyped);
                //pub enum PixelFormat 
                if (params["pixel_format"] == 3) {
                    //GrayScale =  3
                    input = tf.tensor2d(inputTyped, [params["width"], params["height"]]).expandDims(0);
                } else {
                    //RGB = 0,
                    //BGR = 1,
                    //YUV = 2,  
                    input = tf.tensor3d(inputTyped, [params["width"], params["height"], 3]).expandDims(0);
                }
            } else {
                input = convertTypedArray(input, Uint8Array);
            }

            const out = model.predict(input);
            const result = out.dataSync();

            var uint8_output = convertTypedArray(result, Uint8Array);
            console.log("out", result);
            output.set(uint8_output);
        }

    }
}

//this function can convert any TypedArray to any other kind of TypedArray :
function convertTypedArray(src, type) {
    var buffer = new ArrayBuffer(src.byteLength);
    var baseView = new src.constructor(buffer).set(src);
    return new type(buffer);
}

function getCapabilities(parameters) {
    let cap = [];
    parameters.forEach((param) => {
        if (param.function == "request_capability") {
            cap.push(param.capability);
        }
    });
    return cap;
}

function getParameters(parameters) {
    let params = {};
    parameters.forEach((param) => {
        if (param.function == "request_capability_set_param") {
            params[param.key] = param.value;
        }
    });
    return params;
}

async function modelToIndexedDB(model_bytes) {
    var data = JSON.parse(LZString.decompressFromUTF16(model_bytes));
    var DBOpenRequest = window.indexedDB.open("tensorflowjs", 1);
    let successes = 0;
    DBOpenRequest.onupgradeneeded = function (event) {
        const db = DBOpenRequest.result;
        var objectStore = db.createObjectStore("models_store", {
            "keyPath": "modelPath"
        });
        var objectInfoStore = db.createObjectStore("model_info_store", {
            "keyPath": "modelPath"
        });

    }
    DBOpenRequest.onsuccess = function (event) {
        const db = DBOpenRequest.result;
        data.models_store.modelArtifacts.weightData = new Uint32Array(data.weightData).buffer;
        var objectStore = db.transaction("models_store", "readwrite").objectStore("models_store");
        var objectStoreRequest = objectStore.put(data["models_store"]);
        console.log("models_store", data["models_store"]);
        objectStoreRequest.onsuccess = function (event) {
            successes++;
        }
        var objectInfoStore = db.transaction("model_info_store", "readwrite").objectStore("model_info_store");
        var objectInfoStoreRequest = objectInfoStore.put(data["model_info_store"]);
        console.log(data["model_info_store"]);
        objectInfoStoreRequest.onsuccess = function (event) {
            successes++;
        }
    }
    while (successes < 2) {
        await new Promise(r => setTimeout(r, 100));
    }
    console.log("Imported from json!", successes)
    return true;
}

function getInt32Bytes(x) {
    var bytes = [];
    var i = 4;
    do {
        bytes[--i] = x & (255);
        x = x >> 4;
    } while (i)
    return bytes;
}
function string2Bin(str) {
    var result = [];
    for (var i = 0; i < str.length; i++) {
        result.push(str.charCodeAt(i));
    }
    return result;
}

//var LZString = function () { function o(o, r) { if (!t[o]) { t[o] = {}; for (var n = 0; n < o.length; n++)t[o][o.charAt(n)] = n } return t[o][r] } var r = String.fromCharCode, n = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=", e = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-$", t = {}, i = { compressToBase64: function (o) { if (null == o) return ""; var r = i._compress(o, 6, function (o) { return n.charAt(o) }); switch (r.length % 4) { default: case 0: return r; case 1: return r + "==="; case 2: return r + "=="; case 3: return r + "=" } }, decompressFromBase64: function (r) { return null == r ? "" : "" == r ? null : i._decompress(r.length, 32, function (e) { return o(n, r.charAt(e)) }) }, compressToUTF16: function (o) { return null == o ? "" : i._compress(o, 15, function (o) { return r(o + 32) }) + " " }, decompressFromUTF16: function (o) { return null == o ? "" : "" == o ? null : i._decompress(o.length, 16384, function (r) { return o.charCodeAt(r) - 32 }) }, compressToUint8Array: function (o) { for (var r = i.compress(o), n = new Uint8Array(2 * r.length), e = 0, t = r.length; t > e; e++) { var s = r.charCodeAt(e); n[2 * e] = s >>> 8, n[2 * e + 1] = s % 256 } return n }, decompressFromUint8Array: function (o) { if (null === o || void 0 === o) return i.decompress(o); for (var n = new Array(o.length / 2), e = 0, t = n.length; t > e; e++)n[e] = 256 * o[2 * e] + o[2 * e + 1]; var s = []; return n.forEach(function (o) { s.push(r(o)) }), i.decompress(s.join("")) }, compressToEncodedURIComponent: function (o) { return null == o ? "" : i._compress(o, 6, function (o) { return e.charAt(o) }) }, decompressFromEncodedURIComponent: function (r) { return null == r ? "" : "" == r ? null : (r = r.replace(/ /g, "+"), i._decompress(r.length, 32, function (n) { return o(e, r.charAt(n)) })) }, compress: function (o) { return i._compress(o, 16, function (o) { return r(o) }) }, _compress: function (o, r, n) { if (null == o) return ""; var e, t, i, s = {}, p = {}, u = "", c = "", a = "", l = 2, f = 3, h = 2, d = [], m = 0, v = 0; for (i = 0; i < o.length; i += 1)if (u = o.charAt(i), Object.prototype.hasOwnProperty.call(s, u) || (s[u] = f++, p[u] = !0), c = a + u, Object.prototype.hasOwnProperty.call(s, c)) a = c; else { if (Object.prototype.hasOwnProperty.call(p, a)) { if (a.charCodeAt(0) < 256) { for (e = 0; h > e; e++)m <<= 1, v == r - 1 ? (v = 0, d.push(n(m)), m = 0) : v++; for (t = a.charCodeAt(0), e = 0; 8 > e; e++)m = m << 1 | 1 & t, v == r - 1 ? (v = 0, d.push(n(m)), m = 0) : v++, t >>= 1 } else { for (t = 1, e = 0; h > e; e++)m = m << 1 | t, v == r - 1 ? (v = 0, d.push(n(m)), m = 0) : v++, t = 0; for (t = a.charCodeAt(0), e = 0; 16 > e; e++)m = m << 1 | 1 & t, v == r - 1 ? (v = 0, d.push(n(m)), m = 0) : v++, t >>= 1 } l--, 0 == l && (l = Math.pow(2, h), h++), delete p[a] } else for (t = s[a], e = 0; h > e; e++)m = m << 1 | 1 & t, v == r - 1 ? (v = 0, d.push(n(m)), m = 0) : v++, t >>= 1; l--, 0 == l && (l = Math.pow(2, h), h++), s[c] = f++, a = String(u) } if ("" !== a) { if (Object.prototype.hasOwnProperty.call(p, a)) { if (a.charCodeAt(0) < 256) { for (e = 0; h > e; e++)m <<= 1, v == r - 1 ? (v = 0, d.push(n(m)), m = 0) : v++; for (t = a.charCodeAt(0), e = 0; 8 > e; e++)m = m << 1 | 1 & t, v == r - 1 ? (v = 0, d.push(n(m)), m = 0) : v++, t >>= 1 } else { for (t = 1, e = 0; h > e; e++)m = m << 1 | t, v == r - 1 ? (v = 0, d.push(n(m)), m = 0) : v++, t = 0; for (t = a.charCodeAt(0), e = 0; 16 > e; e++)m = m << 1 | 1 & t, v == r - 1 ? (v = 0, d.push(n(m)), m = 0) : v++, t >>= 1 } l--, 0 == l && (l = Math.pow(2, h), h++), delete p[a] } else for (t = s[a], e = 0; h > e; e++)m = m << 1 | 1 & t, v == r - 1 ? (v = 0, d.push(n(m)), m = 0) : v++, t >>= 1; l--, 0 == l && (l = Math.pow(2, h), h++) } for (t = 2, e = 0; h > e; e++)m = m << 1 | 1 & t, v == r - 1 ? (v = 0, d.push(n(m)), m = 0) : v++, t >>= 1; for (; ;) { if (m <<= 1, v == r - 1) { d.push(n(m)); break } v++ } return d.join("") }, decompress: function (o) { return null == o ? "" : "" == o ? null : i._decompress(o.length, 32768, function (r) { return o.charCodeAt(r) }) }, _decompress: function (o, n, e) { var t, i, s, p, u, c, a, l, f = [], h = 4, d = 4, m = 3, v = "", w = [], A = { val: e(0), position: n, index: 1 }; for (i = 0; 3 > i; i += 1)f[i] = i; for (p = 0, c = Math.pow(2, 2), a = 1; a != c;)u = A.val & A.position, A.position >>= 1, 0 == A.position && (A.position = n, A.val = e(A.index++)), p |= (u > 0 ? 1 : 0) * a, a <<= 1; switch (t = p) { case 0: for (p = 0, c = Math.pow(2, 8), a = 1; a != c;)u = A.val & A.position, A.position >>= 1, 0 == A.position && (A.position = n, A.val = e(A.index++)), p |= (u > 0 ? 1 : 0) * a, a <<= 1; l = r(p); break; case 1: for (p = 0, c = Math.pow(2, 16), a = 1; a != c;)u = A.val & A.position, A.position >>= 1, 0 == A.position && (A.position = n, A.val = e(A.index++)), p |= (u > 0 ? 1 : 0) * a, a <<= 1; l = r(p); break; case 2: return "" }for (f[3] = l, s = l, w.push(l); ;) { if (A.index > o) return ""; for (p = 0, c = Math.pow(2, m), a = 1; a != c;)u = A.val & A.position, A.position >>= 1, 0 == A.position && (A.position = n, A.val = e(A.index++)), p |= (u > 0 ? 1 : 0) * a, a <<= 1; switch (l = p) { case 0: for (p = 0, c = Math.pow(2, 8), a = 1; a != c;)u = A.val & A.position, A.position >>= 1, 0 == A.position && (A.position = n, A.val = e(A.index++)), p |= (u > 0 ? 1 : 0) * a, a <<= 1; f[d++] = r(p), l = d - 1, h--; break; case 1: for (p = 0, c = Math.pow(2, 16), a = 1; a != c;)u = A.val & A.position, A.position >>= 1, 0 == A.position && (A.position = n, A.val = e(A.index++)), p |= (u > 0 ? 1 : 0) * a, a <<= 1; f[d++] = r(p), l = d - 1, h--; break; case 2: return w.join("") }if (0 == h && (h = Math.pow(2, m), m++), f[l]) v = f[l]; else { if (l !== d) return null; v = s + s.charAt(0) } w.push(v), f[d++] = s + v.charAt(0), h--, s = v, 0 == h && (h = Math.pow(2, m), m++) } } }; return i }(); "function" == typeof define && define.amd ? define(function () { return LZString }) : "undefined" != typeof module && null != module && (module.exports = LZString);