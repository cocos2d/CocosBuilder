/*
 * JS Bindings: https://github.com/zynga/jsbindings
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#import <Foundation/Foundation.h>
#import "js_bindings_config.h"

typedef void (^js_block)(id sender);

/** Creates a JSObject, a ProxyObject and associates them with the real object */
JSObject* create_jsobject_from_realobj( JSContext* context, Class klass, id realObj );

/** Gets or Creates a JSObject, a ProxyObject and associates them with the real object */
JSObject * get_or_create_jsobject_from_realobj( JSContext *cx, id realObj);

/** Whether or not the jsval is an NSString. If ret is not null, it returns the converted object.
 Like jsval_to_NSString, but if it is not an NSString it does not report error.
 */
JSBool jsval_is_NSString( JSContext *cx, jsval vp, NSString **ret );

/** Whether or not the jsval is an NSObject. If ret is not null, it returns the converted object.
 Like jsval_to_NSObject, but if it is not an NSObject it does not report error.
 */
JSBool jsval_is_NSObject( JSContext *cx, jsval vp, NSObject **ret );

/** converts a jsval to a NSString */
JSBool jsval_to_NSString( JSContext *cx , jsval vp, NSString **out );

/** converts a jsval to a NSObject */
JSBool jsval_to_NSObject( JSContext *cx, jsval vp, NSObject **out );

/** converts a jsval to a NSArray */
JSBool jsval_to_NSArray( JSContext *cx , jsval vp, NSArray **out );

/** converts a jsval to a NSSet */
JSBool jsval_to_NSSet( JSContext *cx , jsval vp, NSSet** out );

/** converts a variadic jsvals to a NSArray */
JSBool jsvals_variadic_to_NSArray( JSContext *cx, jsval *vp, int argc, NSArray** out );
	
JSBool jsval_to_CGPoint( JSContext *cx, jsval vp, CGPoint *out );
JSBool jsval_to_CGSize( JSContext *cx, jsval vp, CGSize *out );
JSBool jsval_to_CGRect( JSContext *cx, jsval vp, CGRect *out );
/** converts a jsval to a 'handle'. Typically the handle is pointer to a struct */
JSBool jsval_to_opaque( JSContext *cx, jsval vp, void **out );
JSBool jsval_to_int( JSContext *cx, jsval vp, int *out);
JSBool jsval_to_uint( JSContext *cx, jsval vp, unsigned int *ret );
JSBool jsval_to_long( JSContext *cx, jsval vp, long *out);
JSBool jsval_to_longlong( JSContext *cx, jsval vp, long long *out);
/** converts a jsval to a "handle" needed for Object Oriented C API */
JSBool jsval_to_c_class( JSContext *cx, jsval vp, void **r, struct jsb_c_proxy_s **out_proxy_optional);
/** converts a jsval to a block (1 == receives 1 argument (sender) ) */
JSBool jsval_to_block_1( JSContext *cx, jsval vp, JSObject *jsthis, js_block *out  );
/** converts a jsval to a block (2 == receives 2 argument (sender + custom) ) */
JSBool jsval_to_block_2( JSContext *cx, jsval vp, JSObject *jsthis, jsval arg, js_block *out  );

/** Converts an NSObject into a jsval. It does not creates a new object it the NSObject has already been converted */
jsval NSObject_to_jsval( JSContext *cx, id object);
jsval NSString_to_jsval( JSContext *cx, NSString *str);
jsval NSArray_to_jsval( JSContext *cx, NSArray *array);
jsval NSSet_to_jsval( JSContext *cx, NSSet *set);
jsval int_to_jsval( JSContext *cx, int l);
jsval uint_to_jsval( JSContext *cx, unsigned int number );
jsval long_to_jsval( JSContext *cx, long l);
jsval longlong_to_jsval( JSContext *cx, long long l);
jsval CGPoint_to_jsval( JSContext *cx, CGPoint p );
jsval CGSize_to_jsval( JSContext *cx, CGSize s);
jsval CGRect_to_jsval( JSContext *cx, CGRect r);
/** Converts an C Structure (handle) into a jsval. It returns jsval that will be sued as a "pointer" to the C Structure */
jsval opaque_to_jsval( JSContext *cx, void* opaque);
/** Converts an C class (a structure) into a jsval. It does not creates a new object it the C class has already been converted */
jsval c_class_to_jsval( JSContext *cx, void* handle, JSObject* object, JSClass *klass, const char* optional_class_name);
