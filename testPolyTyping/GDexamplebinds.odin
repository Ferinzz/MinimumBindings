package main


import "base:runtime"
import sics "base:intrinsics"
import "core:fmt"
import GDW "GDWrapper"
import GDE "GDWrapper/gdextension"

main :: proc() {

    value:i64= 20
    myClassInstance: GDExample
    createdFunc, othercallback:= bindNoReturn2(testproc)
    //createdFunc= bindNoReturn2(testproc)
    fmt.println("proc returndd? 1", createdFunc)
    createdFunc(cast(rawptr)&myClassInstance, cast(rawptr)&value)
    createdFunc, othercallback= bindNoReturn2(testproc)
    fmt.println("proc returndd? 2", createdFunc)
    createdFunc(cast(rawptr)&myClassInstance, cast(rawptr)&value)

    createdFunc0, othercallback0:= bindNoReturn2(testproc0)
    fmt.println("proc returndd?", createdFunc0)
    createdFunc0(cast(rawptr)&myClassInstance, cast(rawptr)&value)
    bindNoReturn2(testproc1)

    variantptr: rawptr
    value = fromvariant(&variantptr, type_of(value))
    fmt.println(value)
    fromvariant_P(&variantptr, &value)
    fmt.println(value)
    fmt.println(createdFunc)
    fmt.println(createdFunc0)

    fmt.println("testproc", testproc)
    bindtodind(testproc)
    fmt.println("testproc0", testproc0)
    bindtodind(testproc0)
    fmt.println("testproc1", testproc1)
    bindtodind(testproc1)
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


testproc :: proc "c" (classptr: ^GDExample, arg0: i64) {
    context = runtime.default_context()
    //testproc
    fmt.println("test proc fired")
    classptr.amplitude+=20
    fmt.println(classptr.amplitude)
}

testproc0 :: proc "c" (classptr: ^GDExample) {
    context = runtime.default_context()
    fmt.println("Do something with no variables from Godot.")
}
testproc1 :: proc "c" (classptr: ^GDExample) -> f32 {
    context = runtime.default_context()
    fmt.println("Do something with no variables from Godot.")
    return 32
}

bindtodind:: proc($T: $P) {
    context = runtime.default_context()

    fmt.println("function passed to bindtodind: ", T)
    callback0, call1:= bindNoReturn2(T)

}

//Send callbacks to Godot. For testing I added the return, but this return should go to Godot for it to send back.
bindNoReturn2 :: proc($T: $P, names: ..cstring) -> (ExtensionClassMethodPtrCall, proc "c" (receivedStruct: rawptr, p_instance: rawptr, p_args: [^]rawptr,
                                    p_argument_count: int, r_return: rawptr, r_error: ^GDE.GDExtensionCallError)) where sics.type_is_proc(P)  {
    context = runtime.default_context()
    argcount:: sics.type_proc_parameter_count(P)
    argT0 :: sics.type_proc_parameter_type(P, 0)
    
    fmt.println("my argcount: ",argcount)
    fmt.println("Bind function", T)
    when argcount == 1 {
        godotCallback0 :: proc "c" (receivedStruct: rawptr, value: rawptr){
            context = runtime.default_context()

            func := cast(P)T
            func(cast(argT0)receivedStruct)
        }
        call_1float_arg_no_ret :: proc "c" (receivedStruct: rawptr, p_instance: rawptr, p_args: [^]rawptr,
                                    p_argument_count: int, r_return: rawptr, r_error: ^GDE.GDExtensionCallError) {
    
            context = runtime.default_context()
            //fmt.println("call 1arg ret 0")
            if p_argument_count < argcount-1 {
                r_error.error = .GDEXTENSION_CALL_ERROR_TOO_FEW_ARGUMENTS
                r_error.expected = argcount
                fmt.println("error small")
                return
            }
            if p_argument_count > argcount-1 {
                r_error.error = .GDEXTENSION_CALL_ERROR_TOO_MANY_ARGUMENTS
                r_error.expected = argcount
                fmt.println("error big")
                return
            }
            
            gdTypeList:= [argcount-1]GDE.GDExtensionVariantType {}
            
            variantTypeCheck(gdTypeList[:], p_args[:], r_error)

            arg1: = 32
            
            func := cast(P)T
            func(cast(argT0)receivedStruct)
        }

        
        //Another binding function with GD.Variant to type conversions before making the function call via pointer.
        //Pass pointers to functions created as well as name strings to Godot's registry.
    return godotCallback0, call_1float_arg_no_ret

    } else {
        fmt.println("Some arg count")
        argT1 :: sics.type_proc_parameter_type(P, 1)
        when argcount == 2 {
        godotCallback :: proc "c" (receivedStruct: rawptr, value: rawptr){
            context = runtime.default_context()
            fmt.println("Some arg count")

            variant: GDE.GDExtensionVariantPtr
            fmt.println("return from typechecker",fromvariant(&variant, argT1))
            
            typeList : [argcount-1]GDE.GDExtensionVariantType = {typetoenum(argT1)}
            //nil is not a type so we cannot align to nil and don't need to check for it. I guess?
            type_offset : int : sics.type_variant_index_of(typeUnion, argT1) + 1
            fmt.println(cast(GDE.GDExtensionVariantType)type_offset)

            gdTypeList:= [argcount-1]GDE.GDExtensionVariantType {typetoenum(argT1)}

            args: [^]rawptr
            r_error: GDE.GDExtensionCallError

            variantTypeCheck(gdTypeList[:], args[:], &r_error)

            fmt.println("type to enum: ",typetoenum(argT1))

            

            func := cast(P)T
            func(cast(argT0)receivedStruct,  (cast(^argT1)value)^)
        }
        call_1float_arg_no_ret :: proc "c" (receivedStruct: rawptr, p_instance: rawptr, p_args: [^]rawptr,
                                    p_argument_count: int, r_return: rawptr, r_error: ^GDE.GDExtensionCallError) {
    
            context = runtime.default_context()
            //fmt.println("call 1arg ret 0")
            if p_argument_count < argcount-1 {
                r_error.error = .GDEXTENSION_CALL_ERROR_TOO_FEW_ARGUMENTS
                r_error.expected = argcount
                fmt.println("error small")
                return
            }
            if p_argument_count > argcount-1 {
                r_error.error = .GDEXTENSION_CALL_ERROR_TOO_MANY_ARGUMENTS
                r_error.expected = argcount
                fmt.println("error big")
                return
            }
            
            gdTypeList:= [argcount-1]GDE.GDExtensionVariantType {typetoenum(argT1)}
            
            variantTypeCheck(gdTypeList[:], p_args[:], r_error)

            arg1: argT1 = 32
            
            func := cast(P)T
            func(cast(argT0)receivedStruct, arg1)
        }
        //Another binding function with GD.Variant to type conversions before making the function call via pointer.
        //Pass pointers to functions created as well as name strings to Godot's registry.
    return godotCallback, call_1float_arg_no_ret
    } else {
        argT2 :: sics.type_proc_parameter_type(P, 2)
        when argcount == 3 {
        
        godotCallback :: proc "c" (receivedStruct: rawptr, value: rawptr){
            context = runtime.default_context()

            variant: GDE.GDExtensionVariantPtr
            arg1: int;
            fmt.println("return from typechecker",fromvariant(&variant, arg1))

            func := cast(P)T
            func(cast(argT0)receivedStruct,  (cast(^argT1)value)^, (cast(^argT2)value1)^)
        }
        call_1float_arg_no_ret :: proc "c" (receivedStruct: rawptr, p_instance: rawptr, p_args: [^]rawptr,
                                    p_argument_count: int, r_return: rawptr, r_error: ^GDE.GDExtensionCallError) {
    
            context = runtime.default_context()
            //fmt.println("call 1arg ret 0")
            if p_argument_count < argcount-1 {
                r_error.error = .GDEXTENSION_CALL_ERROR_TOO_FEW_ARGUMENTS
                r_error.expected = argcount
                fmt.println("error small")
                return
            }
            if p_argument_count > argcount-1 {
                r_error.error = .GDEXTENSION_CALL_ERROR_TOO_MANY_ARGUMENTS
                r_error.expected = argcount
                fmt.println("error big")
                return
                    }
            
            typeList : [argcount-1]GDE.GDExtensionVariantType = {GDW.api.variantGetType(p_args[1])}
            variantTypeCheck(gdTypeList[:], args[:], &r_error)

            func := cast(P)T
            func(cast(argT0)receivedStruct, arg1)
        }
        //Another binding function with GD.Variant to type conversions before making the function call via pointer.
        //Pass pointers to functions created as well as name strings to Godot's registry.
    return godotCallback, call_1float_arg_no_ret
    } else {#panic("RIP too many args in ")}

    }
}}


variantTypeCheck :: proc(typeList: []GDE.GDExtensionVariantType, argList: [^]rawptr, r_error: ^GDE.GDExtensionCallError) -> (error: GDE.GDExtensionCallErrorType) {
    error = .GDEXTENSION_CALL_OK
    for type, index in typeList {
        //if type != GDW.api.variantGetType(argList[index]) {
        //    r_error.error = .GDEXTENSION_CALL_ERROR_INVALID_ARGUMENT
        //    r_error.expected = i32(type)
        //    fmt.println("error wrong type")
        //    return
        //}
    }
    return
}


fromvariant :: proc(variant: ^GDE.GDExtensionVariantPtr, $T: typeid) -> T {
    context = runtime.default_context()

    fmt.println("getting variant")
    ret: T
    when T == GDE.Bool{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.BOLL); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.BOOL)
        //construct(&ret, variant)
        ret = 64
    } else when T == GDE.Int {
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.FLOAT); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.INT)
        //construct(&ret, variant)
        ret = 64
    } else when T == f32 {
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.FLOAT); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.FLOAT)
        //construct(&ret, variant)
        ret = 64
    } else when T == String{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.STRING); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.STRING)
        //construct(&ret, variant)
        ret = 64
    }// else when T == Vector2{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR2); fmt.println("int construct set")}
    ///* math types */
    //    //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR2)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Vector2i{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR2I); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR2I)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Rect2 {
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.RECT2); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.RECT2)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Rect2i {
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.RECT2I); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.RECT2I)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Vector3 {
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR3); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR3)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Vector3i {
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR3I); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR3I)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Transform2d {
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.TRANSFORM2D); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.TRANSFORM2D)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Vector4 {
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR4); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR4)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Vector4i {
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR4I); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR4I)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Plane {
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PLANE); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.PLANE)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Quaternion {
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.QUATERNION); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.QUATERNION)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Aabb {
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.AABB); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.AABB)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Basis {
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.BASIS); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.BASIS)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Transform3d {
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.TRANSFORM3D); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.TRANSFORM3D)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Projection {
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PROJECTION); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.PROJECTION)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Color{
    ///* misc types */
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.COLOR); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.COLOR)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == StringName{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.STRING_NAME); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.STRING_NAME)
    //    //construct(&ret, variant)
    //    ret = 64
    //}// else when T == NodePath{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.NODE_PATH); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.NODE_PATH)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Rid{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.RID); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.RID)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Object{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.OBJECT); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.OBJECT)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Callable{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.CALLABLE); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.CALLABLE)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Signal{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.SIGNAL); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.SIGNAL)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Dictionary{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.DICTIONARY); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.DICTIONARY)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Array{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.ARRAY); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.ARRAY)
    //    //construct(&ret, variant)
    //    ret = 64
    //}
    //
    //
    ///* typed arrays */
    //when T == PByteArray{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_BYTE_ARRAY); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_BYTE_ARRAY)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == PI32Array{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_INT32_ARRAY); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_INT32_ARRAY)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Pi64Array{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_INT64_ARRAY); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_INT64_ARRAY)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Pf32Array{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_FLOAT32_ARRAY); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_FLOAT32_ARRAY)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == Pf64Array{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_FLOAT64_ARRAY); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_FLOAT64_ARRAY)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == PStringArray{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_STRING_ARRAY); fmt.println("int construct set")} //NOT ODIN STRING
    //    //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_STRING_ARRAY)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == PVector2Array{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR2_ARRAY); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR2_ARRAY)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == PVector3Array{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR3_ARRAY); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR3_ARRAY)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == PColorArray{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_COLOR_ARRAY); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_COLOR_ARRAY)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == PVector4Array{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR4_ARRAY); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR4_ARRAY)
    //    //construct(&ret, variant)
    //    ret = 64
    //} else when T == VARIANT_MAX{
    //    @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
    //    if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VARIANT_MAX); fmt.println("int construct set")}
    //    //construct := GDW.api.getVariantToTypeConstuctor(.VARIANT_MAX)
    //    //construct(&ret, variant)
    //    ret = 64
    //}

    return ret
}

fromvariant_P :: proc(variant: ^GDE.GDExtensionVariantPtr, ret: $T) where sics.type_is_pointer(T) {
    context = runtime.default_context()
    
    //Could just do this, but if the goal is to prevent an extra allocation, this fails that goal.
    //Doubling the code it is!!
    //ret^ = fromvariant(variant, sics.type_elem_type(T))
    when T == ^GDE.Bool{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.BOLL); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.BOOL)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^i64 {
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.BOOL); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.INT)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^f32{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.FLOAT); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.FLOAT)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^String{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.STRING); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.STRING)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Vector2{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR2); fmt.println("int construct set")}
/* math types */
        //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR2)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Vector2i{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR2I); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR2I)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Rect2{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.RECT2); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.RECT2)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Rect2i{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.RECT2I); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.RECT2I)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Vector3{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR3); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR3)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Vector3i{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR3I); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR3I)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Transform2d{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.TRANSFORM2D); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.TRANSFORM2D)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Vector4{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR4); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR4)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Vector4i{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR4I); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR4I)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Plane{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PLANE); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PLANE)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Quaternion{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.QUATERNION); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.QUATERNION)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Aabb{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.AABB); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.AABB)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Basis{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.BASIS); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.BASIS)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Transform3d{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.TRANSFORM3D); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.TRANSFORM3D)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Projection{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PROJECTION); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PROJECTION)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^StringName{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.STRING_NAME); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.STRING_NAME)
        //construct(&ret, variant)
        ret^ = 64
    } else
    

    /* misc types */
    when T == ^Color{

        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.COLOR); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.COLOR)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^NodePath{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.NODE_PATH); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.NODE_PATH)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Rid{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.RID); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.RID)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Object{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.OBJECT); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.OBJECT)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Callable{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.CALLABLE); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.CALLABLE)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Signal{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.SIGNAL); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.SIGNAL)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Dictionary{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.DICTIONARY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.DICTIONARY)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Array{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.ARRAY)
        //construct(&ret, variant)
        ret^ = 64
    } else
    

    /* typed arrays */
    when T == ^PByteArray{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_BYTE_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_BYTE_ARRAY)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^PI32Array{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_INT32_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_INT32_ARRAY)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Pi64Array{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_INT64_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_INT64_ARRAY)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Pf32Array{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_FLOAT32_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_FLOAT32_ARRAY)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^Pf64Array{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_FLOAT64_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_FLOAT64_ARRAY)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^PStringArray{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_STRING_ARRAY); fmt.println("int construct set")} //NOT ODIN STRING
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_STRING_ARRAY)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^PVector2Array{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR2_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR2_ARRAY)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^PVector3Array{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR3_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR3_ARRAY)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^PColorArray{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_COLOR_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_COLOR_ARRAY)
        //construct(&ret, variant)
        ret^ = 64
    }else when T == ^PVector4Array{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR4_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR4_ARRAY)
        //construct(&ret, variant)
        ret^ = 64
    } else when T == ^VARIANT_MAX{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        //if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VARIANT_MAX); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.VARIANT_MAX)
        //construct(&ret, variant)
        ret^ = 64
    }
    return 
}


//These are going to be very fragile. If th enum changes order, the union will need to change to match it.
//Reduces repetition on the GDW.api side, but might not be great long-term.
typetoenum :: proc($U: typeid) -> GDE.GDExtensionVariantType {
    return cast(GDE.GDExtensionVariantType)(sics.type_variant_index_of(typeUnion, U) + 1)
}

varToEnum :: proc(arg: $T) -> GDE.GDExtensionVariantType {
    return cast(GDE.GDExtensionVariantType)(sics.type_variant_index_of(typeUnion, T) + 1)
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

//Godot only has 'int', so use GDE.Int or i64
typeUnion :: union  {
    bool,
    GDE.Int,
    f32,
    GDE.gdstring,
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

    type : GDE.GDExtensionVariantType = GDW.api.variantGetType(p_args[0])
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


