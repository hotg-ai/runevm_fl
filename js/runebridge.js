class RuneBridge {
    #rune_bytes;
    #rune;
    #model;
    #wasm;
    #runtime;
    input;
    output;
    getUserMedia(parameters) {
        return navigator.getUserMedia(parameters) ||
            navigator.webkitGetUserMedia(parameters) ||
            navigator.mozGetUserMedia(parameters);
    }

    constructor() {
        this.loadRune();
        this.input = { "data": [] };
        this.output = { "data": [] };
    }

    mobilenet;

    async loadRune() {
        if (this.rune == null) {
            this.rune = await import('./index.js');

        }

        return true;
    }



    async downloadModel(model_name, downloadModelFinal) {
        console.log("download model ");
        var DBOpenRequest = window.indexedDB.open("tensorflowjs", 1);
        DBOpenRequest.onsuccess = function (event) {
            const db = DBOpenRequest.result;
            console.log(db.objectStoreNames);
            var objectStore = db.transaction("model_info_store").objectStore("model_info_store");
            console.log(objectStore);
            objectStore.openCursor().onsuccess = function (event) {
                var cursor = event.target.result;
                if (cursor) {
                    console.log("id " + cursor.key, cursor.value);
                    if (cursor.key == model_name) {
                        downloadModelFinal(model_name, cursor.value)
                    }
                    cursor.continue();
                }
                else {

                }
            };
        };
    }

    async downloadModelFinal(model_name, model_info_store) {
        var DBOpenRequest = window.indexedDB.open("tensorflowjs");
        DBOpenRequest.onsuccess = function (event) {
            const db = DBOpenRequest.result;
            console.log(db.objectStoreNames);
            var objectStore = db.transaction("models_store").objectStore("models_store");
            console.log(objectStore);
            var objectStoreRequest = objectStore.get(model_name);
            objectStoreRequest.onsuccess = function (event) {

                var models_store = objectStoreRequest.result;
                console.log(models_store);
                //change arraybuffer to array
                const weightData = Array.from(new Uint32Array(models_store.modelArtifacts.weightData));
                //too big: Array.from(new Uint32Array(models_store.modelArtifacts.weightData));
                const file_content = LZString.compressToUTF16(JSON.stringify({ "model_name": model_name, "model_info_store": model_info_store, "models_store": models_store, "weightData": weightData }));
                console.log("file_content", file_content.length);
                downloadFile(model_name + ".js.runemodel", file_content);
            };

        };
    }



    async runRune(image) {
        this.input.data = image;
        console.log("running rune");
        console.log(this.runtime.exports._call());
        console.log(this.output);
        return JSON.stringify(this.output.data.slice(-1)[0]);
    }

    copyUint8Array(src) {
        var dst = new ArrayBuffer(src.byteLength);
        new Uint8Array(dst).set(new Uint8Array(src));
        return dst;
    }

    async loadManifest(bytes) {

        await this.loadRune();
        const model_name = "imagenet_mobilenet_v3";
        const portModel = false;
        if (portModel) {
            //convert model from assets to runeformat
            console.log(model_name);
            this.model = await tf.loadGraphModel('/imagenet_mobilenet_v3/model.json');
            await this.model.save('indexeddb://' + model_name);
            console.log('indexeddb://' + model_name);
            this.downloadModel(model_name, this.downloadModelFinal);
        } else {
            var view = new Uint8Array(bytes);
            this.wasm = await WebAssembly.compile(view.buffer);
            this.runtime = await this.rune.Runtime.load(this.wasm, this.trivialImports(this.input, this.output))
            console.log(this.runtime.getCapabilities());
            console.log(this.runtime.getParameters());
            console.log(this.runtime.getModels());
            //need to return capability here
            return JSON.stringify(this.runtime.parameters);
        }

    }

    trivialImports(input, output) {
        const capabilities = {
            raw: () => new RandomCapability(),
            image: () => new ImageCapability(input),
        };
        const serial = new SerialOutput(output);
        const outputs = {
            serial: () => serial,
        };

        return { capabilities, outputs };
    }


    async getKnownCapabilities() {
        await loadRune();
        return this.rune.KnownCapabilities;
    }
}

class ImageCapability {
    input;

    constructor(input) {
        this.input = input;
    }
    generate(dest) {
        console.log(this.input);
        dest.set(this.input.data[0], 0);
    }

    set(key, value) {
        console.log("Setting", key, value);
    }

}

class RandomCapability {
    generate(dest) {
        console.log("Generating raw");
        //const randomBytes = new Array(dest.length).map(() => Math.round(Math.random() * 255));
        const rand = (Math.random() - 0.5) * 2 * Math.PI;
        dest.set([122, 5, 62, 35]);
    }

    set(key, value) {
        console.log("Setting", key, value);
    }

}

class SerialOutput {
    calls;
    constructor(output) {
        this.calls = output.data;
    }


    consume(data) {
        const utf8 = new TextDecoder();
        this.calls.push(JSON.parse(utf8.decode(data)));
        console.log("consume:", JSON.parse(utf8.decode(data)));
    }

}

function downloadFile(filename, text) {
    var element = document.createElement('a');
    element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
    element.setAttribute('download', filename);

    element.style.display = 'none';
    document.body.appendChild(element);

    element.click();

    document.body.removeChild(element);
}

function readFile(file) {
    return new Promise(resolve => {
        var rawFile = new XMLHttpRequest();
        rawFile.overrideMimeType("application/json");
        rawFile.open("GET", file, true);
        rawFile.onreadystatechange = function () {
            if (rawFile.status == 200 && rawFile.readyState == 4) {
                resolve(rawFile.responseText);
            }
        }
        rawFile.send(null);
    });
}


function tflite(image) {

    var response = await fetch('/mobilenet.tflite');
    const mobilenet = new Uint8Array(await response.arrayBuffer());
    const tfliteModel = await tflite.loadTFLiteModel(
        mobilenet.buffer);

    const outputTensor = tf.tidy(() => {
        // Get pixels data from an image.
        //const img = tf.browser.fromPixels(document.querySelector('img'));
        // Normalize (might also do resize here if necessary).
        const input = Array.from(image[0]).map(function (element) {
            return element * 1.0 / 255;
        });//;tf.sub(tf.div(tf.expandDims(img), 127.5), 1);
        console.log(input);
        // Run the inference.
        console.log(tfliteModel);
        let outputTensor = tfliteModel.predict(tf.tensor3d(input, [image[1], image[2], 3]).expandDims(0));


        // De-normalize the result.
        return outputTensor.dataSync();
    });
}
