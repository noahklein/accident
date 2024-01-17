package box2d

// References a world instance
World_ID :: struct
{
	index: i16,
	revision: u16,
}

// References a rigid body instance
Body_ID :: struct
{
	index: i32,
	world: i16,
	revision: u16,
}

// References a shape instance
Shape_ID :: struct
{
	index: i32,
	world: i16,
	revision: u16,
}

// References a joint instance
Joint_ID :: struct
{
	index: i32,
	world: i16,
	revision: u16,
}

Chain_ID :: struct
{
	index: i32,
	world: i16,
	revision: u16,
}

NULL_WORLD_ID :: World_ID{-1, 0}
NULL_BODY_ID :: Body_ID{-1, -1, 0}
NULL_SHAPE_ID :: Shape_ID{-1, -1, 0}
NULL_JOINT_ID :: Joint_ID{-1, -1, 0}
NULL_CHAIN_ID :: Chain_ID{-1, -1, 0}

is_null :: #force_inline proc "contextless" (id: $T) -> bool
{
    return id.index == -1
}

non_null :: #force_inline proc "contextless" (id: $T) -> bool
{
    return id.index != -1
}

// Compare two ids for equality. Doesn't work for World_ID.
id_equals :: #force_inline proc "contextless" (id1, id2: $T) -> bool
{
    return id1.index == id2.index && id1.world == id2.world && id1.revision == id2.revision
}