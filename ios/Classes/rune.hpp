#pragma once

/* Generated with cbindgen:0.20.0 */

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#ifdef __cplusplus
namespace rune {
#endif // __cplusplus

/**
 * The type of value that may be stored in a [`Tensor`].
 */
enum ElementType
#ifdef __cplusplus
  : uint32_t
#endif // __cplusplus
 {
  U8,
  I8,
  U16,
  I16,
  U32,
  I32,
  F32,
  U64,
  I64,
  F64,
};
#ifndef __cplusplus
typedef uint32_t ElementType;
#endif // __cplusplus

enum ErrorKind
#ifdef __cplusplus
  : uint32_t
#endif // __cplusplus
 {
  /**
   * An unidentified error.
   */
  Other = 0,
  /**
   * The WebAssembly isn't valid.
   *
   * This typically happens when the WebAssembly failed validation or isn't
   * actually WebAssembly.
   */
  InvalidWebAssembly = 1,
  /**
   * There was an issue resolving imports.
   *
   * This typically occurs when the Rune is expecting different host
   * functions or some of those functions have different signatures.
   */
  BadImports = 2,
  /**
   * The call into WebAssembly raised an error.
   */
  CallFailed = 3,
};
#ifndef __cplusplus
typedef uint32_t ErrorKind;
#endif // __cplusplus

/**
 * An error that may be returned by the Rune native library.
 *
 * # Error Handling
 *
 * Fallible functions will return a `*mut Error` which *must* be checked before
 * continuing.
 *
 * This might look like...
 *
 * ```cpp
 * Runtime *runtime;
 * Config cfg = {...};
 *
 * Error *error = rune_runtime_load(&cfg, &runtime);
 *
 * if (error) {
 *     const char *msg = rune_error_to_string(error);
 *
 *     printf("Unable to load the Rune: %s\n", msg);
 *
 *     free(msg);
 *     rune_error_free(error);
 *     exit(1);
 * }
 * ```
 *
 * Additional "return" values are returned via output parameters (typically
 * named `xxx_out`). If an error occurs, the state of the output parameter is
 * unspecified, otherwise it is guaranteed to be in a valid state.
 *
 * If an error is present, it is the caller's responsibility to free it
 * afterwards.
 */
typedef struct Error Error;

/**
 * A dictionary mapping input node IDs to the tensor that will be passed into
 * the Rune.
 *
 * # Safety
 *
 * This value must not outlive the `Runtime` it came from. The `Runtime` also
 * shouldn't be used while these `InputTensors` are alive.
 */
typedef struct InputTensors InputTensors;

/**
 * Metadata for a set of nodes in the ML pipeline.
 */
typedef struct Metadata Metadata;

/**
 * Metadata for a single node.
 */
typedef struct Node Node;

typedef struct OutputTensor OutputTensor;

/**
 * An iterator over each of the tensors returned by the Rune.
 *
 * # Safety
 *
 * This directly refers to data structures inside the `Runtime`. Any use of
 * the `Runtime` while this reference is alive may invalidate it, causing
 * undefined behaviour.
 */
typedef struct OutputTensors OutputTensors;

/**
 * A loaded Rune.
 */
typedef struct Runtime Runtime;

/**
 * A wrapper around a tensor containing dynamically sized elements (i.e.
 * strings).
 *
 * # Note
 *
 * Users must free this object once they are done with it.
 *
 * # Safety
 *
 * This inherits all the safety requirements from `OutputTensors`, with the
 * added condition that you must not mutate the tensor's data through this
 * pointer.
 */
typedef struct StringTensor StringTensor;

/**
 * A n-dimension array of numbers.
 */
typedef struct Tensor Tensor;

/**
 * Data used when loading a Rune.
 */
typedef struct Config {
  const uint8_t *rune;
  int rune_len;
} Config;

typedef void (*Logger)(void*, const char*, int);

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

/**
 * Create a new `Error` with the provided error message.
 *
 * It is the caller's responsibility to free the `Error` using
 * `rune_error_free()` once they are done with it.
 */
struct Error *rune_error_new(const char *msg, int len);

/**
 * Get a simple, oneline message describing the error.
 *
 * Note: It is the caller's responsibility to free this string afterwards.
 */
char *rune_error_to_string(const struct Error *e);

/**
 * Print the error, plus any errors that may have caused it.
 *
 * If the `RUST_BACKTRACE` environment variable is set, this will also include
 * a backtrace from where the error was first created.
 *
 * Note: It is the caller's responsibility to free this string afterwards.
 */
char *rune_error_to_string_verbose(const struct Error *e);

/**
 * Free an error once you are done with it.
 *
 * Note: Freeing the same `Error` twice is an error and may cause a crash at
 * runtime.
 */
void rune_error_free(struct Error *e);

/**
 * Programmatically find out what kind of error this is.
 */
ErrorKind rune_error_kind(const struct Error *e);

void rune_input_tensors_free(struct InputTensors *tensors);

int rune_input_tensor_count(const struct InputTensors *tensors);

struct Tensor *rune_input_tensors_get(struct InputTensors *tensors, uint32_t node_id);

/**
 * Add a new tensor to this set of input tensors, returning a pointer to the
 * newly created tensor.
 *
 * If a tensor has already been declared for this node, it will be overwritten.
 *
 * This function may return `null` if the dimensions array contains a zero or
 * `tensors` is a null pointer.
 */
struct Tensor *rune_input_tensors_insert(struct InputTensors *tensors,
                                         uint32_t node_id,
                                         ElementType element_type,
                                         const uintptr_t *dimensions,
                                         int rank);

ElementType rune_tensor_element_type(const struct Tensor *tensor);

int rune_tensor_rank(const struct Tensor *tensor);

const uintptr_t *rune_tensor_dimensions(const struct Tensor *tensor);

int rune_tensor_buffer_len(const struct Tensor *tensor);

uint8_t *rune_tensor_buffer(struct Tensor *tensor);

/**
 * Get a readonly reference to this `Tensor`'s buffer.
 */
const uint8_t *rune_tensor_buffer_readonly(const struct Tensor *tensor);

/**
 * Free a `Metadata` when you are done with it.
 */
void rune_metadata_free(struct Metadata *meta);

/**
 * Get metadata for a specific node, returning `null` if the node doesn't
 * exist.
 *
 * # Safety
 *
 * The returned pointer can't outlive the `Metadata` it came from.
 */
const struct Node *rune_metadata_get_node(const struct Metadata *meta, int index);

/**
 * How many nodes does this set of `Metadata` contain?
 */
int rune_metadata_node_count(const struct Metadata *meta);

/**
 * Get the ID for this particular node.
 */
uint32_t rune_node_id(const struct Node *node);

/**
 * Which kind of node is this?
 *
 * Some examples are `"RAW"` or `"IMAGE"`.
 *
 * # Safety
 *
 * The returned pointer can't outlive the `Metadata` it came from.
 */
const char *rune_node_kind(const struct Node *node);

/**
 * How many arguments have been passed to this node?
 */
int rune_node_argument_count(const struct Node *node);

/**
 * Get the name for a particular argument, or `null` if that argument doesn't
 * exist.
 */
const char *rune_node_get_argument_name(const struct Node *node, int index);

/**
 * Get the value for a particular argument, or `null` if that argument doesn't
 * exist.
 */
const char *rune_node_get_argument_value(const struct Node *node, int index);

void rune_output_tensors_free(struct OutputTensors *tensors);

/**
 * Ask the `OutputTensors` iterator for the next `OutputTensor` and the ID of
 * the node it came from.
 *
 * This will return `false` if you have reached the end of the iterator.
 */
bool rune_output_tensors_next(struct OutputTensors *tensors,
                              uint32_t *id_out,
                              const struct OutputTensor **tensor_out);

/**
 * Get a reference to the underlying `Tensor` if this output tensor has a fixed
 * size.
 *
 * This will return `null` if the `OutputTensor` contains dynamically sized
 * data (i.e. strings) or if the `tensor` parameter is `null`.
 *
 * # Safety
 *
 * This inherits all the safety requirements from `OutputTensors`, with the
 * added condition that you must not mutate the tensor's data through this
 * pointer.
 */
const struct Tensor *rune_output_tensor_as_fixed(const struct OutputTensor *tensor);

const struct StringTensor *rune_output_tensor_as_string_tensor(const struct OutputTensor *tensor);

/**
 * Get the number of dimensions in this `StringTensor`.
 */
uintptr_t rune_string_tensor_rank(const struct StringTensor *tensor);

/**
 * Get a pointer to this `StringTensor`'s dimensions.
 */
const uintptr_t *rune_string_tensor_dimensions(const struct StringTensor *tensor);

void rune_string_tensor_free(const struct StringTensor *tensor);

/**
 * Get a pointer to the string at a specific index in the `StringTensor`'s
 * backing array, returning its length in bytes and setting `string_out` if
 * that string exists.
 *
 * If the index is out of bounds, this function returns `0` and sets
 * `string_out` to `null`.
 */
int rune_string_tensor_get_by_index(const struct StringTensor *tensor,
                                    uintptr_t index,
                                    const uint8_t **string_out);

void rune_runtime_free(struct Runtime *runtime);

/**
 * Execute the rune, reading from the input tensors that were provided and
 * writing to the output tensors.
 */
__attribute__((warn_unused_result)) struct Error *rune_runtime_predict(struct Runtime *runtime);

/**
 * Get a set of all the input nodes in this Rune.
 */
__attribute__((warn_unused_result))
struct Error *rune_runtime_inputs(const struct Runtime *runtime,
                                  struct Metadata **metadata_out);

/**
 * Get a set of all the output nodes in this Rune.
 */
__attribute__((warn_unused_result))
struct Error *rune_runtime_outputs(const struct Runtime *runtime,
                                   struct Metadata **metadata_out);

__attribute__((warn_unused_result))
struct InputTensors *rune_runtime_input_tensors(struct Runtime *runtime);

/**
 * Get a reference to the tensors associated with each output node.
 *
 * This will return `null` if `runtime` is `null`.
 *
 * # Safety
 *
 * This reference points directly into the runtime's internals, so any use of
 * the runtime while this reference is alive may invalidate it.
 */
__attribute__((warn_unused_result))
struct OutputTensors *rune_runtime_output_tensors(struct Runtime *runtime);

__attribute__((warn_unused_result))
struct Error *rune_runtime_load(const struct Config *cfg,
                                struct Runtime **runtime_out);

void rune_runtime_set_logger(struct Runtime *runtime,
                             Logger logger,
                             void *user_data,
                             void (*destructor)(void*));

#ifdef __cplusplus
} // extern "C"
#endif // __cplusplus

#ifdef __cplusplus
} // namespace rune
#endif // __cplusplus
