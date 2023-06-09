package value

import "core:fmt"

/*
Representation of a zen value in Odin. May be one of the values listed
in the union, or nil.
*/
Value :: union {
    bool,
    f64,
}

type_of_value :: proc (value: Value) -> typeid {
    switch v in value {
        case bool: return bool
        case f64: return f64
        case: return nil
    }
}

is_bool :: proc (value: Value) -> bool {
    _, ok := value.(bool)
    return ok
}
is_nil :: proc (value: Value) -> bool { return value == nil }
is_number :: proc (value: Value) -> bool {
    _, ok := value.(f64)
    return ok
}

as_bool :: proc (value: Value) -> bool { return value.(bool) }
as_number :: proc (value: Value) -> f64 { return value.(f64) }

bool_val :: proc (value: bool) -> Value { return Value(value) }
number_val :: proc (value: f64) -> Value { return Value(value) }
nil_val :: proc () -> Value { return Value(nil) }

/* 
A wrapper around a dynamic array that works as a constant pool for values. 
*/
ValueArray :: struct {
    values: [dynamic]Value,
}

/* Initialize the constant pool. */
init_value_array :: proc () -> ValueArray {
    return ValueArray {
        values = make([dynamic]Value, 0, 0),
    }
}

/* Write to the constant pool. */
write_value_array :: proc (a: ^ValueArray, value: Value) {
    append(&a.values, value)
}

/* Free the constant pool's memory. */
free_value_array :: proc (a: ^ValueArray) {
    delete(a.values)
}

/* Print out `value` in a human-readable format. */
print_value :: proc (value: Value) {
    switch v in value {
        case bool: 
            fmt.print(v ? "true" : "false")
        case f64: 
            fmt.printf("%g", v)
        case: fmt.print("nil")
    }
}

/* Determine if two `Value`s are equal. */
values_equal :: proc (a: Value, b: Value) -> bool {
    if type_of_value(a) != type_of_value(b) {
        return false
    }

    switch v in a {
        case bool: return v == as_bool(b)
        case f64: return v == as_number(a)
        case: return true
    }  
}
