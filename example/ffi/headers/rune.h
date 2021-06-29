/** \file
 * rune-native v0.1.0

 * Authors: The Rune Developers
 * License: MIT OR Apache 2.0
 * Commit: db0ba625551e30f4a46fb7d6b3765e7bd17a6937
 * Compiler: rustc 1.54.0-nightly (1c6868aa2 2021-05-27)
 * Enabled Features: default, rune-wasmer-runtime, tflite, wasmer-runtime
 *
 * Native bindings to the `rune` project.
 */

#ifndef _RUST_RUNE_NATIVE_
#define _RUST_RUNE_NATIVE_

#ifdef __cplusplus
extern "C"
{
#endif

  typedef struct Error Error_t;

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

#include <stddef.h>
#include <stdint.h>

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

  typedef struct
  {

    uint8_t const *ptr;

    size_t len;

  } slice_ref_uint8_t;

  typedef struct RunicosBaseImage RunicosBaseImage_t;

/** \remark Has the same ABI as `uint8_t` **/
#ifdef DOXYGEN
  typedef enum ResultTag
#else
typedef uint8_t ResultTag_t;
enum
#endif
  {
    /** . */
    RESULT_TAG_OK = 0,
    /** . */
    RESULT_TAG_ERR = 1,
  }
#ifdef DOXYGEN
  ResultTag_t
#endif
      ;

  typedef struct WasmerRuntime WasmerRuntime_t;

  typedef struct
  {
    ResultTag_t tag;
    WasmerRuntime_t *value;
  } Ok_WasmerRuntime_ptr_t;
  typedef struct
  {
    ResultTag_t tag;
    Error_t *error;
  } Err_Error_ptr_t;
  /** A type which is guaranteed to be identical to `Result<T, E>`.
 *
 * When initializing the `Result_WasmerRuntime_ptr_Error_ptr_t`, make sure to
 * use the correct tag.
 */
  typedef union
  {
    Ok_WasmerRuntime_ptr_t ok;
    Err_Error_ptr_t err;
  } Result_WasmerRuntime_ptr_Error_ptr_t;
  /** \brief
 *  Load a Rune backed by the provided image.
 *
 *  If loading is successful, `runtime_out` will be set to a new `WasmerRuntime`
 *  instance, otherwise an error is returned.
 */
  Result_WasmerRuntime_ptr_Error_ptr_t
  rune_wasmer_runtime_load(slice_ref_uint8_t rune, RunicosBaseImage_t *image);

  /** \brief
 *  Free a `WasmerRuntime` once you are done with it.
 */
  void rune_wasmer_runtime_free(WasmerRuntime_t *runtime);

  typedef struct
  {
    ResultTag_t tag;
    uint8_t value;
  } Ok_uint8_t;
  /** A type which is guaranteed to be identical to `Result<T, E>`.
 *
 * When initializing the `Result_uint8_Error_ptr_t`, make sure to use the
 * correct tag.
 */
  typedef union
  {
    Ok_uint8_t ok;
    Err_Error_ptr_t err;
  } Result_uint8_Error_ptr_t;
  /** \brief
 *  Evaluate the Rune pipeline.
 */
  Result_uint8_Error_ptr_t rune_wasmer_runtime_call(WasmerRuntime_t *runtime);

  RunicosBaseImage_t *rune_image_new(void);

  void rune_image_free(RunicosBaseImage_t *image);

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

  typedef struct
  {

    uint8_t *ptr;

    size_t len;

  } slice_raw_uint8_t;

  typedef struct
  {

    LogLevel_t level;

    slice_raw_uint8_t target;

    char *message;

  } LogRecord_t;

  typedef struct
  {

    void *env_ptr;
    int (*call)(void *, LogRecord_t);
    void (*free)(void *);
  } BoxDynFnMut1_Result_uint8_Error_ptr_LogRecord_t;

  /** \brief
 *  Set the closure to be called when the Rune emits log messages.
 */
#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* _RUST_RUNE_NATIVE_ */
