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

#ifdef JSB_INCLUDE_COCOSBUILDERREADER

#import "js_bindings_core.h"
#import "js_bindings_CocosBuilderReader_classes.h"
#import "js_bindings_basic_conversions.h"

// Arguments: void (^)(id)
// Ret value: void (None)
JSBool JSB_CCBAnimationManager_setCompletedAnimationCallbackBlock_(JSContext *cx, uint32_t argc, jsval *vp) {
    
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
    
	CCBAnimationManager *real = (CCBAnimationManager*) [proxy realObj];
	[real setCompletedAnimationCallbackBlock:(void(^)(id sender))js_func];
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

#endif // JSB_INCLUDE_COCOSBUILDERREADER

