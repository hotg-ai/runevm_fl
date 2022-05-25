#include <rune.hpp>
#include <string>

class Runetime
{
private:
    rune::Runtime *runtime = NULL;
    rune::Metadata *inputs;
    rune::InputTensors *input_tensors;

    static void close_log_file(void *user_data)
    {
    }

public:
    rune::Logger logger;

    std::string
    run()
    {
        rune::Error *error = rune_runtime_predict(runtime);
        if (error)
        {
            const char *msg = rune::rune_error_to_string(error);
            rune::rune_error_free(error);
            return msg;
        }
        // reset input tensors
        rune::rune_input_tensors_free(input_tensors);
        input_tensors = rune_runtime_input_tensors(runtime);

        return getOutput();
    }

    void freeRuntime()
    {
        rune::rune_input_tensors_free(input_tensors);
        rune::rune_metadata_free(inputs);
        rune::rune_runtime_free(runtime);
    }

    void addInputTensor(int raw_node_id, uint8_t *input, uint32_t length, uint32_t *dimensions, int rank, int type)
    {
        size_t dimensionsUnsigned[rank];
        for (int i = 0; i < rank; i++)
        {
            dimensionsUnsigned[i] = *(dimensions + i);
        }
        rune::Tensor *raw_input = rune_input_tensors_insert(
            input_tensors,
            raw_node_id,
            rune::ElementType(type),
            dimensionsUnsigned,
            rank);
        uint8_t *raw_input_buffer = rune::rune_tensor_buffer(raw_input);
        memcpy(raw_input_buffer, input, length);
    }

    std::string load(rune::Config cfg)
    {
        if (runtime != NULL)
        {
            freeRuntime();
        }
        rune::Error *error = rune::rune_runtime_load(&cfg, &runtime);
        if (error)
        {
            const char *msg = rune::rune_error_to_string(error);
            rune::rune_error_free(error);
            return msg;
        }
        error = rune::rune_runtime_inputs(runtime, &inputs);
        if (error)
        {
            const char *msg = rune::rune_error_to_string(error);
            rune::rune_error_free(error);
            return msg;
        }
        input_tensors = rune_runtime_input_tensors(runtime);
        if (logger != NULL)
        {
            rune::rune_runtime_set_logger(runtime, logger, NULL, close_log_file);
        }

        return getManifest();
    }

    std::string getOutput()
    {
        rune::OutputTensors *outputs = rune::rune_runtime_output_tensors(runtime);

        std::string output = "[";
        const rune::OutputTensor *output_tensor;
        uint32_t output_id;

        printf("Reading outputs:\n");
        bool first = true;
        while (rune::rune_output_tensors_next(outputs, &output_id, &output_tensor))
        {
            if (!first)
            {
                output.append(std::string(","));
            }
            first = false;

            const rune::Tensor *fixed = rune::rune_output_tensor_as_fixed(output_tensor);

            output.append(std::string("{"));
            output.append(std::string("\"output_id\":") + std::to_string(output_id) + std::string(","));
            if (!fixed)
            {
                // string tensor
                const rune::StringTensor *variable = rune::rune_output_tensor_as_string_tensor(output_tensor);
                size_t rank = rune::rune_string_tensor_rank(variable);
                const size_t *dimensions = rune::rune_string_tensor_dimensions(variable);
                output.append(std::string("\"rank\":") + std::to_string(rank) + std::string(","));
                output.append(std::string("\"element_type\":\"UTF8\"") + std::string(","));
                output.append(std::string("\"dimensions\":["));
                int length = 1;
                for (int i = 0; i < rank; i++)
                {
                    if (i > 0)
                    {
                        output.append(std::string(","));
                    }
                    length *= dimensions[i];
                    output.append(std::to_string(dimensions[i]));
                    // output.append(std::string(">>>> dimensions:") + std::to_string(i) + std::string(" dimensions:") + std::to_string(dimensions[i]));
                }
                output.append(std::string("]") + std::string(","));
                output.append(std::string("\"size\":") + std::to_string(length) + std::string(","));
                output.append(std::string("\"output\":["));

                for (int i = 0; i < length; i++)
                {
                    // comma sep
                    if (i > 0)
                    {
                        output.append(std::string(","));
                    }
                    const unsigned char *pointer;
                    int strlength = rune::rune_string_tensor_get_by_index(variable, i, &pointer);

                    const std::string_view text{reinterpret_cast<const char *>(pointer), static_cast<size_t>(strlength)};
                    output.append(std::string("\"") + std::string{text} + std::string("\""));
                }
                output.append(std::string("]"));
            }
            else
            {
                // fixed tensor
                rune::ElementType element_type = rune::rune_tensor_element_type(fixed);
                size_t rank = rune::rune_tensor_rank(fixed);
                const size_t *dimensions = rune::rune_tensor_dimensions(fixed);
                // uint8_t output = *(uint8_t *)rune::rune_tensor_buffer_readonly(fixed);

                output.append(std::string("\"rank\":") + std::to_string(rank) + std::string(","));
                output.append(std::string("\"element_type\":") + std::to_string(rune::ElementType(element_type)) + std::string(","));
                output.append(std::string("\"dimensions\":["));
                int length = 1;
                for (int i = 0; i < rank; i++)
                {
                    if (i > 0)
                    {
                        output.append(std::string(","));
                    }
                    length *= dimensions[i];
                    output.append(std::to_string(dimensions[i]));
                    // output.append(std::string(">>>> dimensions:") + std::to_string(i) + std::string(" dimensions:") + std::to_string(dimensions[i]));
                }
                output.append(std::string("]") + std::string(","));
                output.append(std::string("\"size\":") + std::to_string(length) + std::string(","));
                output.append(std::string("\"output\":["));

                for (int i = 0; i < length; i++)
                {
                    // comma sep
                    if (i > 0)
                    {
                        output.append(std::string(","));
                    }
                    // check element

                    if (element_type == rune::U8)
                    {
                        uint8_t *value = (uint8_t *)(rune::rune_tensor_buffer_readonly(fixed) + i * sizeof(uint8_t));
                        output.append(std::to_string(*value));
                    }
                    if (element_type == rune::I8)
                    {
                        int8_t *value = (int8_t *)(rune::rune_tensor_buffer_readonly(fixed) + i * sizeof(int8_t));
                        output.append(std::to_string(*value));
                    }
                    if (element_type == rune::U16)
                    {
                        uint16_t *value = (uint16_t *)(rune::rune_tensor_buffer_readonly(fixed) + i * sizeof(uint16_t));
                        output.append(std::to_string(*value));
                    }
                    if (element_type == rune::I16)
                    {
                        int16_t *value = (int16_t *)(rune::rune_tensor_buffer_readonly(fixed) + i * sizeof(int16_t));
                        output.append(std::to_string(*value));
                    }
                    if (element_type == rune::U32)
                    {
                        uint32_t *value = (uint32_t *)(rune::rune_tensor_buffer_readonly(fixed) + i * sizeof(uint32_t));
                        output.append(std::to_string(*value));
                    }
                    if (element_type == rune::F32)
                    {
                        float *value = (float *)(rune::rune_tensor_buffer_readonly(fixed) + i * sizeof(float));
                        output.append(std::to_string(*value));
                    }
                    if (element_type == rune::U64)
                    {
                        uint64_t *value = (uint64_t *)(rune::rune_tensor_buffer_readonly(fixed) + i * sizeof(uint64_t));
                        output.append(std::to_string(*value));
                    }
                    if (element_type == rune::F64)
                    {
                        double *value = (double *)(rune::rune_tensor_buffer_readonly(fixed) + i * sizeof(double));
                        output.append(std::to_string(*value));
                    }
                }
                output.append(std::string("]"));
            }

            output.append(std::string("}"));
        }
        output.append(std::string("]"));
        rune::rune_output_tensors_free(outputs);
        return output;
    }
    std::string getManifest()
    {
        std::string output = "[";
        for (int i = 0; i < rune::rune_metadata_node_count(inputs); i++)
        {
            if (i > 0)
            {
                output.append(std::string(","));
            }
            const rune::Node *node = rune::rune_metadata_get_node(inputs, i);
            uint32_t id = rune::rune_node_id(node);
            const char *kind = rune::rune_node_kind(node);
            output.append(std::string("{\"kind\":\"") + std::string(kind) + std::string("\",\"id\":") + std::to_string(id) + std::string(",\"args\":{"));
            for (int arg_no = 0; arg_no < rune::rune_node_argument_count(node); arg_no++)
            {
                if (arg_no > 0)
                {
                    output.append(std::string(","));
                }
                const char *name = rune::rune_node_get_argument_name(node, arg_no);
                const char *value = rune::rune_node_get_argument_value(node, arg_no);
                output.append(std::string("\"") + std::string(name) + std::string("\":\"") + std::string(value) + std::string("\""));
            }
            output.append(std::string("}}"));
        }
        output.append(std::string("]"));
        return output;
    }
};
