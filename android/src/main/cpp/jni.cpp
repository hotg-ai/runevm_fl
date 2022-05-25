//
//  Wasm3 - high performance WebAssembly interpreter written in C.
//
//  Copyright © 2019 Steven Massey, Volodymyr Shymanskyy.
//  All rights reserved.
//

#include <memory>
#include <jni.h>
#include <optional>
#include <android/log.h>
#include <rune.hpp>
#include <runetime.cpp>
#include <vector>
namespace
{
    struct Deleter
    {
        Deleter(JNIEnv *env, jbyteArray jdata)
            : m_env(env), m_jdata(jdata) {}

        void operator()(jbyte *ptr) const
        {
            m_env->ReleaseByteArrayElements(m_jdata, ptr, JNI_ABORT);
        }

    private:
        JNIEnv *m_env;
        jbyteArray m_jdata;
    };

    struct JByteArrayData
    {
        JByteArrayData(std::unique_ptr<jbyte, Deleter> &&data, uint32_t size)
            : m_data(std::move(data)), m_size(size) {}

        uint8_t *data() const noexcept
        {
            return reinterpret_cast<uint8_t *>(m_data.get());
        }

        uint32_t size() const noexcept
        {
            return m_size;
        }

    private:
        std::unique_ptr<jbyte, Deleter> m_data;
        uint32_t m_size;
    };

    std::optional<JByteArrayData> getDataFromJArray(JNIEnv *env, jbyteArray jdata)
    {
        auto data = std::unique_ptr<jbyte, Deleter>(
            env->GetByteArrayElements(jdata, 0),
            Deleter(env, jdata));
        if (!data)
            return std::nullopt;

        const auto size = env->GetArrayLength(jdata);
        if (size < 0)
            return std::nullopt;

        return JByteArrayData(std::move(data), size);
    }

}

extern "C"
{

    Runetime runetime;
    std::string logs = "";
    void logger(void *user_data, const char *msg, int len)
    {
        __android_log_print(ANDROID_LOG_DEBUG, "LOG_TAG", "[Rune Logger] %s", msg);
        if (logs.length() > 0)
        {
            logs = logs + ",";
        }
        const std::string_view text{reinterpret_cast<const char *>(msg), static_cast<size_t>(len)};
        logs = logs + std::string{text};
    }

    JNIEXPORT jstring JNICALL
    Java_ai_hotg_runevm_1fl_RunevmFlPlugin_getLogs(JNIEnv *env, jobject thiz)
    {
        std::string log_output = "[" + logs + "]";
        logs = "";
        return env->NewStringUTF(log_output.c_str());
    }
    JNIEXPORT jint JNICALL
    JNI_OnLoad(JavaVM *vm, void *reserved)
    {
        auto jniEnv = (JNIEnv *)nullptr;

        if (vm->GetEnv((void **)&jniEnv, JNI_VERSION_1_6) != JNI_OK)
        {
            return JNI_ERR; // JNI version not supported
        }

        runetime.logger = &logger;

        return JNI_VERSION_1_6;
    }

    JNIEXPORT jstring JNICALL
    Java_ai_hotg_runevm_1fl_RunevmFlPlugin_getManifest(JNIEnv *env, jobject thiz, jbyteArray wasm)
    {

        const auto optData = getDataFromJArray(env, wasm);
        if (!optData)
            return NULL;

        struct rune::Config cfg = {
            .rune = optData->data(),
            .rune_len = (int)optData->size(),
        };

        std::string result = runetime.load(cfg);

        return env->NewStringUTF(result.c_str());
    }

    JNIEXPORT jboolean JNICALL
    Java_ai_hotg_runevm_1fl_RunevmFlPlugin_addInputTensor(JNIEnv *env, jobject thiz, jint node_id, jbyteArray input, jint type, jintArray dimensions, jint rank)
    {

        const auto bytesArray = getDataFromJArray(env, input);
        if (!bytesArray)
            return NULL;
        const uint8_t *bytes = bytesArray->data();
        jint length = bytesArray->size();
        jint *dimensionsArray = env->GetIntArrayElements(dimensions, 0);
        runetime.addInputTensor(node_id, bytesArray->data(), length, (uint32_t *)dimensionsArray, rank, type);
        return true;
    }

    JNIEXPORT jstring JNICALL
    Java_ai_hotg_runevm_1fl_RunevmFlPlugin_runRune(JNIEnv *env, jobject thiz)
    {
        std::string result = runetime.run();
        __android_log_print(ANDROID_LOG_DEBUG, "LOG_TAG", "INFERENCE OUTPUT %s", result.c_str());

        return env->NewStringUTF(result.c_str());
    }
}