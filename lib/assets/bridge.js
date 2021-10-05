
let output;

class ImageCapability {
    parameters = {};
    manifest;
    data;
    cap_id = 0;
    constructor(cap_id,manifest,data) {
        this.manifest = manifest;
        this.cap_id = cap_id;
        this.data = data;
    }
    generate(dest,id) {
        dest.set(this.data.inputs[this.cap_id], 0);
    }
    setParameter(key, value) {
        this.parameters[key] = value;
        if(this.manifest.length<=this.cap_id) {
            this.manifest[this.cap_id]={"type":"ImageCapability"};
        }
        this.manifest[this.cap_id][key] = value;
    }
 }

class SerialOutput {
    consume(data) {
        const utf8 = new TextDecoder();
        output=JSON.parse(utf8.decode(data));
    }
}

class Bridge {
    runtime;
    data;
    cap_count=0;
    manifest = [];
    constructor() {
        this.data = [{ "inputs": [],  "outputs": [] }];
        console.log("bridge loaded");
    }
    
    async call(bytes,lengths) {
        this.data.inputs=[];
        var pos=0;
        for(var i = 0;i<lengths.length;i++) {
            this.data.inputs[i]=bytes.subarray(pos, lengths[i]+pos);
            pos+=lengths[i];
        }
        await this.runtime.call();
        if(output.type_name=="f32") {
            return output.elements;
        }
        return JSON.stringify(output);
    }

    async load(bytes) {
        this.cap_count = 0;
        this.manifest = [];
        const imports = {
            createCapability: () => new ImageCapability(this.cap_count++,this.manifest,this.data),
            createOutput: () => new SerialOutput(),
            createModel: (mime, model_data) => rune.TensorFlowModel.loadTensorFlowLite(model_data),
            log: (log) => { console.log(log) },
        };
        var view = new Uint8Array(bytes);
        this.runtime=await rune.Runtime.load(view.buffer,imports);
        return JSON.stringify(this.manifest);
    }
}

bridge = new Bridge();