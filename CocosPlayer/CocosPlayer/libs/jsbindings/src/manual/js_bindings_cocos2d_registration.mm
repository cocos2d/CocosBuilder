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
#import "js_bindings_core.h"


// cocos2d
#import "js_bindings_cocos2d_classes.h"
#import "js_bindings_cocos2d_functions.h"
#ifdef __CC_PLATFORM_IOS
#import "js_bindings_cocos2d_ios_classes.h"
#import "js_bindings_cocos2d_ios_functions.h"
#elif defined(__CC_PLATFORM_MAC)
#import "js_bindings_cocos2d_mac_classes.h"
#import "js_bindings_cocos2d_mac_functions.h"
#endif

// CocosDenshion
#import "js_bindings_CocosDenshion_classes.h"

// CocosBuilder reader
#import "js_bindings_CocosBuilderReader_classes.h"

void jsb_register_cocos2d_config( JSContext *_cx, JSObject *cocos2d);

void jsb_register_cocos2d_config( JSContext *_cx, JSObject *cocos2d)
{
	// Config Object
	JSObject *ccconfig = JS_NewObject(_cx, NULL, NULL, NULL);
	// config.os: The Operating system
	// osx, ios, android, windows, linux, etc..
#ifdef __CC_PLATFORM_MAC
	JSString *str = JS_InternString(_cx, "osx");
#elif defined(__CC_PLATFORM_IOS)
	JSString *str = JS_InternString(_cx, "ios");
#endif
	JS_DefineProperty(_cx, ccconfig, "os", STRING_TO_JSVAL(str), NULL, NULL, JSPROP_ENUMERATE | JSPROP_READONLY | JSPROP_PERMANENT);
	
	// config.deviceType: Device Type
	// 'mobile' for any kind of mobile devices, 'desktop' for PCs, 'browser' for Web Browsers
#ifdef __CC_PLATFORM_MAC
	str = JS_InternString(_cx, "desktop");
#elif defined(__CC_PLATFORM_IOS)
	str = JS_InternString(_cx, "mobile");
#endif
	JS_DefineProperty(_cx, ccconfig, "deviceType", STRING_TO_JSVAL(str), NULL, NULL, JSPROP_ENUMERATE | JSPROP_READONLY | JSPROP_PERMANENT);
	
	// config.engine: Type of renderer
	// 'cocos2d', 'cocos2d-x', 'cocos2d-html5/canvas', 'cocos2d-html5/webgl', etc..
	str = JS_InternString(_cx, "cocos2d");
	JS_DefineProperty(_cx, ccconfig, "engine", STRING_TO_JSVAL(str), NULL, NULL, JSPROP_ENUMERATE | JSPROP_READONLY | JSPROP_PERMANENT);
	
	// config.arch: CPU Architecture
	// i386, ARM, x86_64, web
#ifdef __LP64__
	str = JS_InternString(_cx, "x86_64");
#elif defined(__arm__) || defined(__ARM_NEON__)
	str = JS_InternString(_cx, "arm");
#else
	str = JS_InternString(_cx, "i386");
#endif
	JS_DefineProperty(_cx, ccconfig, "arch", STRING_TO_JSVAL(str), NULL, NULL, JSPROP_ENUMERATE | JSPROP_READONLY | JSPROP_PERMANENT);
	
	// config.version: Version of cocos2d + renderer
	str = JS_InternString(_cx, [cocos2dVersion() UTF8String] );
	JS_DefineProperty(_cx, ccconfig, "version", STRING_TO_JSVAL(str), NULL, NULL, JSPROP_ENUMERATE | JSPROP_READONLY | JSPROP_PERMANENT);
	
	// config.usesTypedArrays
#if JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES
	JSBool b = JS_FALSE;
#else
	JSBool b = JS_TRUE;
#endif
	JS_DefineProperty(_cx, ccconfig, "usesTypedArrays", BOOLEAN_TO_JSVAL(b), NULL, NULL, JSPROP_ENUMERATE | JSPROP_READONLY | JSPROP_PERMANENT);
	
	// config.debug: Debug build ?
#ifdef DEBUG
	b = JS_TRUE;
#else
	b = JS_FALSE;
#endif
	JS_DefineProperty(_cx, ccconfig, "debug", BOOLEAN_TO_JSVAL(b), NULL, NULL, JSPROP_ENUMERATE | JSPROP_READONLY | JSPROP_PERMANENT);
	
	
	// Add "config" to "cc"
	JS_DefineProperty(_cx, cocos2d, "config", OBJECT_TO_JSVAL(ccconfig), NULL, NULL, JSPROP_ENUMERATE | JSPROP_READONLY | JSPROP_PERMANENT);
	
	
	JS_DefineFunction(_cx, cocos2d, "log", JSBCore_log, 0, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
	
	JSB_NSObject_createClass(_cx, cocos2d, "Object");
#ifdef __CC_PLATFORM_MAC
	JSB_NSEvent_createClass(_cx, cocos2d, "Event");
#elif defined(__CC_PLATFORM_IOS)
	JSB_UITouch_createClass(_cx, cocos2d, "Touch");
	JSB_UIAccelerometer_createClass(_cx, cocos2d, "Accelerometer");
#endif	
}

void jsb_register_cocos2d( JSContext *_cx, JSObject *object)
{
	//
	// cocos2d
	//
	JSObject *cocos2d = JS_NewObject(_cx, NULL, NULL, NULL);
	jsval cocosVal = OBJECT_TO_JSVAL(cocos2d);
	JS_SetProperty(_cx, object, "cc", &cocosVal);
	

	// register "config" object
	jsb_register_cocos2d_config(_cx, cocos2d);

	
	// Register classes: base classes should be registered first

#import "js_bindings_cocos2d_classes_registration.h"
#import "js_bindings_cocos2d_functions_registration.h"

#ifdef __CC_PLATFORM_IOS
	JSObject *cocos2d_ios = cocos2d;
#import "js_bindings_cocos2d_ios_classes_registration.h"
#import "js_bindings_cocos2d_ios_functions_registration.h"
#elif defined(__CC_PLATFORM_MAC)
	JSObject *cocos2d_mac = cocos2d;
#import "js_bindings_cocos2d_mac_classes_registration.h"
#import "js_bindings_cocos2d_mac_functions_registration.h"
#endif
	
	//
	// CocosDenshion
	//
	// Reuse "cc" namespace for CocosDenshion
	JSObject *CocosDenshion = cocos2d;
#import "js_bindings_CocosDenshion_classes_registration.h"

	//
	// CocosBuilderReader
	//
	// Reuse "cc" namespace for CocosBuilderReader
	JSObject *CocosBuilderReader = cocos2d;
#import "js_bindings_CocosBuilderReader_classes_registration.h"

}
