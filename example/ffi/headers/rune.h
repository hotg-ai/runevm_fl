/** \file
 * rune-native v0.1.0

 * Authors: The Rune Developers
 * License: MIT OR Apache 2.0
 * Commit: 6ca6011dd00bb009f6c3ff735614f27c522aeb28
 * Compiler: rustc 1.54.0-nightly (1c6868aa2 2021-05-27)
 * Enabled Features: default, rune-wasmer-runtime, tflite, wasmer-runtime
 *
 * Native bindings to the `rune` project.
 */

#ifndef _RUST_RUNE_NATIVE_
#define _RUST_RUNE_NATIVE_

#ifdef __cplusplus
extern "C" {
#endif

typedef struct IntegerOrErrorResult IntegerOrErrorResult_t;

#include <stdbool.h>

/** \brief
 * Check if the result contains a `usize`.
 */
bool rune_result_IntegerOrErrorResult_is_ok(
    IntegerOrErrorResult_t const *result);

/** \brief
 * Check if the result contains a `BoxedError`.
 */
bool rune_result_IntegerOrErrorResult_is_err(
    IntegerOrErrorResult_t const *result);

/** \brief
 * Free the `IntegerOrErrorResult` after you are done with it.
 */
void rune_result_IntegerOrErrorResult_free(IntegerOrErrorResult_t *result);

#include <stddef.h>
#include <stdint.h>

/** \brief
 * Get a reference to the `usize` in this `IntegerOrErrorResult`, or `null` if
 * not present.
 */
size_t const *
rune_result_IntegerOrErrorResult_get_ok(IntegerOrErrorResult_t const *result);

typedef struct Error Error_t;

/** \brief
 * Get a reference to the `BoxedError` in this `IntegerOrErrorResult`, or `null`
 * if not present.
 */
Error_t *const *
rune_result_IntegerOrErrorResult_get_err(IntegerOrErrorResult_t const *result);

/** \brief
 * Extract the `usize`, freeing the `IntegerOrErrorResult` and crashing if it
 * actually contains a `BoxedError`.
 */
size_t rune_result_IntegerOrErrorResult_take_ok(IntegerOrErrorResult_t *result);

/** \brief
 * Extract the `BoxedError`, freeing the `IntegerOrErrorResult` and crashing if
 * it actually contains a `usize`.
 */
Error_t *
rune_result_IntegerOrErrorResult_take_err(IntegerOrErrorResult_t *result);

typedef struct CapabilityResult CapabilityResult_t;

/** \brief
 * Check if the result contains a `BoxedCapability`.
 */
bool rune_result_CapabilityResult_is_ok(CapabilityResult_t const *result);

/** \brief
 * Check if the result contains a `BoxedError`.
 */
bool rune_result_CapabilityResult_is_err(CapabilityResult_t const *result);

/** \brief
 * Free the `CapabilityResult` after you are done with it.
 */
void rune_result_CapabilityResult_free(CapabilityResult_t *result);

/** \brief
 *  Like [`slice_ref`] and [`slice_mut`], but with any lifetime attached
 *  whatsoever.
 *
 *  It is only intended to be used as the parameter of a **callback** that
 *  locally borrows it, due to limitations of the [`ReprC`][
 *  `trait@crate::layout::ReprC`] design _w.r.t._ higher-rank trait bounds.
 *
 *  # C layout (for some given type T)
 *
 *  ```c
 *  typedef struct {
 *      // Cannot be NULL
 *      T * ptr;
 *      size_t len;
 *  } slice_T;
 *  ```
 *
 *  # Nullable pointer?
 *
 *  If you want to support the above typedef, but where the `ptr` field is
 *  allowed to be `NULL` (with the contents of `len` then being undefined)
 *  use the `Option< slice_ptr<_> >` type.
 */
typedef struct {

  uint8_t *ptr;

  size_t len;

} slice_raw_uint8_t;

typedef struct {

  void *user_data;

  void (*set_parameter)(void *);

  IntegerOrErrorResult_t (*generate)(void *, slice_raw_uint8_t);

  void (*free)(void *);

} Capability_t;

/** \brief
 * Get a reference to the `BoxedCapability` in this `CapabilityResult`, or
 * `null` if not present.
 */
Capability_t *const *
rune_result_CapabilityResult_get_ok(CapabilityResult_t const *result);

/** \brief
 * Get a reference to the `BoxedError` in this `CapabilityResult`, or `null` if
 * not present.
 */
Error_t *const *
rune_result_CapabilityResult_get_err(CapabilityResult_t const *result);

/** \brief
 * Extract the `BoxedCapability`, freeing the `CapabilityResult` and crashing if
 * it actually contains a `BoxedError`.
 */
Capability_t *rune_result_CapabilityResult_take_ok(CapabilityResult_t *result);

/** \brief
 * Extract the `BoxedError`, freeing the `CapabilityResult` and crashing if it
 * actually contains a `BoxedCapability`.
 */
Error_t *rune_result_CapabilityResult_take_err(CapabilityResult_t *result);

typedef struct RunicosBaseImage RunicosBaseImage_t;

RunicosBaseImage_t *rune_image_new(void);

void rune_image_free(RunicosBaseImage_t *image);

typedef struct RuneResult RuneResult_t;

/** \remark Has the same ABI as `uint32_t` **/
#ifdef DOXYGEN
typedef enum LogLevel
#else
typedef uint32_t LogLevel_t;
enum
#endif
{
  /** \brief
   *  The "error" level.
   *
   *  Designates very serious errors.
   */
  LOG_LEVEL_ERROR = 1,
  /** \brief
   *  The "warn" level.
   *
   *  Designates hazardous situations.
   */
  LOG_LEVEL_WARN,
  /** \brief
   *  The "info" level.
   *
   *  Designates useful information.
   */
  LOG_LEVEL_INFO,
  /** \brief
   *  The "debug" level.
   *
   *  Designates lower priority information.
   */
  LOG_LEVEL_DEBUG,
  /** \brief
   *  The "trace" level.
   *
   *  Designates very low priority, often extremely verbose, information.
   */
  LOG_LEVEL_TRACE,
}
#ifdef DOXYGEN
LogLevel_t
#endif
    ;

typedef struct {

  LogLevel_t level;

  slice_raw_uint8_t target;

  char *message;

} LogRecord_t;

typedef struct {

  void *env_ptr;

  RuneResult_t *(*call)(void *, LogRecord_t);

  void (*free)(void *);

} BoxDynFnMut1_RuneResult_ptr_LogRecord_t;

/** \brief
 *  Set the closure to be called when the Rune emits log messages.
 */
void rune_image_set_log(RunicosBaseImage_t *image,
                        BoxDynFnMut1_RuneResult_ptr_LogRecord_t log);

typedef struct {

  void *env_ptr;

  CapabilityResult_t *(*call)(void *);

  void (*free)(void *);

} BoxDynFnMut0_CapabilityResult_ptr_t;

void rune_image_set_raw(RunicosBaseImage_t *image,
                        BoxDynFnMut0_CapabilityResult_ptr_t raw);

char const *rune_log_level_name(LogLevel_t level);

typedef struct WasmerRuntimeResult WasmerRuntimeResult_t;

/** \brief
 * Check if the result contains a `BoxedWasmerRuntime`.
 */
bool rune_result_WasmerRuntimeResult_is_ok(WasmerRuntimeResult_t const *result);

/** \brief
 * Check if the result contains a `BoxedError`.
 */
bool rune_result_WasmerRuntimeResult_is_err(
    WasmerRuntimeResult_t const *result);

/** \brief
 * Free the `WasmerRuntimeResult` after you are done with it.
 */
void rune_result_WasmerRuntimeResult_free(WasmerRuntimeResult_t *result);

typedef struct WasmerRuntime WasmerRuntime_t;

/** \brief
 * Get a reference to the `BoxedWasmerRuntime` in this `WasmerRuntimeResult`, or
 * `null` if not present.
 */
WasmerRuntime_t *const *
rune_result_WasmerRuntimeResult_get_ok(WasmerRuntimeResult_t const *result);

/** \brief
 * Get a reference to the `BoxedError` in this `WasmerRuntimeResult`, or `null`
 * if not present.
 */
Error_t *const *
rune_result_WasmerRuntimeResult_get_err(WasmerRuntimeResult_t const *result);

/** \brief
 * Extract the `BoxedWasmerRuntime`, freeing the `WasmerRuntimeResult` and
 * crashing if it actually contains a `BoxedError`.
 */
WasmerRuntime_t *
rune_result_WasmerRuntimeResult_take_ok(WasmerRuntimeResult_t *result);

/** \brief
 * Extract the `BoxedError`, freeing the `WasmerRuntimeResult` and crashing if
 * it actually contains a `BoxedWasmerRuntime`.
 */
Error_t *
rune_result_WasmerRuntimeResult_take_err(WasmerRuntimeResult_t *result);

/** \brief
 *  `&'lt [T]` but with a guaranteed `#[repr(C)]` layout.
 *
 *  # C layout (for some given type T)
 *
 *  ```c
 *  typedef struct {
 *      // Cannot be NULL
 *      T * ptr;
 *      size_t len;
 *  } slice_T;
 *  ```
 *
 *  # Nullable pointer?
 *
 *  If you want to support the above typedef, but where the `ptr` field is
 *  allowed to be `NULL` (with the contents of `len` then being undefined)
 *  use the `Option< slice_ptr<_> >` type.
 */
typedef struct {

  uint8_t const *ptr;

  size_t len;

} slice_ref_uint8_t;

/** \brief
 *  Load a Rune backed by the provided image.
 *
 *  If loading is successful, `runtime_out` will be set to a new `WasmerRuntime`
 *  instance, otherwise an error is returned.
 */
WasmerRuntimeResult_t *rune_wasmer_runtime_load(slice_ref_uint8_t rune,
                                                RunicosBaseImage_t *image);

/** \brief
 *  Free a `WasmerRuntime` once you are done with it.
 */
void rune_wasmer_runtime_free(WasmerRuntime_t *runtime);

/** \brief
 *  Evaluate the Rune pipeline.
 */
RuneResult_t *rune_wasmer_runtime_call(WasmerRuntime_t *runtime);

/** \brief
 *  Construct a new error.
 */
Error_t *rune_error_new(char const *msg);

/** \brief
 *  Free the error once you are done with it.
 */
void rune_error_free(Error_t *e);

/** \brief
 *  Return a newly allocated string containing the error's backtrace.
 */
char *rune_error_backtrace(Error_t const *error);

/** \brief
 *  Return a newly allocated string describing the error.
 */
char *rune_error_to_string(Error_t const *error);

/** \brief
 *  Return a newly allocated string describing the error and any errors that
 *  may have caused it.
 *
 *  This will also contain a backtrace if the `RUST_BACKTRACE` environment
 *  variable is set.
 */
char *rune_error_to_string_verbose(Error_t const *error);

/** \brief
 * Check if the result contains a `u8`.
 */
bool rune_result_RuneResult_is_ok(RuneResult_t const *result);

/** \brief
 * Check if the result contains a `BoxedError`.
 */
bool rune_result_RuneResult_is_err(RuneResult_t const *result);

/** \brief
 * Free the `RuneResult` after you are done with it.
 */
void rune_result_RuneResult_free(RuneResult_t *result);

/** \brief
 * Get a reference to the `u8` in this `RuneResult`, or `null` if not present.
 */
uint8_t const *rune_result_RuneResult_get_ok(RuneResult_t const *result);

/** \brief
 * Get a reference to the `BoxedError` in this `RuneResult`, or `null` if not
 * present.
 */
Error_t *const *rune_result_RuneResult_get_err(RuneResult_t const *result);

/** \brief
 * Extract the `u8`, freeing the `RuneResult` and crashing if it actually
 * contains a `BoxedError`.
 */
uint8_t rune_result_RuneResult_take_ok(RuneResult_t *result);

/** \brief
 * Extract the `BoxedError`, freeing the `RuneResult` and crashing if it
 * actually contains a `u8`.
 */
Error_t *rune_result_RuneResult_take_err(RuneResult_t *result);

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* _RUST_RUNE_NATIVE_ */
