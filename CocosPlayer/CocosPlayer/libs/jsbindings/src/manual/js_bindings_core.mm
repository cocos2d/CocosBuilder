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


// NS
#import "js_bindings_NS_manual.h"

// cocos2d + chipmunk registration files
#import "js_bindings_cocos2d_registration.h"
#import "js_bindings_chipmunk_registration.h"

#pragma mark - Hash

typedef struct _hashJSObject
{
	JSObject			*jsObject;
	void				*proxy;
	UT_hash_handle		hh;
} tHashJSObject;

static tHashJSObject *hash = NULL;
static tHashJSObject *reverse_hash = NULL;

// Globals
char * JSB_association_proxy_key = NULL;

const char * JSB_version = "0.3-beta";


static void its_finalize(JSFreeOp *fop, JSObject *obj)
{
	CCLOGINFO(@"Finalizing global class");
}

static JSClass global_class = {
	"__global", JSCLASS_GLOBAL_FLAGS,
	JS_PropertyStub, JS_PropertyStub,
	JS_PropertyStub, JS_StrictPropertyStub,
	JS_EnumerateStub, JS_ResolveStub,
	JS_ConvertStub, its_finalize,
	JSCLASS_NO_OPTIONAL_MEMBERS
};

#pragma mark JSBCore - Helper free functions
static void reportError(JSContext *cx, const char *message, JSErrorReport *report)
{
	fprintf(stderr, "%s:%u:%s\n",  
			report->filename ? report->filename : "<no filename=\"filename\">",  
			(unsigned int) report->lineno,  
			message);
};

#pragma mark JSBCore - Free JS functions

JSBool JSBCore_log(JSContext *cx, uint32_t argc, jsval *vp)
{
	if (argc > 0) {
		JSString *string = NULL;
		JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "S", &string);
		if (string) {
			char *cstr = JS_EncodeString(cx, string);
			fprintf(stderr, "%s\n", cstr);
		}
		
		return JS_TRUE;
	}
	return JS_FALSE;
};

JSBool JSBCore_executeScript(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION3(argc==1, cx, JS_FALSE, "Invalid number of arguments in executeScript");

	JSBool ok = JS_FALSE;
	JSString *string;
	if (JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "S", &string) == JS_TRUE) {
		ok = [[JSBCore sharedInstance] runScript: [NSString stringWithCString:JS_EncodeString(cx, string) encoding:NSUTF8StringEncoding] ];
	}

	JSB_PRECONDITION3(ok, cx, JS_FALSE, "Error executing script");

	return ok;
};

JSBool JSBCore_associateObjectWithNative(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION(argc==2, "Invalid number of arguments in associateObjectWithNative");

	
	jsval *argvp = JS_ARGV(cx,vp);
	JSObject *pureJSObj;
	JSObject *nativeJSObj;
	JSBool ok = JS_TRUE;
	ok &= JS_ValueToObject( cx, *argvp++, &pureJSObj );
	ok &= JS_ValueToObject( cx, *argvp++, &nativeJSObj );

	JSB_PRECONDITION3(ok && pureJSObj && nativeJSObj, cx, JS_FALSE, "Error parsing parameters");

	JSB_NSObject *proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject( nativeJSObj );
	jsb_set_proxy_for_jsobject( proxy, pureJSObj );
	[proxy setJsObj:pureJSObj];
		
	return JS_TRUE;
};

JSBool JSBCore_getAssociatedNative(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION3(argc==1, cx, JS_FALSE, "Invalid number of arguments in getAssociatedNative");

	jsval *argvp = JS_ARGV(cx,vp);
	JSObject *pureJSObj;
	JS_ValueToObject( cx, *argvp++, &pureJSObj );
	
	JSB_NSObject *proxy = (JSB_NSObject*) jsb_get_proxy_for_jsobject( pureJSObj );
	id native = [proxy realObj];
	
	JSObject * obj = get_or_create_jsobject_from_realobj(cx, native);
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(obj) );
	
	return JS_TRUE;
};


JSBool JSBCore_platform(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION3(argc==0, cx, JS_FALSE, "Invalid number of arguments in getPlatform");

	JSString * platform;

// iOS is always 32 bits
#ifdef __CC_PLATFORM_IOS
	platform = JS_InternString(cx, "mobile/iOS/32");

// Mac can be 32 or 64 bits
#elif defined(__CC_PLATFORM_MAC)

#ifdef __LP64__
	platform = JS_InternString(cx, "desktop/OSX/64");
#else
	platform = JS_InternString(cx, "desktop/OSX/32");
#endif // 32 or 64

#else // unknown platform
#error "Unsupported platform"
#endif
	jsval ret = STRING_TO_JSVAL(platform);
	
	JS_SET_RVAL(cx, vp, ret);

	return JS_TRUE;
};



/* Register an object as a member of the GC's root set, preventing them from being GC'ed */
JSBool JSBCore_addRootJS(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION3(argc==1, cx, JS_FALSE, "Invalid number of arguments in addRootJS");

	JSObject *o = NULL;
	if (JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "o", &o) == JS_TRUE) {
		if (JS_AddObjectRoot(cx, &o) == JS_FALSE) {
			CCLOGWARN(@"something went wrong when setting an object to the root");
		}
	}
	
	return JS_TRUE;
};

/*
 * removes an object from the GC's root, allowing them to be GC'ed if no
 * longer referenced.
 */
JSBool JSBCore_removeRootJS(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION3(argc==1, cx, JS_FALSE, "Invalid number of arguments in removeRootJS");

	JSObject *o = NULL;
	if (JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "o", &o) == JS_TRUE) {
		JS_RemoveObjectRoot(cx, &o);
	}
	return JS_TRUE;
};

/*
 * Dumps GC
 */
static void dumpNamedRoot(const char *name, void *addr,  JSGCRootType type, void *data)
{
    printf("There is a root named '%s' at %p\n", name, addr);
}
JSBool JSBCore_dumpRoot(JSContext *cx, uint32_t argc, jsval *vp)
{
	// JS_DumpNamedRoots is only available on DEBUG versions of SpiderMonkey.
	// Mac and Simulator versions were compiled with DEBUG.
#if DEBUG && (defined(__CC_PLATFORM_MAC) || TARGET_IPHONE_SIMULATOR )
	JSRuntime *rt = [[JSBCore sharedInstance] runtime];
	JS_DumpNamedRoots(rt, dumpNamedRoot, NULL);
#endif
	return JS_TRUE;
};

/*
 * Force a cycle of GC
 */
JSBool JSBCore_forceGC(JSContext *cx, uint32_t argc, jsval *vp)
{
	JS_GC( [[JSBCore sharedInstance] runtime] );
	return JS_TRUE;
};

JSBool JSBCore_restartVM(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION3(argc==0, cx, JS_FALSE, "Invalid number of arguments in executeScript");
	
	[[JSBCore sharedInstance] restartRuntime];
	return JS_FALSE;
};


@implementation JSBCore

@synthesize globalObject = _object;
@synthesize globalContext = _cx;
@synthesize runtime = _rt;

+ (id)sharedInstance
{
	static dispatch_once_t pred;
	static JSBCore *instance = nil;
	dispatch_once(&pred, ^{
		instance = [[self alloc] init];
	});
	return instance;
}

-(id) init
{
	self = [super init];
	if( self ) {
		
#if DEBUG
		printf("JSB: JavaScript Bindings v%s\n", JSB_version);
#endif
		
		// Must be called only once, and before creating a new runtime
		JS_SetCStringsAreUTF8();
		
		[self createRuntime];
	}
	
	return self;
}

-(void) createRuntime
{
	NSAssert(_rt == NULL && _cx==NULL, @"runtime already created. Reset it first");

	_rt = JS_NewRuntime(8 * 1024 * 1024);
	_cx = JS_NewContext( _rt, 8192);
	JS_SetOptions(_cx, JSOPTION_VAROBJFIX);
	JS_SetVersion(_cx, JSVERSION_LATEST);
	JS_SetErrorReporter(_cx, reportError);
	_object = JS_NewGlobalObject( _cx, &global_class, NULL);
	if (!JS_InitStandardClasses( _cx, _object)) {
		CCLOGWARN(@"js error");
	}

	
	//
	// globals
	//
	JS_DefineFunction(_cx, _object, "require", JSBCore_executeScript, 1, JSPROP_READONLY | JSPROP_PERMANENT);
	JS_DefineFunction(_cx, _object, "__associateObjWithNative", JSBCore_associateObjectWithNative, 2, JSPROP_READONLY | JSPROP_PERMANENT);
	JS_DefineFunction(_cx, _object, "__getAssociatedNative", JSBCore_getAssociatedNative, 2, JSPROP_READONLY | JSPROP_PERMANENT);
	JS_DefineFunction(_cx, _object, "__getPlatform", JSBCore_platform, 0, JSPROP_READONLY | JSPROP_PERMANENT);

	// 
	// Javascript controller (__jsc__)
	//
	JSObject *jsc = JS_NewObject( _cx, NULL, NULL, NULL);
	jsval jscVal = OBJECT_TO_JSVAL(jsc);
	JS_SetProperty(_cx, _object, "__jsc__", &jscVal);

	JS_DefineFunction(_cx, jsc, "garbageCollect", JSBCore_forceGC, 0, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
	JS_DefineFunction(_cx, jsc, "dumpRoot", JSBCore_dumpRoot, 0, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
	JS_DefineFunction(_cx, jsc, "addGCRootObject", JSBCore_addRootJS, 1, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
	JS_DefineFunction(_cx, jsc, "removeGCRootObject", JSBCore_removeRootJS, 1, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
	JS_DefineFunction(_cx, jsc, "executeScript", JSBCore_executeScript, 1, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
	JS_DefineFunction(_cx, jsc, "restart", JSBCore_restartVM, 0, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );

	//
	// 3rd party developer ?
	// Add here your own classes registration
	//
	
	// registers cocos2d, cocosdenshion and cocosbuilder reader bindings
#if JSB_INCLUDE_COCOS2D
	jsb_register_cocos2d(_cx, _object);
#endif // JSB_INCLUDE_COCOS2D
	
	// registers chipmunk bindings
#if JSB_INCLUDE_CHIPMUNK
	jsb_register_chipmunk(_cx, _object);
#endif // JSB_INCLUDE_CHIPMUNK
}

+(void) reportErrorWithContext:(JSContext*)cx message:(NSString*)message report:(JSErrorReport*)report
{
	
}

+(JSBool) logWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp
{
	return JS_TRUE;	
}

+(JSBool) executeScriptWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp
{
	return JS_TRUE;	
}

+(JSBool) addRootJSWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp
{
	return JS_TRUE;
}

+(JSBool) removeRootJSWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp
{
	return JS_TRUE;	
}

+(JSBool) forceGCWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp
{
	return JS_TRUE;
}

-(void) purgeCache
{
    tHashJSObject *current, *tmp;
    HASH_ITER(hh, hash, current, tmp) {
		HASH_DEL(hash, current);
		JSB_NSObject *proxy = (JSB_NSObject*) current->proxy;
		[proxy unrootJSObject];
		free(current);
    }

	HASH_ITER(hh, reverse_hash, current, tmp) {
		HASH_DEL(reverse_hash, current);
		free(current);
    }
}

-(void) shutdown
{
	// clean cache
	[self purgeCache];
	
	JS_DestroyContext(_cx);
	JS_DestroyRuntime(_rt);
	_cx = NULL;
	_rt = NULL;
}

-(void) restartRuntime
{
	[self shutdown];
	[self createRuntime];
}

-(BOOL) evalString:(NSString*)string outVal:(jsval*)outVal
{
	jsval rval;
	JSString *str;
	JSBool ok;
	const char *filename = "noname";
	uint32_t lineno = 0;
	if (outVal == NULL) {
		outVal = &rval;
	}
	const char *cstr = [string UTF8String];
	ok = JS_EvaluateScript( _cx, _object, cstr, (unsigned)strlen(cstr), filename, lineno, outVal);
	if (ok == JS_FALSE) {
		CCLOGWARN(@"error evaluating script:%@", string);
	}
	str = JS_ValueToString( _cx, rval);
	return ok;
}

/*
 * Evaluates an script
 */
-(JSBool) runScript_do_not_use:(NSString*)filename
{
	JSBool ok = JS_FALSE;

	CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];
	NSString *fullpath = [fileUtils fullPathFromRelativePath:filename];

	unsigned char *content = NULL;
	size_t contentSize = ccLoadFileIntoMemory([fullpath UTF8String], &content);
	if (content && contentSize) {
		jsval rval;
		ok = JS_EvaluateScript( _cx, _object, (char *)content, (unsigned)contentSize, [filename UTF8String], 1, &rval);
		free(content);
		
		if (ok == JS_FALSE)
			CCLOGWARN(@"error evaluating script: %@", filename);
	}
	
	return ok;
}

/*
 * This function works OK if it JS_SetCStringsAreUTF8() is called.
 */
-(JSBool) runScript:(NSString*)filename
{
	JSBool ok = JS_FALSE;

	static JSScript *script;
	
	CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];
	NSString *fullpath = [fileUtils fullPathFromRelativePath:filename];

	script = JS_CompileUTF8File(_cx, _object, [fullpath UTF8String] );

	JSB_PRECONDITION(script, "Error compiling script");
		
	const char * name = [[NSString stringWithFormat:@"script %@", filename] UTF8String];
	char *static_name = (char*) malloc(strlen(name)+1);
	strcpy(static_name, name );

    if (!JS_AddNamedScriptRoot(_cx, &script, static_name ) )
        return JS_FALSE;
	
	jsval result;	
	ok = JS_ExecuteScript(_cx, _object, script, &result);
		
    JS_RemoveScriptRoot(_cx, &script);  /* scriptObj becomes unreachable
										   and will eventually be collected. */
	free( static_name);

	JSB_PRECONDITION(ok, "Error executing script");
	
    return ok;
}

-(void) dealloc
{
	[super dealloc];

	JS_DestroyContext(_cx);
	JS_DestroyRuntime(_rt);
	JS_ShutDown();
}
@end


#pragma mark JSObject-> Proxy

// Hash of JSObject -> proxy
void* jsb_get_proxy_for_jsobject(JSObject *obj)
{
	tHashJSObject *element = NULL;
	HASH_FIND_INT(hash, &obj, element);
	
	if( element )
		return element->proxy;
	return nil;
}

void jsb_set_proxy_for_jsobject(void *proxy, JSObject *obj)
{
	NSCAssert( !jsb_get_proxy_for_jsobject(obj), @"Already added. abort");
	
//	printf("Setting proxy for: %p - %p (%s)\n", obj, proxy, [[proxy description] UTF8String] );
	
	tHashJSObject *element = (tHashJSObject*) malloc( sizeof( *element ) );

	// XXX: Do not retain it here.
//	[proxy retain];
	element->proxy = proxy;
	element->jsObject = obj;

	HASH_ADD_INT( hash, jsObject, element );
}

void jsb_del_proxy_for_jsobject(JSObject *obj)
{
	tHashJSObject *element = NULL;
	HASH_FIND_INT(hash, &obj, element);
	if( element ) {		
		HASH_DEL(hash, element);
		free(element);
	}
}

#pragma mark Proxy -> JSObject

// Reverse hash: Proxy -> JSObject
JSObject* jsb_get_jsobject_for_proxy(void *proxy)
{
	tHashJSObject *element = NULL;
	HASH_FIND_INT(reverse_hash, &proxy, element);
	
	if( element )
		return element->jsObject;
	return NULL;
}

void jsb_set_jsobject_for_proxy(JSObject *jsobj, void* proxy)
{
	NSCAssert( !jsb_get_jsobject_for_proxy(proxy), @"Already added. abort");
	
	tHashJSObject *element = (tHashJSObject*) malloc( sizeof( *element ) );
	
	element->proxy = proxy;
	element->jsObject = jsobj;
	
	HASH_ADD_INT( reverse_hash, proxy, element );
}

void jsb_del_jsobject_for_proxy(void* proxy)
{
	tHashJSObject *element = NULL;
	HASH_FIND_INT(reverse_hash, &proxy, element);
	if( element ) {		
		HASH_DEL(reverse_hash, element);
		free(element);
	}	
}

#pragma mark


JSBool jsb_set_reserved_slot(JSObject *obj, uint32_t idx, jsval value)
{
	JSClass *klass = JS_GetClass(obj);
	NSUInteger slots = JSCLASS_RESERVED_SLOTS(klass);
	if( idx >= slots )
		return JS_FALSE;
	
	JS_SetReservedSlot(obj, idx, value);
	
	return JS_TRUE;
}

#pragma mark "C" proxy functions

struct jsb_c_proxy_s* jsb_get_c_proxy_for_jsobject( JSObject *jsobj )
{
	struct jsb_c_proxy_s *proxy = (struct jsb_c_proxy_s *) JS_GetPrivate(jsobj);

	// DO not assert. This might be called from "finalize".
	// "finalize" could be called from a VM restart, and it is possible that no proxy was
	// associated with the jsobj yet
	if( ! proxy )
		CCLOGWARN(@"Could you find proxy for jsboject: %p ", jsobj);

	return proxy;
}

void jsb_del_c_proxy_for_jsobject( JSObject *jsobj )
{
	struct jsb_c_proxy_s *proxy = (struct jsb_c_proxy_s *) JS_GetPrivate(jsobj);
	NSCAssert(proxy, @"Invalid proxy for JSObject");
	JS_SetPrivate(jsobj, NULL);
	
	free(proxy);
}

void jsb_set_c_proxy_for_jsobject( JSObject *jsobj, void *handle, unsigned long flags)
{
	struct jsb_c_proxy_s *proxy = (struct jsb_c_proxy_s*) malloc(sizeof(*proxy));
	NSCAssert(proxy, @"No memory for proxy");
	
	proxy->handle = handle;
	proxy->flags = flags;
	proxy->jsobj = jsobj;
	
	JS_SetPrivate(jsobj, proxy);
}


#pragma mark Do Nothing - Callbacks

JSBool JSB_do_nothing(JSContext *cx, uint32_t argc, jsval *vp)
{
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}
