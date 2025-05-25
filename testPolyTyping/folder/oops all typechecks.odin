#+build ignore

package other

import GDE "GDWrapper/gdextension"

    when T == ^GDE.Bool{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.BOLL); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.BOOL)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^i64 || T == ^Int {
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.BOLL); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.INT)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^f32{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.FLOAT); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.FLOAT)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^String{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.STRING); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.STRING)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Vector2{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR2); fmt.println("int construct set")}
/* math types */
        //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR2)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Vector2i{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR2I); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR2I)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Rect2{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.RECT2); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.RECT2)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Rect2i{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.RECT2I); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.RECT2I)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Vector3{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR3); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR3)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Vector3i{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR3I); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR3I)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Transform2d{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.TRANSFORM2D); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.TRANSFORM2D)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Vector4{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR4); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR4)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Vector4i{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VECTOR4I); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.VECTOR4I)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Plane{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PLANE); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PLANE)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Quaternion{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.QUATERNION); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.QUATERNION)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Aabb{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.AABB); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.AABB)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Basis{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.BASIS); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.BASIS)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Transform3d{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.TRANSFORM3D); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.TRANSFORM3D)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Projection{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PROJECTION); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PROJECTION)
        //construct(&ret, variant)
        ret = 64
    }
    

    //construct := GDW.api.getVariantToTypeConstuctor(./* misc types */
    when T == ^Color{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.COLOR); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.COLOR)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^StringName{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.STRING_NAME); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.STRING_NAME)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^NodePath{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.NODE_PATH); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.NODE_PATH)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Rid{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.RID); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.RID)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Object{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.OBJECT); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.OBJECT)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Callable{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.CALLABLE); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.CALLABLE)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Signal{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.SIGNAL); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.SIGNAL)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Dictionary{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.DICTIONARY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.DICTIONARY)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Array{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.ARRAY)
        //construct(&ret, variant)
        ret = 64
    }
    

    //construct := GDW.api.getVariantToTypeConstuctor(./* typed arrays */
    when T == ^PByteArray{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_BYTE_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_BYTE_ARRAY)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^PI32Array{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_INT32_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_INT32_ARRAY)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Pi64Array{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_INT64_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_INT64_ARRAY)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Pf32Array{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_FLOAT32_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_FLOAT32_ARRAY)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^Pf64Array{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_FLOAT64_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_FLOAT64_ARRAY)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^PStringArray{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_STRING_ARRAY); fmt.println("int construct set")} //NOT ODIN STRING
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_STRING_ARRAY)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^PVector2Array{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR2_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR2_ARRAY)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^PVector3Array{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR3_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR3_ARRAY)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^PColorArray{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_COLOR_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_COLOR_ARRAY)
        //construct(&ret, variant)
        ret = 64
    }else when T == ^PVector4Array{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR4_ARRAY); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.PACKED_VECTOR4_ARRAY)
        //construct(&ret, variant)
        ret = 64
    } else when T == ^VARIANT_MAX{
        @(static)construct: GDE.GDExtensionTypeFromVariantConstructorFunc
        if construct == nil {construct = GDW.api.getVariantToTypeConstuctor(.VARIANT_MAX); fmt.println("int construct set")}
        //construct := GDW.api.getVariantToTypeConstuctor(.VARIANT_MAX)
        //construct(&ret, variant)
        ret = 64
    }