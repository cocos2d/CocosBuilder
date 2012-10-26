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


#import "jsapi.h"
#import "jsfriendapi.h"

#import "js_bindings_core.h"
#import "js_bindings_config.h"
#import "js_bindings_NS_manual.h"


#pragma mark - helpers

JSObject* create_jsobject_from_realobj( JSContext* context, Class klass, id realObj )
{
	NSString *proxied_class = [NSString stringWithFormat:@"JSB_%@", klass];
	Class newKlass = NSClassFromString(proxied_class);
	if( newKlass )
		return [newKlass createJSObjectWithRealObject:realObj context:context];

	CCLOGWARN(@"Proxied class not found: %@. Trying with parent class", proxied_class );
	return create_jsobject_from_realobj( context, [klass superclass], realObj  );
}

JSObject * get_or_create_jsobject_from_realobj( JSContext *cx, id realObj )
{
	if( ! realObj )
		return NULL;
		
	JSB_NSObject *proxy = objc_getAssociatedObject(realObj, &JSB_association_proxy_key );
	if( proxy )
		return [proxy jsObj];
	
	return create_jsobject_from_realobj( cx, [realObj class], realObj );
}

#pragma mark - jsval to native

JSBool jsval_is_NSObject( JSContext *cx, jsval vp, NSObject **ret )
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	if( ! ok )
		return JS_FALSE;
	
	// root it
	vp = OBJECT_TO_JSVAL(jsobj);
	
	JSB_NSObject* proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject(jsobj);
	if( ! proxy )
		return  JS_FALSE;

	if( ret )
		*ret = [proxy realObj];
	
	return JS_TRUE;
}

// Convert function
JSBool jsval_to_NSObject( JSContext *cx, jsval vp, NSObject **ret )
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error converting value to object");
	
	// root it
	vp = OBJECT_TO_JSVAL(jsobj);
	
	JSB_NSObject* proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject(jsobj);
	
	JSB_PRECONDITION3( proxy, cx, JS_FALSE, "Error obtaining proxy");

	*ret = [proxy realObj];
	
	return JS_TRUE;
}

JSBool jsval_is_NSString( JSContext *cx, jsval vp, NSString **ret )
{
	JSString *jsstr = JS_ValueToString( cx, vp );
	if( !jsstr )
		return JS_FALSE;
	
	// root it
	vp = STRING_TO_JSVAL(jsstr);
	
	char *ptr = JS_EncodeString(cx, jsstr);
	
	if( !ptr )
		return JS_FALSE;
	
	NSString *tmp = [NSString stringWithUTF8String: ptr];
	
	if( !tmp ) {
		JS_free( cx, ptr );
		return JS_FALSE;
	}
	
	if( ret )
		*ret = tmp;

	JS_free( cx, ptr );
	
	return JS_TRUE;
}
JSBool jsval_to_NSString( JSContext *cx, jsval vp, NSString **ret )
{
	JSString *jsstr = JS_ValueToString( cx, vp );
	JSB_PRECONDITION3( jsstr, cx, JS_FALSE, "invalid string" );
	
	// root it
	vp = STRING_TO_JSVAL(jsstr);
	
	char *ptr = JS_EncodeString(cx, jsstr);
	
	JSB_PRECONDITION3(ptr, cx, JS_FALSE, "Error encoding string");
	
//	NSString *tmp = [NSString stringWithUTF8String: ptr];
	NSString *tmp = [NSString stringWithCString:ptr encoding:NSUTF8StringEncoding];
	
	JSB_PRECONDITION3( tmp, cx, JS_FALSE, "Error creating string from UTF8");
	
	*ret = tmp;
	JS_free( cx, ptr );
	
	return JS_TRUE;
}

JSBool jsval_to_NSArray( JSContext *cx, jsval vp, NSArray**ret )
{
	// Parsing sequence
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error converting value to object");
	
	JSB_PRECONDITION3( jsobj && JS_IsArrayObject( cx, jsobj),  cx, JS_FALSE, "Object must be an array");

	
	uint32_t len;
	JS_GetArrayLength(cx, jsobj,&len);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:len];
	for( uint32_t i=0; i< len;i++ ) {		
		jsval valarg;
		JS_GetElement(cx, jsobj, i, &valarg);
		
		// XXX: forcing them to be objects, but they could also be NSString, NSDictionary or NSArray
		id real_obj;
		ok = jsval_is_NSObject( cx, valarg, &real_obj );
		JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error converting value to nsobject");
		
		[array addObject:real_obj];
	}
	*ret = array;

	return JS_TRUE;
}

JSBool jsval_to_NSSet( JSContext *cx, jsval vp, NSSet** ret)
{
	// Parsing sequence
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error converting value to object");
	
	JSB_PRECONDITION3( jsobj && JS_IsArrayObject( cx, jsobj), cx, JS_FALSE, "Object must be an array");

	uint32_t len;
	JS_GetArrayLength(cx, jsobj,&len);
	NSMutableSet *set = [NSMutableArray arrayWithCapacity:len];
	for( uint32_t i=0; i< len;i++ ) {		
		jsval valarg;
		JS_GetElement(cx, jsobj, i, &valarg);
		
		// XXX: forcing them to be objects, but they could also be NSString, NSDictionary or NSArray
		id real_obj;
		ok = jsval_is_NSObject( cx, valarg, &real_obj );
		JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error converting value to nsobject");
		
		[set addObject:real_obj];
	}
	*ret = set;
	return JS_TRUE;
}

JSBool jsvals_variadic_to_NSArray( JSContext *cx, jsval *vp, int argc, NSArray**ret )
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:argc];
	
	for( int i=0; i < argc; i++ )
	{
		id obj = NULL;
		JSBool ok = JS_FALSE;
		
		// Native Object ?
		ok = jsval_is_NSObject( cx, *vp, &obj );

		// Number ?
		if( ! ok ) {
			double num;
			
			// optimization: JS_ValueToNumber is expensive. And can convert an string like "12" to a number
			if( JSVAL_IS_NUMBER(*vp))
			   ok = JS_ValueToNumber(cx, *vp, &num );
			
			if( ok ) {
				obj = [NSNumber numberWithDouble:num];
			}
		}
		
		// String ?
		if( ! ok )
			ok = jsval_is_NSString(cx, *vp, (NSString**)&obj );
		
		JSB_PRECONDITION3( ok && obj, cx, JS_FALSE, "Error converting variadic arguments");

		// next
		vp++;
		
		[array addObject:obj];
	}
	*ret = array;
	return JS_TRUE;
}

JSBool jsval_to_block_1( JSContext *cx, jsval vp, JSObject *jsthis, js_block *ret)
{
	JSFunction *func = JS_ValueToFunction(cx, vp );
	JSB_PRECONDITION2( func, cx, JS_FALSE, "Error converting value to function");
	
	js_block block = ^(id sender) {

		jsval rval;
		jsval val = NSObject_to_jsval(cx, sender);

		JSBool ok = JS_CallFunctionValue(cx, jsthis, vp, 1, &val, &rval);
		JSB_PRECONDITION2(ok, cx, , "Error calling callback (1)");
	};
	
	*ret = [[block copy] autorelease];
	return JS_TRUE;
}

JSBool jsval_to_block_2( JSContext *cx, jsval vp, JSObject *jsthis, jsval arg, js_block *ret)
{
	JSFunction *func = JS_ValueToFunction(cx, vp );
	JSB_PRECONDITION2( func, cx, JS_FALSE, "Error converting value to function");
		
	js_block block = ^(id sender) {
		
		jsval rval;
		jsval vals[2];
		
		vals[0] = NSObject_to_jsval(cx, sender);
		
		// arg NEEDS TO BE ROOTED! Potential crash
		vals[1] = arg;
		
		JSBool ok = JS_CallFunctionValue(cx, jsthis, vp, 2, vals, &rval);
		JSB_PRECONDITION2(ok, cx, , "Error calling callback (2)");
	};
	
	*ret = [[block copy] autorelease];
	return JS_TRUE;
}

JSBool jsval_to_CGPoint( JSContext *cx, jsval vp, CGPoint *ret )
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error converting value to object");
	JSB_PRECONDITION3( jsobj, cx, JS_FALSE, "Not a valid JS object");

	jsval valx, valy;
	ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "x", &valx);
	ok &= JS_GetProperty(cx, jsobj, "y", &valy);
	JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error obtaining point properties");
	
	double x, y;
	ok &= JS_ValueToNumber(cx, valx, &x);
	ok &= JS_ValueToNumber(cx, valy, &y);
	JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error converting value to numbers");

	ret->x = x;
	ret->y = y;

	return JS_TRUE;
}

JSBool jsval_to_CGSize( JSContext *cx, jsval vp, CGSize *ret )
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error converting value to object");
	JSB_PRECONDITION3( jsobj, cx, JS_FALSE, "Not a valid JS object");
	
	jsval valw, valh;
	ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "width", &valw);
	ok &= JS_GetProperty(cx, jsobj, "height", &valh);	
	JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error obtaining point properties");
	
	double w, h;
	ok &= JS_ValueToNumber(cx, valw, &w);
	ok &= JS_ValueToNumber(cx, valh, &h);	
	JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error converting value to numbers");
	
	ret->width = w;
	ret->height = h;
	
	return JS_TRUE;	
}

JSBool jsval_to_CGRect( JSContext *cx, jsval vp, CGRect *ret )
{	
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error converting value to object");
	JSB_PRECONDITION3( jsobj, cx, JS_FALSE, "Not a valid JS object");
	
	jsval valx, valy, valw, valh;
	ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "x", &valx);
	ok &= JS_GetProperty(cx, jsobj, "y", &valy);
	ok &= JS_GetProperty(cx, jsobj, "width", &valw);
	ok &= JS_GetProperty(cx, jsobj, "height", &valh);
	JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error obtaining point properties");
	
	double x, y, w, h;
	ok &= JS_ValueToNumber(cx, valx, &x);
	ok &= JS_ValueToNumber(cx, valy, &y);
	ok &= JS_ValueToNumber(cx, valw, &w);
	ok &= JS_ValueToNumber(cx, valh, &h);
	JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error converting value to numbers");
	
	ret->origin.x = x;
	ret->origin.y = y;
	ret->size.width = w;
	ret->size.height = h;
	
	return JS_TRUE;	
}

JSBool jsval_to_opaque( JSContext *cx, jsval vp, void **r)
{
#ifdef __LP64__
	JSObject *tmp_arg;
	JSBool ok = JS_ValueToObject( cx, vp, &tmp_arg );
	JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error converting value to object");
	JSB_PRECONDITION3( tmp_arg && JS_IsTypedArrayObject( tmp_arg, cx ), cx, JS_FALSE, "Not a TypedArray object");
	JSB_PRECONDITION3( JS_GetTypedArrayByteLength( tmp_arg, cx ) == sizeof(void*), cx, JS_FALSE, "Invalid Typed Array lenght");
	
	uint32_t* arg_array = (uint32_t*)JS_GetArrayBufferViewData( tmp_arg, cx );
	uint64 ret =  arg_array[0];
	ret = ret << 32;
	ret |= arg_array[1];
	
#else
	NSCAssert( sizeof(int)==4, @"fatal!");
	int32_t ret;
	JSBool ok = JS_ValueToInt32(cx, vp, &ret );
	JSB_PRECONDITION3(ok, cx, JS_FALSE, "Error converting value to int32");
#endif
	*r = (void*)ret;
	return JS_TRUE;
}

JSBool jsval_to_c_class( JSContext *cx, jsval vp, void **out_native, struct jsb_c_proxy_s **out_proxy)
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject(cx, vp, &jsobj);
	JSB_PRECONDITION3(ok, cx, JS_FALSE, "Error converting jsval to object");
	
	struct jsb_c_proxy_s *proxy = jsb_get_c_proxy_for_jsobject(jsobj);
	*out_native = proxy->handle;
	if( out_proxy )
		*out_proxy = proxy;
	return JS_TRUE;
}

JSBool jsval_to_int( JSContext *cx, jsval vp, int *ret )
{
	// Since this is called to cast uint64 to uint32,
	// it is needed to initialize the value to 0 first
#ifdef __LP64__
	long *tmp = (long*)ret;
	*tmp = 0;
#endif
	return JS_ValueToInt32(cx, vp, (int32_t*)ret);
}

JSBool jsval_to_uint( JSContext *cx, jsval vp, unsigned int *ret )
{
	// Since this is called to cast uint64 to uint32,
	// it is needed to initialize the value to 0 first
#ifdef __LP64__
	long *tmp = (long*)ret;
	*tmp = 0;
#endif
	return JS_ValueToInt32(cx, vp, (int32_t*)ret);
}


// XXX: sizeof(long) == 8 in 64 bits on OS X... apparently on Windows it is 32 bits (???)
JSBool jsval_to_long( JSContext *cx, jsval vp, long *r )
{
#ifdef __LP64__
	// compatibility check
	NSCAssert( sizeof(long)==8, @"fatal! Compiler error ?");
	JSString *jsstr = JS_ValueToString(cx, vp);
	JSB_PRECONDITION3(jsstr, cx, JS_FALSE, "Error converting value to string");
	
	char *str = JS_EncodeString(cx, jsstr);
	JSB_PRECONDITION3(str, cx, JS_FALSE, "Error encoding string");
	
	char *endptr;
	long ret = strtol(str, &endptr, 10);
	
	*r = ret;
	return JS_TRUE;	
#else
	// compatibility check
	NSCAssert( sizeof(int)==4, @"fatal!, Compiler error ?");
	long ret = JSVAL_TO_INT(vp);
#endif
	
	*r = ret;
	return JS_TRUE;
}

JSBool jsval_to_longlong( JSContext *cx, jsval vp, long long *r )
{
#if JSB_REPRESENT_LONGLONG_AS_STR
	JSString *jsstr = JS_ValueToString(cx, vp);
	JSB_PRECONDITION3(jsstr, cx, JS_FALSE, "Error converting value to string");

	char *str = JS_EncodeString(cx, jsstr);
	JSB_PRECONDITION3(str, cx, JS_FALSE, "Error encoding string");

	char *endptr;
	long long ret = strtoll(str, &endptr, 10);
	
	*r = ret;
	return JS_TRUE;

#else

	JSObject *tmp_arg;
	JSBool ok = JS_ValueToObject( cx, vp, &tmp_arg );
	JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error converting value to object");
	JSB_PRECONDITION3( tmp_arg && JS_IsTypedArrayObject( tmp_arg, cx ), cx, JS_FALSE, "Not a TypedArray object");
	JSB_PRECONDITION3( JS_GetTypedArrayByteLength( tmp_arg, cx ) == sizeof(long long), cx, JS_FALSE, "Invalid Typed Array lenght");
	
	uint32_t* arg_array = (uint32_t*)JS_GetArrayBufferViewData( tmp_arg, cx );
	long long ret =  arg_array[0];
	ret = ret << 32;
	ret |= arg_array[1];
	
	*r = ret;
	return JS_TRUE;
#endif // JSB_REPRESENT_LONGLONG_AS_STR
}


#pragma mark - native to jsval

jsval NSObject_to_jsval( JSContext *cx, id obj )
{
	jsval ret;
	if( ! obj )
		return JSVAL_NULL;
	
	JSB_NSObject *proxy = objc_getAssociatedObject(obj, &JSB_association_proxy_key );
	if( proxy )
		ret = OBJECT_TO_JSVAL([proxy jsObj]);
	
	else
		ret = OBJECT_TO_JSVAL( create_jsobject_from_realobj( cx, [obj class], obj ) );
	
	return ret;
}

jsval NSString_to_jsval( JSContext *cx, NSString *str)
{
	JSString *ret_obj = JS_NewStringCopyZ(cx, [str UTF8String]);
	return STRING_TO_JSVAL(ret_obj);
}

jsval NSArray_to_jsval( JSContext *cx, NSArray *array)
{
	JSObject *jsobj = JS_NewArrayObject(cx, 0, NULL);
	uint32_t index = 0;
	for( id obj in array ) {
        jsval val;
        // XXX: We should do the same for NSNumber
        if( [obj isKindOfClass:[NSString class]] )
            val = NSString_to_jsval(cx, obj);
        else
            val = NSObject_to_jsval(cx, obj);
		JS_SetElement(cx, jsobj, index++, &val);
	}
	
	return OBJECT_TO_JSVAL(jsobj);
}

jsval NSSet_to_jsval( JSContext *cx, NSSet *set)
{
	JSObject *jsobj = JS_NewArrayObject(cx, 0, NULL);
	uint32_t index = 0;
	for( id obj in set ) {
        jsval val;
        // XXX: We should do the same for NSNumber
        if( [obj isKindOfClass:[NSString class]] )
            val = NSString_to_jsval(cx, obj);
        else
            val = NSObject_to_jsval(cx, obj);

		JS_SetElement(cx, jsobj, index++, &val);
	}

	return OBJECT_TO_JSVAL(jsobj);
}

jsval CGPoint_to_jsval( JSContext *cx, CGPoint p)
{
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;

	if (!JS_DefineProperty(cx, object, "x", DOUBLE_TO_JSVAL(p.x), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "y", DOUBLE_TO_JSVAL(p.y), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;
	
	return OBJECT_TO_JSVAL(object);
}

jsval CGSize_to_jsval( JSContext *cx, CGSize s)
{
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;
	
	if (!JS_DefineProperty(cx, object, "width", DOUBLE_TO_JSVAL(s.width), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "height", DOUBLE_TO_JSVAL(s.height), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;
	
	return OBJECT_TO_JSVAL(object);	
}

jsval CGRect_to_jsval( JSContext *cx, CGRect rect)
{
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;
	
	if (!JS_DefineProperty(cx, object, "x", DOUBLE_TO_JSVAL(rect.origin.x), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "y", DOUBLE_TO_JSVAL(rect.origin.y), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "width", DOUBLE_TO_JSVAL(rect.size.width), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "height", DOUBLE_TO_JSVAL(rect.size.height), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;
	
	return OBJECT_TO_JSVAL(object);	
}

jsval opaque_to_jsval( JSContext *cx, void *opaque )
{
#ifdef __LP64__
	uint64_t number = (uint64_t)opaque;
	JSObject *typedArray = JS_NewUint32Array( cx, 2 );
	uint32_t *buffer = (uint32_t*)JS_GetArrayBufferViewData(typedArray, cx);
	buffer[0] = number >> 32;
	buffer[1] = number & 0xffffffff;
	return OBJECT_TO_JSVAL(typedArray);		
#else
	NSCAssert( sizeof(int)==4, @"Error!");
	uint32_t number = (uint32_t) opaque;
	return INT_TO_JSVAL(number);
#endif
}

jsval c_class_to_jsval( JSContext *cx, void* handle, JSObject* object, JSClass *klass, const char* class_name)
{
	JSObject *jsobj;

	jsobj = jsb_get_jsobject_for_proxy(handle);
	if( !jsobj ) {
		jsobj = JS_NewObject(cx, klass, object, NULL);
		NSCAssert(jsobj, @"Invalid object");
		jsb_set_c_proxy_for_jsobject(jsobj, handle, JSB_C_FLAG_DO_NOT_CALL_FREE);
		jsb_set_jsobject_for_proxy(jsobj, handle);
	}

	return OBJECT_TO_JSVAL(jsobj);
}

jsval int_to_jsval( JSContext *cx, int number )
{
	return INT_TO_JSVAL(number);
}

jsval uint_to_jsval( JSContext *cx, unsigned int number )
{
	return UINT_TO_JSVAL(number);
}

jsval long_to_jsval( JSContext *cx, long number )
{
#ifdef __LP64__
	NSCAssert( sizeof(long)==8, @"Error!");

	char chr[128];
	snprintf(chr, sizeof(chr)-1, "%ld", number);
	JSString *ret_obj = JS_NewStringCopyZ(cx, chr);
	return STRING_TO_JSVAL(ret_obj);
#else
	NSCAssert( sizeof(int)==4, @"Error!");
	return INT_TO_JSVAL(number);
#endif
}

jsval longlong_to_jsval( JSContext *cx, long long number )
{
#if JSB_REPRESENT_LONGLONG_AS_STR
	char chr[128];
	snprintf(chr, sizeof(chr)-1, "%lld", number);
	JSString *ret_obj = JS_NewStringCopyZ(cx, chr);
	return STRING_TO_JSVAL(ret_obj);

#else
	NSCAssert( sizeof(long long)==8, @"Error!");
	JSObject *typedArray = JS_NewUint32Array( cx, 2 );
	uint32_t *buffer = (uint32_t*)JS_GetArrayBufferViewData(typedArray, cx);
	buffer[0] = number >> 32;
	buffer[1] = number & 0xffffffff;
	return OBJECT_TO_JSVAL(typedArray);
#endif
}


