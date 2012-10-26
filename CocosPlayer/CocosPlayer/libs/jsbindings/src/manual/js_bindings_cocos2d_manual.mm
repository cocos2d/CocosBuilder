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


#import "js_bindings_config.h"

#ifdef JSB_INCLUDE_COCOS2D

#import "jsfriendapi.h"

#import "js_bindings_core.h"
#import "js_bindings_basic_conversions.h"
#import "js_bindings_cocos2d_classes.h"

#if __CC_PLATFORM_MAC
#import "js_bindings_cocos2d_mac_classes.h"
#elif __CC_PLATFORM_IOS
#import "js_bindings_cocos2d_ios_classes.h"
#endif

#pragma mark - convertions
jsval ccGridSize_to_jsval( JSContext *cx, ccGridSize p)
{
	JSObject *typedArray = JS_NewInt32Array( cx, 2 );
	int32_t *buffer = (int32_t*)JS_GetArrayBufferViewData(typedArray, cx);
	buffer[0] = (int32_t)p.x;
	buffer[1] = (int32_t)p.y;
	return OBJECT_TO_JSVAL(typedArray);
}

JSBool jsval_to_ccGridSize( JSContext *cx, jsval vp, ccGridSize *ret )
{
	JSObject *tmp_arg;
	JSBool ok = JS_ValueToObject( cx, vp, &tmp_arg );
	JSB_PRECONDITION( ok, "Error converting value to object");
	JSB_PRECONDITION( JS_IsTypedArrayObject( tmp_arg, cx ), "Not a TypedArray object");
	JSB_PRECONDITION( JS_GetTypedArrayByteLength( tmp_arg, cx ) == sizeof(int32_t)*2, "Invalid length");
	
#ifdef __LP64__
	int32_t* arg_array = (int32_t*)JS_GetArrayBufferViewData( tmp_arg, cx );
	*ret = ccg(arg_array[0], arg_array[1] );	
#else
	*ret = *(ccGridSize*)JS_GetArrayBufferViewData( tmp_arg, cx);
#endif
	return JS_TRUE;
}

JSBool jsval_to_ccColor3B( JSContext *cx, jsval vp, ccColor3B *ret )
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION( ok, "Error converting value to object");
	JSB_PRECONDITION( jsobj, "Not a valid JS object");
	
	jsval valr, valg, valb;
	ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "r", &valr);
	ok &= JS_GetProperty(cx, jsobj, "g", &valg);
	ok &= JS_GetProperty(cx, jsobj, "b", &valb);
	JSB_PRECONDITION( ok, "Error obtaining point properties");
	
	uint16_t r,g,b;
	ok &= JS_ValueToUint16(cx, valr, &r);
	ok &= JS_ValueToUint16(cx, valg, &g);
	ok &= JS_ValueToUint16(cx, valb, &b);
	JSB_PRECONDITION( ok, "Error converting value to numbers");
	
	ret->r = r;
	ret->g = g;
	ret->b = b;
	
	return JS_TRUE;	
}

JSBool jsval_to_ccColor4B( JSContext *cx, jsval vp, ccColor4B *ret )
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION( ok, "Error converting value to object");
	JSB_PRECONDITION( jsobj, "Not a valid JS object");
	
	jsval valr, valg, valb, vala;
	ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "r", &valr);
	ok &= JS_GetProperty(cx, jsobj, "g", &valg);
	ok &= JS_GetProperty(cx, jsobj, "b", &valb);
	ok &= JS_GetProperty(cx, jsobj, "a", &vala);
	JSB_PRECONDITION( ok, "Error obtaining point properties");
	
	uint16_t r,g,b,a;
	ok &= JS_ValueToUint16(cx, valr, &r);
	ok &= JS_ValueToUint16(cx, valg, &g);
	ok &= JS_ValueToUint16(cx, valb, &b);
	ok &= JS_ValueToUint16(cx, vala, &a);
	JSB_PRECONDITION( ok, "Error converting value to numbers");
	
	ret->r = r;
	ret->g = g;
	ret->b = b;
	ret->a = a;
	
	return JS_TRUE;
}

JSBool jsval_to_ccColor4F( JSContext *cx, jsval vp, ccColor4F *ret )
{
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION( ok, "Error converting value to object");
	JSB_PRECONDITION( jsobj, "Not a valid JS object");
	
	jsval valr, valg, valb, vala;
	ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "r", &valr);
	ok &= JS_GetProperty(cx, jsobj, "g", &valg);
	ok &= JS_GetProperty(cx, jsobj, "b", &valb);
	ok &= JS_GetProperty(cx, jsobj, "a", &vala);	
	JSB_PRECONDITION( ok, "Error obtaining point properties");
	
	double r,g,b,a;
	ok &= JS_ValueToNumber(cx, valr, &r);
	ok &= JS_ValueToNumber(cx, valg, &g);
	ok &= JS_ValueToNumber(cx, valb, &b);
	ok &= JS_ValueToNumber(cx, vala, &a);
	JSB_PRECONDITION( ok, "Error converting value to numbers");
	
	ret->r = r;
	ret->g = g;
	ret->b = b;
	ret->a = a;
	
	return JS_TRUE;	
}

jsval ccColor3B_to_jsval( JSContext *cx, ccColor3B p )
{
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;
	
	if (!JS_DefineProperty(cx, object, "r", UINT_TO_JSVAL(p.r), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "g", UINT_TO_JSVAL(p.g), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "b", UINT_TO_JSVAL(p.b), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;
	
	return OBJECT_TO_JSVAL(object);	
}

jsval ccColor4B_to_jsval( JSContext *cx, ccColor4B p )
{
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;
	
	if (!JS_DefineProperty(cx, object, "r", UINT_TO_JSVAL(p.r), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "g", UINT_TO_JSVAL(p.g), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "b", UINT_TO_JSVAL(p.g), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "a", UINT_TO_JSVAL(p.b), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;
	
	return OBJECT_TO_JSVAL(object);		
}

jsval ccColor4F_to_jsval( JSContext *cx, ccColor4F p )
{
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;
	
	if (!JS_DefineProperty(cx, object, "r", DOUBLE_TO_JSVAL(p.r), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "g", DOUBLE_TO_JSVAL(p.g), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "b", DOUBLE_TO_JSVAL(p.g), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "a", DOUBLE_TO_JSVAL(p.b), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;
	
	return OBJECT_TO_JSVAL(object);		
}

JSBool jsval_to_array_of_CGPoint( JSContext *cx, jsval vp, CGPoint**points, int *numPoints)
{
	// Parsing sequence
	JSObject *jsobj;
	JSBool ok = JS_ValueToObject( cx, vp, &jsobj );
	JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error converting value to object");
	JSB_PRECONDITION3( jsobj && JS_IsArrayObject( cx, jsobj), cx, JS_FALSE, "Object must be an array");
	
	uint32_t len;
	JS_GetArrayLength(cx, jsobj, &len);
		
	CGPoint *array = (CGPoint*)malloc( sizeof(CGPoint) * len);
	
	for( uint32_t i=0; i< len;i++ ) {
		jsval valarg;
		JS_GetElement(cx, jsobj, i, &valarg);

		ok = jsval_to_CGPoint(cx, valarg, &array[i]);
		JSB_PRECONDITION3( ok, cx, JS_FALSE, "Error converting value to CGPoint");
	}
			
	*numPoints = len;
	*points = array;
	
	return JS_TRUE;
}

#pragma mark - Layer

@implementation JSB_CCLayer (Manual)

#if __CC_PLATFORM_MAC

-(BOOL) ccFlagsChanged:(NSEvent*)event
{
	BOOL ret;
	if (_jsObj) {
		JSContext* cx = [[JSBCore sharedInstance] globalContext];
		JSBool found;
		JS_HasProperty(cx, _jsObj, "onKeyFlagsChanged", &found);
		if (found == JS_TRUE) {
			jsval rval, fval;
			jsval argv;
			NSUInteger flags = [event modifierFlags];
			argv = UINT_TO_JSVAL((uint32_t)flags);
			
			JS_GetProperty(cx, _jsObj, "onKeyFlagsChanged", &fval);
			JS_CallFunctionValue(cx, _jsObj, fval, 1, &argv, &rval);
			JSBool jsbool; JS_ValueToBoolean(cx, rval, &jsbool);
			ret = jsbool;
		}
	}
	return ret;
}

-(BOOL) ccKeyUp:(NSEvent*)event
{
	BOOL ret;
	if (_jsObj) {
		JSContext* cx = [[JSBCore sharedInstance] globalContext];
		JSBool found;
		JS_HasProperty(cx, _jsObj, "onKeyUp", &found);
		if (found == JS_TRUE) {
			jsval rval, fval;
			jsval argv;
			unichar uchar = [[event characters] characterAtIndex:0];
			argv = UINT_TO_JSVAL(uchar);
			
			JS_GetProperty(cx, _jsObj, "onKeyUp", &fval);
			JS_CallFunctionValue(cx, _jsObj, fval, 1, &argv, &rval);
			JSBool jsbool; JS_ValueToBoolean(cx, rval, &jsbool);
			ret = jsbool;
		}
	}
	return ret;
}

-(BOOL) ccKeyDown:(NSEvent*)event
{
	BOOL ret;
	if (_jsObj) {
		JSContext* cx = [[JSBCore sharedInstance] globalContext];
		JSBool found;
		JS_HasProperty(cx, _jsObj, "onKeyDown", &found);
		if (found == JS_TRUE) {
			jsval rval, fval;
			jsval argv;
			unichar uchar = [[event characters] characterAtIndex:0];
			argv = UINT_TO_JSVAL(uchar);
			
			JS_GetProperty(cx, _jsObj, "onKeyDown", &fval);
			JS_CallFunctionValue(cx, _jsObj, fval, 1, &argv, &rval);
			JSBool jsbool; JS_ValueToBoolean(cx, rval, &jsbool);
			ret = jsbool;
		}
	}
	return ret;
}

#elif __CC_PLATFORM_IOS

-(void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	if (_jsObj) {
		JSContext* cx = [[JSBCore sharedInstance] globalContext];
		JSBool found;
		JS_HasProperty(cx, _jsObj, "onAccelerometer", &found);
		if (found == JS_TRUE) {
			jsval rval, fval;

			NSTimeInterval time = acceleration.timestamp;
			UIAccelerationValue x = acceleration.x;
			UIAccelerationValue y = acceleration.y;
			UIAccelerationValue z = acceleration.z;

			// Create an JS object with x,y,z,timestamp as properties
			JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
			if( !object)
				return;

			if (!JS_DefineProperty(cx, object, "x", DOUBLE_TO_JSVAL(x), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
				!JS_DefineProperty(cx, object, "y", DOUBLE_TO_JSVAL(y), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
				!JS_DefineProperty(cx, object, "z", DOUBLE_TO_JSVAL(z), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
				!JS_DefineProperty(cx, object, "timestamp", DOUBLE_TO_JSVAL(time), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
				return;
			
			jsval argv = OBJECT_TO_JSVAL(object);
			
			JS_GetProperty(cx, _jsObj, "onAccelerometer", &fval);
			JS_CallFunctionValue(cx, _jsObj, fval, 1, &argv, &rval);
		}
	}	
}
#endif // __CC_PLATFORM_IOS

@end

#pragma mark - MenuItem 

// "setCallback" in JS
JSBool JSB_CCMenuItem_setBlock_( JSContext *cx, uint32_t argc, jsval *vp ) {
	
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject(jsthis);
	
	JSB_PRECONDITION( proxy && [proxy realObj], "Invalid Proxy object");
	JSB_PRECONDITION( argc == 2, "Invalid number of arguments. Expecting 2 args" );
	jsval *argvp = JS_ARGV(cx,vp);
	js_block js_func;
	JSObject *js_this;
	JSBool ok = JS_TRUE;

	ok &= JS_ValueToObject(cx, *argvp, &js_this);
	ok &= jsb_set_reserved_slot(jsthis, 0, *argvp++ );

	ok &= jsval_to_block_1( cx, *argvp, js_this, &js_func );
	ok &= jsb_set_reserved_slot(jsthis, 1, *argvp++ );
	
	if( ! ok )
		return JS_FALSE;
	
	CCMenuItem *real = (CCMenuItem*) [proxy realObj];

	[real setBlock:(void(^)(id sender))js_func];

	JS_SET_RVAL(cx, vp, JSVAL_VOID);

	return JS_TRUE;
}

#pragma mark - MenuItemFont

// "create" in JS
JSBool JSB_CCMenuItemFont_itemWithString_block__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc ==1 || argc == 3, "Invalid number of arguments. Expecting 1 or 3 args" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	NSString *normal;
	js_block js_func;
	JSObject *js_this;
	
	ok &= jsval_to_NSString( cx, argvp[0], &normal );
		
	if( argc ==3 ) {
		// this
		ok &= JS_ValueToObject(cx, argvp[1], &js_this);

		// function
		ok &= jsval_to_block_1( cx, argvp[2], js_this, &js_func );
	}
	
	CCMenuItemFont *ret_val;
	
	if( argc == 1 )
		ret_val = [CCMenuItemFont itemWithString:normal];
	else if (argc ==3 )
		ret_val = [CCMenuItemFont itemWithString:normal block:(void(^)(id sender))js_func];
	
	JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, ret_val );
	
	// "root" object and function
	if( argc == 3 ) {
		jsb_set_reserved_slot(jsobj, 0, argvp[1] );
		jsb_set_reserved_slot(jsobj, 1, argvp[2] );
	}

	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));


	return JS_TRUE;
}

// "init" in JS
JSBool JSB_CCMenuItemFont_initWithString_block_(JSContext *cx, uint32_t argc, jsval *vp) {
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject(jsthis);
	
	JSB_PRECONDITION( proxy && ![proxy realObj], "Invalid Proxy object");
	JSB_PRECONDITION( argc ==1 || argc == 3, "Invalid number of arguments. Expecting 1 or 3 args" );
	
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	NSString *normal;
	js_block js_func;
	JSObject *js_this;
	
	ok &= jsval_to_NSString( cx, argvp[0], &normal );
	
	if( argc ==3 ) {
		// this
		ok &= JS_ValueToObject(cx, argvp[1], &js_this);
		
		// function
		ok &= jsval_to_block_1( cx, argvp[2], js_this, &js_func );
	}
	
	CCMenuItemFont *real;
	
	if( argc == 1 )
		real = [(CCMenuItemFont*)[proxy.klass alloc] initWithString:normal target:nil selector:nil];
	else if (argc ==3 )
		real = [(CCMenuItemFont*)[proxy.klass alloc] initWithString:normal block:(void(^)(id sender))js_func];

	[proxy setRealObj: real];

	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	
	// "root" object and function
	if( argc == 3 ) {
		jsb_set_reserved_slot(jsthis, 0, argvp[1] );
		jsb_set_reserved_slot(jsthis, 1, argvp[2] );
	}
		
	return JS_TRUE;
}


#pragma mark - MenuItemLabel

// "create" in JS
JSBool JSB_CCMenuItemLabel_itemWithLabel_block__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc ==1 || argc == 3, "Invalid number of arguments. Expecting 1 or 3 args" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	CCNode<CCLabelProtocol, CCRGBAProtocol> *label;
	js_block js_func;
	JSObject *js_this;
	
	ok &= jsval_to_NSObject( cx, argvp[0], &label );
	
	if( argc ==3 ) {
		// this
		ok &= JS_ValueToObject(cx, argvp[1], &js_this);
		
		// function
		ok &= jsval_to_block_1( cx, argvp[2], js_this, &js_func );
	}
	
	CCMenuItemLabel *ret_val;
	
	if( argc == 1 )
		ret_val = [CCMenuItemLabel itemWithLabel:label];
	else if (argc ==3 )
		ret_val = [CCMenuItemLabel itemWithLabel:label block:(void(^)(id sender))js_func];
	
	JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
	// "root" object and function
	if( argc == 3 ) {
		jsb_set_reserved_slot(jsobj, 0, argvp[1] );
		jsb_set_reserved_slot(jsobj, 1, argvp[2] );
	}
	
	return JS_TRUE;
}

// "init" in JS
JSBool JSB_CCMenuItemLabel_initWithLabel_block_(JSContext *cx, uint32_t argc, jsval *vp) {
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject(jsthis);
	
	JSB_PRECONDITION( proxy && [proxy realObj], "Invalid Proxy object");
	JSB_PRECONDITION( argc ==1 || argc == 3, "Invalid number of arguments. Expecting 1 or 3 args" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	CCNode<CCLabelProtocol, CCRGBAProtocol> *label;
	js_block js_func;
	JSObject *js_this;
	
	ok &= jsval_to_NSObject( cx, argvp[0], &label );
	
	if( argc ==3 ) {
		// this
		ok &= JS_ValueToObject(cx, argvp[1], &js_this);
		
		// function
		ok &= jsval_to_block_1( cx, argvp[2], js_this, &js_func );
	}
	
	CCMenuItemLabel *real = nil;
	if( argc == 1 )
		real = [(CCMenuItemLabel*)[proxy.klass alloc] initWithLabel:label target:nil selector:NULL];
	else if (argc ==3 )
		real = [(CCMenuItemLabel*)[proxy.klass alloc] initWithLabel:label block:(void(^)(id sender))js_func];

	[proxy setRealObj:real];
	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	
	// "root" object and function
	if( argc == 3 ) {
		jsb_set_reserved_slot(jsthis, 0, argvp[1] );
		jsb_set_reserved_slot(jsthis, 1, argvp[2] );
	}
	
	return JS_TRUE;
}

#pragma mark - MenuItemImage

// "create" in JS
JSBool JSB_CCMenuItemImage_itemWithNormalImage_selectedImage_disabledImage_block__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc >=2 && argc <= 5, "Invalid number of arguments. Expecting: 2 <= args <= 5" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	NSString *normal, *selected, *disabled;
	js_block js_func;
	JSObject *js_this;
	jsval valthis, valfn;
	
	ok &= jsval_to_NSString( cx, *argvp++, &normal );
	
	if( argc >= 2 )
		ok &= jsval_to_NSString( cx, *argvp++, &selected );

	if( argc == 3 || argc == 5)
		ok &= jsval_to_NSString( cx, *argvp++, &disabled );


	// cannot merge with previous if() since argvp needs to be incremented
	if( argc >=4 ) {
		// this
		valthis = *argvp;
		ok &= JS_ValueToObject(cx, *argvp++, &js_this);

		// function
		valfn = *argvp;
		ok &= jsval_to_block_1( cx, *argvp++, js_this, &js_func );
	}

	CCMenuItemImage *ret_val;
		
	if( argc == 2 )
		ret_val = [CCMenuItemImage itemWithNormalImage:normal selectedImage:selected];
	else if (argc ==3 )
		ret_val = [CCMenuItemImage itemWithNormalImage:normal selectedImage:selected disabledImage:disabled];
	else if (argc == 4 )
		ret_val = [CCMenuItemImage itemWithNormalImage:normal selectedImage:selected block:(void(^)(id sender))js_func];
	else if (argc == 5 )
		ret_val = [CCMenuItemImage itemWithNormalImage:normal selectedImage:selected disabledImage:disabled block:(void(^)(id sender))js_func];

	JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
	// "root" object and function
	if( argc >= 4 ) {
		jsb_set_reserved_slot(jsobj, 0, valthis );
		jsb_set_reserved_slot(jsobj, 1, valfn );
	}
	
	return JS_TRUE;
}

// "init" in JS
JSBool JSB_CCMenuItemImage_initWithNormalImage_selectedImage_disabledImage_block_(JSContext *cx, uint32_t argc, jsval *vp) {
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject(jsthis);
	
	JSB_PRECONDITION( proxy && [proxy realObj], "Invalid Proxy object");
	JSB_PRECONDITION( argc >=2 && argc <= 5, "Invalid number of arguments. Expecting: 2 <= args <= 5" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	NSString *normal, *selected, *disabled;
	js_block js_func;
	JSObject *js_this;
	jsval valthis, valfn;
	
	ok &= jsval_to_NSString( cx, *argvp++, &normal );
	
	if( argc >= 2 )
		ok &= jsval_to_NSString( cx, *argvp++, &selected );
	
	if( argc == 3 || argc == 5)
		ok &= jsval_to_NSString( cx, *argvp++, &disabled );
	
	
	// cannot merge with previous if() since argvp needs to be incremented
	if( argc >=4 ) {
		// this
		valthis = *argvp;
		ok &= JS_ValueToObject(cx, *argvp++, &js_this);
		
		// function
		valfn = *argvp;
		ok &= jsval_to_block_1( cx, *argvp++, js_this, &js_func );
	}
	
	CCMenuItemImage *real = nil;
	
	if( argc == 2 )
		real = [(CCMenuItemImage*)[proxy.klass alloc] initWithNormalImage:normal selectedImage:selected disabledImage:nil target:nil selector:NULL];
	else if (argc ==3 )
		real = [(CCMenuItemImage*)[proxy.klass alloc] initWithNormalImage:normal selectedImage:selected disabledImage:disabled target:nil selector:NULL];
	else if (argc == 4 )
		real = [(CCMenuItemImage*)[proxy.klass alloc] initWithNormalImage:normal selectedImage:selected disabledImage:nil block:(void(^)(id sender))js_func];
	else if (argc == 5 )
		real = [(CCMenuItemImage*)[proxy.klass alloc] initWithNormalImage:normal selectedImage:selected disabledImage:disabled block:(void(^)(id sender))js_func];
	
	[proxy setRealObj:real];

	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	
	// "root" object and function
	if( argc >= 4 ) {
		jsb_set_reserved_slot(jsthis, 0, valthis );
		jsb_set_reserved_slot(jsthis, 1, valfn );
	}
	
	return JS_TRUE;
}


#pragma mark - MenuItemSprite

// "create" in JS
JSBool JSB_CCMenuItemSprite_itemWithNormalSprite_selectedSprite_disabledSprite_block__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc >=2 && argc <= 5 && argc != 3, "Invalid number of arguments. 2 <= args <= 5 but not 3" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	CCSprite *normal, *selected, *disabled;
	js_block js_func;
	JSObject *js_this;
	jsval valthis, valfn;
	
	ok &= jsval_to_NSObject( cx, *argvp++, &normal );
	
	if( argc >= 2 )
		ok &= jsval_to_NSObject( cx, *argvp++, &selected );
	
	if( argc == 5 )
		ok &= jsval_to_NSObject( cx, *argvp++, &disabled );
	
	
	// cannot merge with previous if() since argvp needs to be incremented
	if( argc >=4 ) {
		// this
		valthis = *argvp;
		ok &= JS_ValueToObject(cx, *argvp++, &js_this);
		
		// function
		valfn = *argvp;
		ok &= jsval_to_block_1( cx, *argvp++, js_this, &js_func );
	}
	
	CCMenuItemSprite *ret_val;

	if( argc == 2 )
		ret_val = [CCMenuItemSprite itemWithNormalSprite:normal selectedSprite:selected];
	else if (argc == 4 )
		ret_val = [CCMenuItemSprite itemWithNormalSprite:normal selectedSprite:selected block:(void(^)(id sender))js_func];
	else if (argc == 5 )
		ret_val = [CCMenuItemSprite itemWithNormalSprite:normal selectedSprite:selected disabledSprite:disabled block:(void(^)(id sender))js_func];
	
	JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
	// "root" object and function
	if( argc >= 4 ) {
		jsb_set_reserved_slot(jsobj, 0, valthis );
		jsb_set_reserved_slot(jsobj, 1, valfn );
	}
	
	return JS_TRUE;
}

// "init" in JS
JSBool JSB_CCMenuItemSprite_initWithNormalSprite_selectedSprite_disabledSprite_block_(JSContext *cx, uint32_t argc, jsval *vp) {
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject(jsthis);
	
	JSB_PRECONDITION( proxy && [proxy realObj], "Invalid Proxy object");
	JSB_PRECONDITION( argc >=2 && argc <= 5 && argc != 3, "Invalid number of arguments. 2 <= args <= 5 but not 3" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	CCSprite *normal, *selected, *disabled;
	js_block js_func;
	JSObject *js_this;
	jsval valthis, valfn;
	
	ok &= jsval_to_NSObject( cx, *argvp++, &normal );
	
	if( argc >= 2 )
		ok &= jsval_to_NSObject( cx, *argvp++, &selected );
	
	if( argc == 5 )
		ok &= jsval_to_NSObject( cx, *argvp++, &disabled );
	
	
	// cannot merge with previous if() since argvp needs to be incremented
	if( argc >=4 ) {
		// this
		valthis = *argvp;
		ok &= JS_ValueToObject(cx, *argvp++, &js_this);
		
		// function
		valfn = *argvp;
		ok &= jsval_to_block_1( cx, *argvp++, js_this, &js_func );
	}
	
	CCMenuItemSprite *real = nil;
	
	if( argc == 2 )
		real = [(CCMenuItemSprite*)[proxy.klass alloc] initWithNormalSprite:normal selectedSprite:selected disabledSprite:nil target:nil selector:NULL];
	else if (argc == 4 )
		real = [(CCMenuItemSprite*)[proxy.klass alloc] initWithNormalSprite:normal selectedSprite:selected disabledSprite:nil block:(void(^)(id sender))js_func];
	else if (argc == 5 )
		real = [(CCMenuItemSprite*)[proxy.klass alloc] initWithNormalSprite:normal selectedSprite:selected disabledSprite:disabled block:(void(^)(id sender))js_func];
	
	[proxy setRealObj:real];
	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	
	// "root" object and function
	if( argc >= 4 ) {
		jsb_set_reserved_slot(jsthis, 0, valthis );
		jsb_set_reserved_slot(jsthis, 1, valfn );
	}

	return JS_TRUE;
}

#pragma mark - CallFunc

JSBool JSB_CCCallBlockN_actionWithBlock__static(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION( argc == 2 || argc == 3,  "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	js_block js_func;
	JSObject *js_this;
	jsval valthis, valfn;
	
	// this
	valthis = *argvp;
	ok &= JS_ValueToObject(cx, *argvp++, &js_this);
	
	NSObject *ret_val;
	if( argc == 2 ) {
		// function
		valfn = *argvp;
		ok &= jsval_to_block_1( cx, *argvp++, js_this, &js_func );
		if( ! ok )
			return JS_FALSE;
	
		ret_val = [CCCallBlockN actionWithBlock:js_func];
	} else if( argc == 3 ) {

		jsval func = *argvp++;
		jsval arg = *argvp++;
		ok &= jsval_to_block_2( cx, func, js_this, arg, &js_func );
		if( ! ok )
			return JS_FALSE;

		ret_val = [CCCallBlockN actionWithBlock:js_func];
	}
		
	JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
	// "root" object and function
	jsb_set_reserved_slot(jsobj, 0, valthis );
	jsb_set_reserved_slot(jsobj, 1, valfn );
	
	return JS_TRUE;	
}

#pragma mark - Texture2D

JSBool JSB_CCTexture2D_setTexParameters_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject(obj);
	
	JSB_PRECONDITION( proxy && [proxy realObj], "Invalid Proxy object");
	JSB_PRECONDITION( argc == 4, "Invalid number of arguments. Expecting 4 args" );

	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;

	GLint arg0, arg1, arg2, arg3;
	
	ok &= JS_ValueToInt32(cx, *argvp++, &arg0);
	ok &= JS_ValueToInt32(cx, *argvp++, &arg1);
	ok &= JS_ValueToInt32(cx, *argvp++, &arg2);
	ok &= JS_ValueToInt32(cx, *argvp++, &arg3);
	
	if( ! ok )
		return JS_FALSE;
	
	ccTexParams param = { arg0, arg1, arg2, arg3 };

	CCTexture2D *real = (CCTexture2D*) [proxy realObj];
	[real setTexParameters:&param];

	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	
	return JS_TRUE;		
}

#pragma mark - CCDrawNode

// Arguments: Array of points, fill color (ccc4f), width(float), border color (ccc4f)
// Ret value: void
JSBool JSB_CCDrawNode_drawPolyWithVerts_count_fillColor_borderWidth_borderColor_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject(obj);
	
	JSB_PRECONDITION( proxy && [proxy realObj], "Invalid Proxy object");
	JSB_PRECONDITION( argc == 4, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	JSObject *argArray; ccColor4F argFillColor; double argWidth; ccColor4F argBorderColor; 
	
	ok &= JS_ValueToObject(cx, *argvp++, &argArray);
	if( ! (argArray && JS_IsArrayObject(cx, argArray) ) )
	   return JS_FALSE;
	
	JSObject *tmp_arg;
	ok &= JS_ValueToObject( cx, *argvp++, &tmp_arg );
	argFillColor = *(ccColor4F*)JS_GetArrayBufferViewData( tmp_arg, cx );

	ok &= JS_ValueToNumber( cx, *argvp++, &argWidth );
	
	ok &= JS_ValueToObject( cx, *argvp++, &tmp_arg );
	argBorderColor = *(ccColor4F*)JS_GetArrayBufferViewData( tmp_arg, cx );

	if( ! ok )
		return JS_FALSE;
	
	{
		uint32_t l;
		if( ! JS_GetArrayLength(cx, argArray, &l) )
			return JS_FALSE;
		
		CGPoint verts[ l ];
		CGPoint p;

		for( int i=0; i<l; i++ ) {
			jsval pointvp;
			if( ! JS_GetElement(cx, argArray, i, &pointvp) )
				return JS_FALSE;
			if( ! jsval_to_CGPoint(cx, pointvp, &p) )
				continue;
			
			verts[i] = p;
		}
		
		CCDrawNode *real = (CCDrawNode*) [proxy realObj];
		[real drawPolyWithVerts:verts count:l fillColor:argFillColor borderWidth:argWidth borderColor:argBorderColor];
	}
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;	
}

#pragma mark - CCNode

// func, delay
JSBool JSB_CCNode_scheduleOnce_delay_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject(jsthis);

	JSB_PRECONDITION3( proxy && [proxy realObj], cx, JS_FALSE, "Invalid Proxy object");
	JSB_PRECONDITION3( argc == 2, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);

	CCNode *real = (CCNode*) [proxy realObj];
	CCScheduler *scheduler = [real scheduler];

	//
	// "function"
	//
	jsval funcval = *argvp++;
	JSFunction *func = JS_ValueToFunction(cx, funcval);
	JSB_PRECONDITION3( func, cx, JS_FALSE, "Cannot convert Value to Function");

	NSString *key = nil;
	JSString *funcname = JS_GetFunctionId(func);

	// named function
	if( funcname ) {
		char *key_c = JS_EncodeString(cx, funcname);
		key = [NSString stringWithUTF8String:key_c];
	} else {
		// anonymous function
		key = [NSString stringWithFormat:@"anonfunc at %p", func];
	}

	void (^block)(ccTime dt) = ^(ccTime dt) {
		
		jsval rval;
		jsval jsdt = DOUBLE_TO_JSVAL(dt);
		
		JSBool ok = JS_CallFunctionValue(cx, jsthis, funcval, 1, &jsdt, &rval);
		JSB_PRECONDITION2(ok, cx, ,"Error calling collision callback: schedule_interval_repeat_delay");
	};

	//
	// delay
	//
	double delay;
	JSBool ok = JS_ValueToNumber(cx, *argvp++, &delay );
	JSB_PRECONDITION3(ok, cx, JS_FALSE,"Error converting jsval to number");


	[scheduler scheduleBlockForKey:key target:real interval:0 repeat:0 delay:delay paused:![real isRunning] block:block];


	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

// func, [interval], [repeat], [delay]
JSBool JSB_CCNode_schedule_interval_repeat_delay_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject(jsthis);
	
	JSB_PRECONDITION3( proxy && [proxy realObj], cx, JS_FALSE, "Invalid Proxy object");
	JSB_PRECONDITION3( argc >=1 && argc <=4, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);

	CCNode *real = (CCNode*) [proxy realObj];
	CCScheduler *scheduler = [real scheduler];
	
	//
	// "function"
	//
	jsval funcval = *argvp++;
	JSFunction *func = JS_ValueToFunction(cx, funcval);
	JSB_PRECONDITION3( func, cx, JS_FALSE, "Cannot convert Value to Function");

	NSString *key = nil;
	JSString *funcname = JS_GetFunctionId(func);

	// named function
	if( funcname ) {
		char *key_c = JS_EncodeString(cx, funcname);
		key = [NSString stringWithUTF8String:key_c];
	} else {
		// anonymous function
		key = [NSString stringWithFormat:@"anonfunc at %p", func];
	}
	
	void (^block)(ccTime dt) = ^(ccTime dt) {
			
		jsval rval;
		jsval jsdt = DOUBLE_TO_JSVAL(dt);
		
		JSBool ok = JS_CallFunctionValue(cx, jsthis, funcval, 1, &jsdt, &rval);
		JSB_PRECONDITION2(ok, cx, ,"Error calling collision callback: schedule_interval_repeat_delay");
	};
	
	JSBool ok = JS_TRUE;

	//
	// Interval
	//
	double interval;
	if( argc >= 2 )
		ok &= JS_ValueToNumber(cx, *argvp++, &interval );

	//
	// repeat
	//
	double repeat;
	if( argc >= 3 )
		ok &= JS_ValueToNumber(cx, *argvp++, &repeat );


	//
	// delay
	//
	double delay;
	if( argc >= 4 )
		ok &= JS_ValueToNumber(cx, *argvp++, &delay );
		
	JSB_PRECONDITION3(ok, cx, JS_FALSE, "Error converting jsval to native");


	if( argc==1)
		[scheduler scheduleBlockForKey:key target:real interval:0 repeat:kCCRepeatForever delay:0 paused:![real isRunning] block:block];
		
	else if (argc == 2 )
		[scheduler scheduleBlockForKey:key target:real interval:interval repeat:kCCRepeatForever delay:0 paused:![real isRunning] block:block];

	else if (argc == 3 )
		[scheduler scheduleBlockForKey:key target:real interval:interval repeat:repeat delay:0 paused:![real isRunning] block:block];

	else if( argc == 4 )
		[scheduler scheduleBlockForKey:key target:real interval:interval repeat:repeat delay:delay paused:![real isRunning] block:block];
	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

//  func,
JSBool JSB_CCNode_unschedule_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject(jsthis);
	
	JSB_PRECONDITION3( proxy && [proxy realObj], cx, JS_FALSE, "Invalid Proxy object");
	JSB_PRECONDITION3( argc == 1, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	
	CCNode *real = (CCNode*) [proxy realObj];
	CCScheduler *scheduler = [real scheduler];
	
	//
	// "function"
	//
	jsval funcval = *argvp++;
	JSFunction *func = JS_ValueToFunction(cx, funcval);
	JSB_PRECONDITION3( func, cx, JS_FALSE, "Cannot convert Value to Function");
	
	NSString *key = nil;
	JSString *funcname = JS_GetFunctionId(func);
	
	// named function
	if( funcname ) {
		char *key_c = JS_EncodeString(cx, funcname);
		key = [NSString stringWithUTF8String:key_c];
	} else {
		// anonymous function
		key = [NSString stringWithFormat:@"anonfunc at %p", func];
	}
	
	[scheduler unscheduleBlockForKey:key target:real];
		
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

JSBool JSB_CCNode_setPosition_(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject(jsthis);
	
	JSB_PRECONDITION3( proxy && [proxy realObj], cx, JS_FALSE, "Invalid Proxy object");
	JSB_PRECONDITION3( argc == 1 || argc == 2, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	CGPoint arg0;
	
	if( argc == 1) {
		ok &= jsval_to_CGPoint( cx, *argvp++, (CGPoint*) &arg0 );
		JSB_PRECONDITION3(ok, cx, JS_FALSE, "Error processing arguments");
	} else {
		double x, y;
		ok = JS_ValueToNumber(cx, *argvp++, &x);
		ok &= JS_ValueToNumber(cx, *argvp++, &y);
		JSB_PRECONDITION3(ok, cx, JS_FALSE, "Error processing arguments");
		arg0 = ccp(x,y);
	}
	
	CCNode *real = (CCNode*) [proxy realObj];
	[real setPosition:(CGPoint)arg0  ];
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

#pragma mark - CCScheduler

// scheduler.scheduleCallbackForTarget(this, this.onSchedUpdate, interval, repeat, delay, paused);
JSBool JSB_CCScheduler_scheduleBlockForKey_target_interval_repeat_delay_paused_block_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject(jsthis);
	
	JSB_PRECONDITION3( proxy && [proxy realObj], cx, JS_FALSE, "Invalid Proxy object");
	JSB_PRECONDITION3( argc >=2 && argc <=6, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	
	CCScheduler *scheduler = (CCScheduler*) [proxy realObj];
	
	JSBool ok = JS_TRUE;
	
	//
	// arg 0: target
	//
	// XXX: This must be rooted, right?
	JSObject *jstarget = JSVAL_TO_OBJECT(*argvp);
	id target;
	ok &= jsval_to_NSObject(cx, *argvp++, &target);
	
	//
	// arg 1: "function"
	//
	jsval funcval = *argvp++;
	JSFunction *func = JS_ValueToFunction(cx, funcval);
	JSB_PRECONDITION3( func, cx, JS_FALSE, "Cannot convert Value to Function");
	
	NSString *key = nil;
	JSString *funcname = JS_GetFunctionId(func);
	
	// named function
	if( funcname ) {
		char *key_c = JS_EncodeString(cx, funcname);
		key = [NSString stringWithUTF8String:key_c];
	} else {
		// anonymous function
		key = [NSString stringWithFormat:@"anonfunc at %p", func];
	}
	
	void (^block)(ccTime dt) = ^(ccTime dt) {
		
		jsval rval;
		jsval jsdt = DOUBLE_TO_JSVAL(dt);
		
		JSBool ok = JS_CallFunctionValue(cx, jstarget, funcval, 1, &jsdt, &rval);
		JSB_PRECONDITION2(ok, cx, ,"Error calling collision callback: schedule_interval_repeat_delay");
	};

	//
	// arg 2: Interval
	//
	double interval = 0;
	if( argc >= 3 )
		ok &= JS_ValueToNumber(cx, *argvp++, &interval );
	
	//
	// arg 3: repeat
	//
	int32_t repeat = -1;
	if( argc >= 4 )
		ok &= JS_ValueToECMAInt32(cx, *argvp++, &repeat);
	// convert -1 to kCCRepeatForever
	if( repeat == -1)
		repeat = kCCRepeatForever;
	
	//
	// arg 4: delay
	//
	double delay = 0;
	if( argc >= 5 )
		ok &= JS_ValueToNumber(cx, *argvp++, &delay );

	//
	// arg 5: paused
	//
	JSBool paused = JS_FALSE;
	if( argc >= 6 )
		ok &= JS_ValueToBoolean(cx, *argvp++, &paused);

	JSB_PRECONDITION3(ok, cx, JS_FALSE, "Error converting jsval to native");
	
	
	[scheduler scheduleBlockForKey:key target:target interval:interval repeat:repeat delay:delay paused:paused block:block];
	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

#pragma mark - setBlendFunc friends

// setBlendFunc
JSBool JSB_CCParticleSystem_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSB_NSObject *proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject(jsthis);
	
	JSB_PRECONDITION( proxy && [proxy realObj], "Invalid Proxy object");
	JSB_PRECONDITION( argc==2, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	
	id real = (id) [proxy realObj];
	JSBool ok = JS_TRUE;

	GLenum src, dst;
	
	ok &= JS_ValueToInt32(cx, *argvp++, (int32_t*)&src);
	ok &= JS_ValueToInt32(cx, *argvp++, (int32_t*)&dst);
	
	if( ! ok )
		return JS_FALSE;

	[real setBlendFunc:(ccBlendFunc){src, dst}];
	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

JSBool JSB_CCSprite_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSB_CCSpriteBatchNode_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSB_CCMotionStreak_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSB_CCDrawNode_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSB_CCAtlasNode_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSB_CCParticleBatchNode_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSB_CCLayerColor_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

#pragma mark Effects

JSBool JSB_CCLens3D_setPosition_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCNode_setPosition_(cx, argc, vp);
}
JSBool JSB_CCRipple3D_setPosition_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCNode_setPosition_(cx, argc, vp);
}
JSBool JSB_CCTwirl_setPosition_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSB_CCNode_setPosition_(cx, argc, vp);
}

#pragma mark Actions

JSBool JSB_CCBezierBy_actionWithDuration_bezier__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION3( argc == 2, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	double arg0;
	CGPoint *array;
	int numPoints;
	
	ok &= JS_ValueToNumber( cx, *argvp++, &arg0 );
	ok &= jsval_to_array_of_CGPoint(cx, *argvp++, &array, &numPoints);
	
	JSB_PRECONDITION3(ok && numPoints==3, cx, JS_FALSE, "Error processing arguments. Expending an array of 3 elements");
	
	CCBezierTo* ret_val;
	
	ccBezierConfig config;
	config.controlPoint_1 = array[0];
	config.controlPoint_2 = array[1];
	config.endPosition = array[2];
	free(array);
	
	ret_val = [CCBezierBy actionWithDuration:arg0 bezier:config];
	
	JS_SET_RVAL(cx, vp, NSObject_to_jsval(cx, ret_val));
	
	return JS_TRUE;
}

JSBool JSB_CCBezierTo_actionWithDuration_bezier__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION3( argc == 2, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	double arg0;
	CGPoint *array;
	int numPoints;
	
	ok &= JS_ValueToNumber( cx, *argvp++, &arg0 );
	ok &= jsval_to_array_of_CGPoint(cx, *argvp++, &array, &numPoints);
	
	JSB_PRECONDITION3(ok && numPoints==3, cx, JS_FALSE, "Error processing arguments. Expending an array of 3 elements");

	CCBezierTo* ret_val;
	
	ccBezierConfig config;
	config.controlPoint_1 = array[0];
	config.controlPoint_2 = array[1];
	config.endPosition = array[2];
	free(array);
	
	ret_val = [CCBezierTo actionWithDuration:arg0 bezier:config];
	
	JS_SET_RVAL(cx, vp, NSObject_to_jsval(cx, ret_val));
	
	return JS_TRUE;
}

JSBool JSB_CCCardinalSplineBy_actionWithDuration_points_tension__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION3( argc == 3, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	double arg0; double arg2;
	CGPoint *array;
	int numPoints;
	
	ok &= JS_ValueToNumber( cx, *argvp++, &arg0 );
	ok &= jsval_to_array_of_CGPoint(cx, *argvp++, &array, &numPoints);
	ok &= JS_ValueToNumber( cx, *argvp++, &arg2 );
	
	JSB_PRECONDITION3(ok, cx, JS_FALSE, "Error processing arguments");
	CCCardinalSplineTo* ret_val;
	
	CCPointArray *points = [CCPointArray arrayWithCapacity:numPoints];
	for( int i=0; i<numPoints;i++)
		[points addControlPoint:array[i]];
	free(array);
	
	ret_val = [CCCardinalSplineBy actionWithDuration:(ccTime)arg0 points:points tension:(CGFloat)arg2  ];
	
	JS_SET_RVAL(cx, vp, NSObject_to_jsval(cx, ret_val));
	
	return JS_TRUE;
}

// Arguments: ccTime, CCPointArray*, CGFloat
// Ret value: CCCardinalSplineTo* (o)
JSBool JSB_CCCardinalSplineTo_actionWithDuration_points_tension__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION3( argc == 3, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	double arg0; double arg2;
	CGPoint *array;
	int numPoints;
	
	ok &= JS_ValueToNumber( cx, *argvp++, &arg0 );
	ok &= jsval_to_array_of_CGPoint(cx, *argvp++, &array, &numPoints);
	ok &= JS_ValueToNumber( cx, *argvp++, &arg2 );
		
	JSB_PRECONDITION3(ok, cx, JS_FALSE, "Error processing arguments");
	CCCardinalSplineTo* ret_val;
	
	CCPointArray *points = [CCPointArray arrayWithCapacity:numPoints];
	for( int i=0; i<numPoints;i++)
		[points addControlPoint:array[i]];
	free(array);
		
	ret_val = [CCCardinalSplineTo actionWithDuration:(ccTime)arg0 points:points tension:(CGFloat)arg2  ];
	
	JS_SET_RVAL(cx, vp, NSObject_to_jsval(cx, ret_val));
	
	return JS_TRUE;
}

// Arguments: ccTime, CCPointArray*
// Ret value: CCCatmullRomBy* (o)
JSBool JSB_CCCatmullRomBy_actionWithDuration_points__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION3( argc == 2, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	double arg0;
	CGPoint *array;
	int numPoints;
	
	ok &= JS_ValueToNumber( cx, *argvp++, &arg0 );
	ok &= jsval_to_array_of_CGPoint(cx, *argvp++, &array, &numPoints);
	
	JSB_PRECONDITION3(ok, cx, JS_FALSE, "Error processing arguments");
	CCCatmullRomTo* ret_val;
	
	CCPointArray *points = [CCPointArray arrayWithCapacity:numPoints];
	for( int i=0; i<numPoints;i++)
		[points addControlPoint:array[i]];
	free(array);
	
	ret_val = [CCCatmullRomBy actionWithDuration:(ccTime)arg0 points:points  ];
	
	JS_SET_RVAL(cx, vp, NSObject_to_jsval(cx, ret_val));
	
	return JS_TRUE;
}

// Arguments: ccTime, CCPointArray*
// Ret value: CCCatmullRomTo* (o)
JSBool JSB_CCCatmullRomTo_actionWithDuration_points__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION3( argc == 2, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	double arg0;
	CGPoint *array;
	int numPoints;
	
	ok &= JS_ValueToNumber( cx, *argvp++, &arg0 );
	ok &= jsval_to_array_of_CGPoint(cx, *argvp++, &array, &numPoints);

	JSB_PRECONDITION3(ok, cx, JS_FALSE, "Error processing arguments");
	CCCatmullRomTo* ret_val;
	
	CCPointArray *points = [CCPointArray arrayWithCapacity:numPoints];
	for( int i=0; i<numPoints;i++)
		[points addControlPoint:array[i]];
	free(array);
	
	ret_val = [CCCatmullRomTo actionWithDuration:(ccTime)arg0 points:points  ];
	
	JS_SET_RVAL(cx, vp, NSObject_to_jsval(cx, ret_val));
	
	return JS_TRUE;
}

#endif // JSB_INCLUDE_COCOS2D
