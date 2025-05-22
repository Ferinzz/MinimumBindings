package main


import "base:runtime"
import sics "base:intrinsics"
import "core:fmt"

main :: proc() {

    createdFunc:= bindNoReturn2(testproc)
    fmt.println("proc returndd?", createdFunc)
    myClassInstance: GDExample
    value:int= 20
    createdFunc(cast(rawptr)&myClassInstance, cast(rawptr)&value)

    createdFunc0:= bindNoReturn2(testproc0)
    fmt.println("proc returndd?", createdFunc0)
    createdFunc0(cast(rawptr)&myClassInstance, cast(rawptr)&value)
}

//Defines things like variables, methods, class names. It's a unique ID generated from a string which will be used to match with the correct thing on Godot side.
StringName :: struct{
    data: [8]u8
}

//The format of Godot's call functions are all the same. This is pseudo code. Normally arguments passed to my library are passed in [^]rawptr
ExtensionClassMethodPtrCall :: #type proc "c" (
    classPtr: rawptr,
    value: rawptr
)

//Struct to hold node instance's data. Pointer to this is passed to Godot and passed back and forth to/from the extension.
//This struct should hold the class variables. (following the C guide)
//Make a new one for each instance that gets created.
GDExample :: struct{
    //public properties. Could be functions pointers?
    amplitude: f64,
    speed: f64,
    object: rawptr, //Stores the underlying Godot data. //Set in gdexampleClassCreateInstance.

    //''''''private''''''' variables.
    timePassed: f64,
    time_emit: f64,

    //Metadata
    position_changed: StringName, //Specifies the signal StringName used in class.StringName.connect(func_to_call). 
}


testproc :: proc(classptr: ^GDExample, arg0: int) {
    //testproc
    fmt.println("test proc fired")
    classptr.amplitude+=20
    fmt.println(classptr.amplitude)
}

testproc0 :: proc(classptr: ^GDExample) {
    fmt.println("Do something with no variables from Godot.")
}

//Send callbacks to Godot. For testing I added the return, but this return should go to Godot for it to send back.
bindNoReturn2 :: proc($T: $P) -> ExtensionClassMethodPtrCall where sics.type_is_proc(P)  {
    context = runtime.default_context()
    argcount:: sics.type_proc_parameter_count(P)
    
    when argcount == 1 {
        arg0 :: sics.type_proc_parameter_type(P, 0)
        godotCallback0 :: proc "c" (receivedStruct: rawptr, value: rawptr){
            context = runtime.default_context()

            func := cast(P)T
            func(cast(arg0)receivedStruct)
        }
        //Another binding function with GD.Variant to type conversions before making the function call via pointer.
        //Pass pointers to functions created as well as name strings to Godot's registry.
    return godotCallback0

    } else when argcount == 2{
        
        //index:: sics.type_proc_parameter_count(P)-2
        //index1:: sics.type_proc_parameter_count(P)-1
        arg0 :: sics.type_proc_parameter_type(P, 0)
        arg1 :: sics.type_proc_parameter_type(P, 1)
        
        godotCallback :: proc "c" (receivedStruct: rawptr, value: rawptr){
            context = runtime.default_context()

            func := cast(P)T
            func(cast(arg0)receivedStruct, (cast(^arg1)value)^)
        }
        //Another binding function with GD.Variant to type conversions before making the function call via pointer.
        //Pass pointers to functions created as well as name strings to Godot's registry.
    return godotCallback
    } 

}

GDExtensionCallErrorType :: enum {
	GDEXTENSION_CALL_OK,
	GDEXTENSION_CALL_ERROR_INVALID_METHOD,
	GDEXTENSION_CALL_ERROR_INVALID_ARGUMENT, // Expected a different variant type.
	GDEXTENSION_CALL_ERROR_TOO_MANY_ARGUMENTS, // Expected lower number of arguments.
	GDEXTENSION_CALL_ERROR_TOO_FEW_ARGUMENTS, // Expected higher number of arguments.
	GDEXTENSION_CALL_ERROR_INSTANCE_IS_NULL,
	GDEXTENSION_CALL_ERROR_METHOD_NOT_CONST, // Used for const call.
}


typeUnion :: union {
    int, bool, i32, i64, ^GDExample, f32, f64, 
}


/*
The info about the method that we pass to Godot.
Needs a pointer to a function that it can call which can handle pointer variables and another which can handle pointer to variant types
GDExtensionClassMethodInfo :: struct {
	name: GDExtensionStringNamePtr, //name of your function. cstring -> StringName
	method_userdata: rawptr, //pointer to proc
	call_func: GDExtensionClassMethodCall, //function that converts the [^]args from Variants to type_id
	ptrcall_func: GDExtensionClassMethodPtrCall, //function that converts the [^]args to type_id
	method_flags: u32, // Bitfield of `GDExtensionClassMethodFlags`.

	/* If `has_return_value` is false, `return_value_info` and `return_value_metadata` are ignored.
     */,
	has_return_value: GDExtensionBool, 
	return_value_info: ^GDExtensionPropertyInfo, //Pointer to type info of return.
	return_value_metadata: GDExtensionClassMethodArgumentMetadata, //Not certain how this is used.

	/* Arguments: `arguments_info` and `arguments_metadata` are array of size `argument_count`.
	 * Name and hint information for the argument can be omitted in release builds. Class name should always be present if it applies.
	 *
	 */
	argument_count: u32, //number of arguments that Godot should send
	arguments_info: [^]GDExtensionPropertyInfo, //PropInfo with just Name and Type
	arguments_metadata: ^GDExtensionClassMethodArgumentMetadata, //an array of argumentMetadata enum

	/* Default arguments: `default_arguments` is an array of size `default_argument_count`. */
	default_argument_count: u32, //How to use?
	default_arguments: ^GDExtensionVariantPtr, //
}

//EXAMPLE CALLS GODOT WILL MAKE.
//Extension will need to figure out to what proc the rawptr method_userdata is referring.
//Extension will need to know how to cast method_userdata to the correct proc type.
//Extension will need to figure out know to what types to cast the different variables.
//Extension will need to know how many variables there are in the [^]rawptr of p_args

ptrcall_1_float_arg_no_ret :: proc "c" (method_userdata: rawptr, p_instance: rawptr, p_args: [^]rawptr, r_ret: rawptr){
    context = runtime.default_context()
    //fmt.println("point 1float 0ret")
    //I need to handle the argument types when passing them to the function. Then return nothing.
    
    function : proc "c" (rawptr, f64) = cast(proc "c" (rawptr, f64))method_userdata
    function(p_instance, (cast(^f64)p_args[0])^)
}

//Will either need to store the variant type to skip the variantGetType or just do it anyways for error checking.
//In either case we need to know what type it >should< be.
//Extension will need to figure out what proc the method_userdata is referring to.
//Extension will need to know how to cast method_userdata to the correct proc type.
call_1float_arg_no_ret :: proc "c" (method_userdata: rawptr, p_instance: rawptr, p_args: [^]rawptr,
                                    p_argument_count: int, r_return: rawptr, r_error: ^GDExtensionCallError) {
    
    context = runtime.default_context()
    //fmt.println("call 1arg ret 0")
    if p_argument_count < 1 {
        r_error.error = .GDEXTENSION_CALL_ERROR_TOO_FEW_ARGUMENTS
        r_error.expected = 1
        fmt.println("error small")
        return
    }
    if p_argument_count > 1 {
        r_error.error = .GDEXTENSION_CALL_ERROR_TOO_MANY_ARGUMENTS
        r_error.expected = 1
        fmt.println("error big")
        return
    }

    type : GDE.GDExtensionVariantType = api.variantGetType(p_args[0])
    if type != .FLOAT {
        r_error.error = .GDEXTENSION_CALL_ERROR_INVALID_ARGUMENT
        r_error.expected = i32(GDE.GDExtensionVariantType.FLOAT)
        fmt.println("error wrong type")
        return
    }
    
    // Extract the argument.
    arg1: f64;
    constructor.floatFromVariant(&arg1, cast(GDE.GDExtensionVariantPtr)p_args[0]);
    //Variants are special things, so probably do just need to rely on Godot's type conversion.
    fmt.println("Variant from Godot: ",arg1)

    //Call function.
    function: proc "c" (rawptr, f64) = cast(proc "c" (rawptr, f64))method_userdata
    function(p_instance, arg1)
}
*/

//Random testing things. Of note, the intrinsic.type_base_type says that it uses typeid but in actuallity it only uses types.

/*
//Was testing all the different ways to try and store the type info.
//Ultimately there's really only one way to do it.
bindNoReturn2 :: proc($T: $P) -> ExtensionClassMethodPtrCall where sics.type_is_proc(P)  {
    context = runtime.default_context()
    argcount:: sics.type_proc_parameter_count(P)
    

    when argcount == 2{
        
        //index:: sics.type_proc_parameter_count(P)-2
        //index1:: sics.type_proc_parameter_count(P)-1
        arg0 :: sics.type_proc_parameter_type(P, 0)
        arg1 :: sics.type_proc_parameter_type(P, 1)
        Proc :: #type proc(self: arg0, argument: arg1)
    //proc(method_userdata: rawptr, p_instance: rawptr, p_args: [^]rawptr, r_ret: rawptr){
    godotCallback :: proc(){
        context = runtime.default_context()
        //Do weird Godot calling stuff.
        //change variant based on myType. cast to 
        argCount:: argcount
        argT0:arg0
        argT1:arg1=0
        method_userdata: rawptr
        //args2:= [argcount]runtime.Type_Info {type_info_of(arg0)^, type_info_of(arg1)^}
        args2:= [2]typeid {typeid_of(arg0), typeid_of(arg1)}
        arrrg:= [2]any {argT0, argT1}
        meth:= arrrg[1]
        for arg, index in args2{
            //meth:= cast(^f32)method_userdata //This is fine
            //meth:= cast(f32)method_userdata //This is fine
            //meth:= cast(type_of(argT0))method_userdata //This is fine
            //fmt.println(arg) //Prints ^GDExample then int -> These are types?
            //fmt.println(type_info_of(arg)) //Prints ^GDExample then int
            //fmt.println(typeid_of(arg)) //Error Error: Expected a type for 'typeid_of' 
            //fmt.println(type_of(arg)) //Error: Cannot assign 'typeid', a type, to a procedure argument -> type of a type is typeid.
            //meth:= cast(arg)method_userdata //Error: Expected a type, got arg -> But arg is a typeid?
            //meth:= cast(type_of(arg))method_userdata //Error: Cannot cast 'method_userdata' as 'typeid' from 'rawptr' -> so it doesn't know the type of arg?
            //meth:= cast(^type_of(arg))method_userdata //I'm allowed to do this.
            //fmt.println(typeid_of(type_of(meth))) //Error: cannot assign '^typeid', a type, to a procedure argument
            //meth:= cast(^(type_info_of(arg).id))method_userdata //Expected a type, got type_info_of(arg) 
            //meth:= cast(type_of(type_info_of(arg).id))method_userdata //Error: Cannot cast 'method_userdata' as 'typeid' from 'rawptr' 
            //fmt.println(type_info_of(arg).id) //Prints ^GDExample then int
            //fmt.println(meth)
            //fmt.println(arg.id)
            //meth:= cast(type_of(argT0))method_userdata
            //meth:= cast(arg.?)method_userdata
            //fmt.println(meth)
        }
        point:=cast(^int)meth.data
        point^+=1
        //sics.type_base_type(args2[0])
        //args2[0]
        getType:sics.type_base_type(type_of(argT1))=2
        fmt.println("nothing?", getType)
        receivedStruct: GDExample
        
        p_instance: rawptr
        //[argcount]typeid{myType0, myType}
        func := cast(P)T

        //argtemp:typeid= args2[0]
        //meth:= (cast(args2[0])method_userdata)
        //meth:= (cast(argtemp)method_userdata)
        func(&receivedStruct, argT1)
        p_args: [^]rawptr
        //func(cast(args2[0])p_instance, (cast(args2[1].(type))p_args[0])^)
        fmt.println("arguments: ", args2) //prints arguments:  [^GDExample, int]
    }
    return godotCallback
        

} else when argcount == 0 {
    godotCallback0 :: proc(){
        context = runtime.default_context()
        //Do weird Godot calling stuff.
        //change variant based on myType. cast to 
        argCount:: argcount
        //[argcount]typeid{myType0, myType}
        //func := cast(P)method_userdata
        //func(cast(myType0)p_instance, (cast(^myType)p_args[0])^)
        fmt.println("arguments: ", argCount)
    }
    godotCallback0()

    }


    //Another binding function with GD.Variant to type conversions before making the function call via pointer.

    //fmt.println("a whole new function: ",godotCallback)

    //Pass pointers to bindingfunc and other values to Godot registry.
}*/


