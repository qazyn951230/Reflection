// MIT License
//
// Copyright (c) 2017-present qazyn951230 qazyn951230@gmail.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#ifndef START_POINT_CONFIG_H
#define START_POINT_CONFIG_H

// ------------- FILE ------------------

#if (__cplusplus)
#define SP_EXTERN_C_BEGIN   extern "C" {
#define SP_EXTERN_C_END     }
#ifdef SP_CPP_USE_NAMESPACE
#define SP_CPP_FILE_BEGIN   namespace SP_CPP_NAMESPACE { \
                            _Pragma("clang assume_nonnull begin")
#define SP_CPP_FILE_END     _Pragma("clang assume_nonnull end") \
                            }
#else
#define SP_CPP_FILE_BEGIN  _Pragma("clang assume_nonnull begin")
#define SP_CPP_FILE_END    _Pragma("clang assume_nonnull end")
#endif // #ifdef SP_CPP_USE_NAMESPACE
#else
#define SP_EXTERN_C_BEGIN
#define SP_EXTERN_C_END
#define SP_CPP_FILE_BEGIN   _Pragma("clang assume_nonnull begin")
#define SP_CPP_FILE_END     _Pragma("clang assume_nonnull end")
#endif // (__cplusplus)

#define SP_C_FILE_BEGIN SP_EXTERN_C_BEGIN \
                        _Pragma("clang assume_nonnull begin")
#define SP_C_FILE_END   _Pragma("clang assume_nonnull end") \
                        SP_EXTERN_C_END

// ------------- FILE ------------------

#if defined(__clang__) || defined(__GNUC__)
#define SP_LIKELY(x)    __builtin_expect(!!(x), 1)
#define SP_UNLIKELY(x)  __builtin_expect(!!(x), 0)
#else
#define SP_LIKELY(x)    (x)
#define SP_UNLIKELY(x)  (x)
#endif

// ------------- NULLABLE ------------------
// http://clang.llvm.org/docs/AttributeReference.html#nullability-attributes
// A nullable pointer to non-null pointers to const characters.
// const char *join_strings(const char * _Nonnull * _Nullable strings, unsigned n);
#if defined(__clang__)
// int fetch(int * SP_NONNULL ptr);
#define SP_NONNULL _Nonnull
#define SP_NULL_UNSPECIFIED _Null_unspecified
// int fetch_or_zero(int * SP_NULLABLE ptr);
#define SP_NULLABLE _Nullable
#else
#define SP_NONNULL
#define SP_NULL_UNSPECIFIED
#define SP_NULLABLE
#endif // defined(__clang__)
// ------------- NULLABLE ------------------

// ------------- NSInteger ------------------
// .../usr/include/objc/NSObjCRuntime.h
#if !__has_include(<NSObjCRuntime.h>)

#if __LP64__ || 0 || NS_BUILD_32_LIKE_64
typedef long NSInteger;
typedef unsigned long NSUInteger;
#else
typedef int NSInteger;
typedef unsigned int NSUInteger;
#endif

#endif // !__has_include(<NSObjCRuntime.h>)
// ------------- NSInteger ------------------

// ------------- NSEnum ------------------
#if defined(CF_ENUM)
#define SP_ENUM CF_ENUM
#define SP_OPTIONS CF_OPTIONS
#else
// .../CoreFoundation.framework/Headers/CFAvailability.h
// Enums and Options
#if __has_attribute(enum_extensibility)
#define __SP_ENUM_ATTRIBUTES __attribute__((enum_extensibility(open)))
#define __SP_CLOSED_ENUM_ATTRIBUTES __attribute__((enum_extensibility(closed)))
#define __SP_OPTIONS_ATTRIBUTES __attribute__((flag_enum,enum_extensibility(open)))
#else
#define __SP_ENUM_ATTRIBUTES
#define __SP_CLOSED_ENUM_ATTRIBUTES
#define __SP_OPTIONS_ATTRIBUTES
#endif

#define __SP_ENUM_GET_MACRO(_1, _2, NAME, ...) NAME
#if (__cplusplus && __cplusplus >= 201103L && (__has_extension(cxx_strong_enums) || \
    __has_feature(objc_fixed_enum))) || (!__cplusplus && __has_feature(objc_fixed_enum))
#define __SP_NAMED_ENUM(_type, _name)     enum __SP_ENUM_ATTRIBUTES _name : _type _name; enum _name : _type
#define __SP_ANON_ENUM(_type)             enum __SP_ENUM_ATTRIBUTES : _type
#define SP_CLOSED_ENUM(_type, _name)      enum __SP_CLOSED_ENUM_ATTRIBUTES _name : _type _name; enum _name : _type
#if (__cplusplus)
#define SP_OPTIONS(_type, _name) _type _name; enum __SP_OPTIONS_ATTRIBUTES : _type
#else
#define SP_OPTIONS(_type, _name) enum __SP_OPTIONS_ATTRIBUTES _name : _type _name; enum _name : _type
#endif
#else
#define __SP_NAMED_ENUM(_type, _name) _type _name; enum
#define __SP_ANON_ENUM(_type) enum
#define SP_CLOSED_ENUM(_type, _name) _type _name; enum
#define SP_OPTIONS(_type, _name) _type _name; enum
#endif

/* SP_ENUM supports the use of one or two arguments.
 * The first argument is always the integer type used for the values of the enum.
 * The second argument is an optional type name for the macro.
 * When specifying a type name, you must precede the macro with 'typedef' like so:

typedef SP_ENUM(CFIndex, CFComparisonResult) {
    ...
};

If you do not specify a type name, do not use 'typdef', like so:

SP_ENUM(CFIndex) {
    ...
};
*/

#define SP_ENUM(...) __SP_ENUM_GET_MACRO(__VA_ARGS__, __SP_NAMED_ENUM, __SP_ANON_ENUM, )(__VA_ARGS__)
#endif
// ------------- NSEnum ------------------

// ------------- NS_SWIFT_NAME ------------------
#if defined(CF_SWIFT_NAME)
#define SP_SWIFT_NAME CF_SWIFT_NAME
#else
// CoreFoundation.framework/Headers/CFBase.h
#if __has_attribute(swift_name)
# define SP_SWIFT_NAME(_name) __attribute__((swift_name(#_name)))
#else
# define SP_SWIFT_NAME(_name)
#endif
#endif // defined(CF_ENUM)
// ------------- NS_SWIFT_NAME ------------------

// ------------- NS_NOESCAPE ------------------
#ifdef NS_NOESCAPE

#define SP_NOESCAPE NS_NOESCAPE

#else

#if __has_attribute(noescape)
#define SP_NOESCAPE __attribute__((noescape))
#else
#define SP_NOESCAPE
#endif

#endif
// ------------- NS_NOESCAPE ------------------

// ------------- CAST ------------------
#ifndef SP_OPAQUE_POINTER
#define SP_OPAQUE_POINTER(x) typedef struct x##_t* x##_p
#endif // SP_OPAQUE_POINTER

#if (__cplusplus)

#define SP_SIMPLE_CONVERSION(CxxType, CRef)                     \
inline CxxType *unwrap(CRef value) {                            \
    return reinterpret_cast<CxxType*>(value);                   \
}                                                               \
                                                                \
inline CRef wrap(const CxxType* value) {                        \
    return reinterpret_cast<CRef>(const_cast<CxxType*>(value)); \
}                                                               \

#define SP_STATIC_CONVERSION(TARGET, SOURCE)                    \
inline TARGET unwrap(const SOURCE& value) {                     \
return static_cast<TARGET>(value);                              \
}                                                               \
                                                                \
inline SOURCE wrap(const TARGET& value) {                       \
return static_cast<SOURCE>(value);                              \
}                                                               \

#define SP_CLASS_CONVERSION(TARGET, SOURCE)                                                     \
inline const TARGET& unwrap(const SOURCE& value) {                                              \
return *const_cast<const TARGET*>(reinterpret_cast<TARGET*>(const_cast<SOURCE*>(&value)));      \
}                                                                                               \
                                                                                                \
inline TARGET& unwrap(SOURCE& value) {                                                          \
    return *reinterpret_cast<TARGET*>(&value);                                                  \
}                                                                                               \
                                                                                                \
inline const SOURCE& wrap(const TARGET& value) {                                                \
    return *const_cast<const SOURCE*>(reinterpret_cast<SOURCE*>(const_cast<TARGET*>(&value)));  \
}                                                                                               \
                                                                                                \
inline SOURCE& wrap(TARGET& value) {                                                            \
    return *reinterpret_cast<SOURCE*>(&value);                                                  \
}                                                                                               \

#define SP_POINTER_CAST(type, source) (reinterpret_cast<type>(source))

#else // (__cplusplus)

#define SP_SIMPLE_CONVERSION(CxxType, CRef)                     \
inline CxxType *unwrap(CRef value) {                            \
    return (CxxType*)(value);                                   \
}                                                               \
                                                                \
inline CRef wrap(const CxxType* value) {                        \
    return (CRef)(const_cast<CxxType*>(value));                 \
}                                                               \

#define SP_STATIC_CONVERSION(TARGET, SOURCE)                    \
inline TARGET unwrap(const SOURCE& value) {                     \
return (TARGET)(value);                                         \
}                                                               \
                                                                \
inline SOURCE wrap(const TARGET& value) {                       \
return (SOURCE)(value);                                         \
}                                                               \

#define SP_POINTER_CAST(type, source) ((type)(source))

#endif // (__cplusplus)

// ------------- CAST ------------------

#endif // START_POINT_CONFIG_H
