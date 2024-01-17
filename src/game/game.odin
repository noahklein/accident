package game

import "core:math/linalg"
import "core:runtime"
import rl "vendor:raylib"
import b2 "../odin-box2d"

import "../rlutil"

DT :: 1.0 / 60.0

world: World

World :: struct {
    id: b2.World_ID,
    bodies: [dynamic]b2.Body_ID,
    dt_acc: f32,
}

init :: proc() {
    world_def := b2.DEFAULT_WORLD_DEF
    world_def.gravity = {0, 10}
    world.id = b2.create_world(&world_def)

    ground_body_def := b2.DEFAULT_BODY_DEF
    ground_body_def.position = b2.Vec2{0, 10}
    ground_body_id := b2.create_body(world.id, &ground_body_def)

    ground_box := b2.make_box(50, 10)
    ground_shape_def := b2.DEFAULT_SHAPE_DEF
    b2.create_polygon_shape(ground_body_id, &ground_shape_def, &ground_box)
}

deinit :: proc() {
    b2.destroy_world(world.id)
    delete(world.bodies)
}

update :: proc(dt: f32, cursor: rl.Vector2) {
    if rl.IsMouseButtonPressed(.LEFT) {
        body_def := b2.DEFAULT_BODY_DEF
        body_def.type = .Dynamic
        body_def.position = cursor
        body_id := b2.create_body(world.id, &body_def)

        shape := b2.DEFAULT_SHAPE_DEF
        shape.density = 1
        shape.friction = 0.3
        circle := b2.Circle{ radius = 1 }

        b2.create_circle_shape(body_id, &shape, &circle)
        append(&world.bodies, body_id)
    }

    world.dt_acc += dt
    for world.dt_acc >= DT {
        world.dt_acc -= DT
        fixed_update(cursor)
    }
}

fixed_update :: proc(cursor: rl.Vector2) {
    b2.world_step(world.id, DT, velocity_iterations = 8, position_iterations = 3)
}

draw :: proc(cursor: rl.Vector2) {
    b2.world_draw(world.id, &debug_draw)
}

debug_draw := b2.Debug_Draw{
    draw_polygon = draw_polygon,
    draw_solid_polygon = draw_solid_polygon,
    draw_circle = draw_circle,
    draw_solid_circle = draw_solid_circle,
    draw_segment = draw_segment,
    draw_point = draw_point,

    draw_shapes = true,
}

draw_polygon :: proc "c" (vertices: [^]b2.Vec2, vertex_count: i32, color: b2.Color, context_: rawptr) {
    context = runtime.default_context()

    rlutil.DrawPolygonLines(vertices[:vertex_count], b2_color_to_rl(color))
}

draw_solid_polygon :: proc "c" (vertices: [^]b2.Vec2, vertex_count: i32, color: b2.Color, context_: rawptr) {
    context = runtime.default_context()
    rlutil.DrawPolygonLines(vertices[:vertex_count], b2_color_to_rl(color))
}

draw_circle :: proc "c" (center: b2.Vec2, radius: f32, color: b2.Color, context_: rawptr) {
    rl.DrawCircleV(center, radius, b2_color_to_rl(color))
}

draw_solid_circle :: proc "c" (center: b2.Vec2, radius: f32, axis: b2.Vec2, color: b2.Color, context_: rawptr) {
    rl.DrawCircleV(center, radius, b2_color_to_rl(color))
}

draw_segment :: proc "c" (p1, p2: b2.Vec2, color: b2.Color, context_: rawptr) {
    rl.DrawLineV(p1, p2, b2_color_to_rl(color))
}

draw_point :: proc "c" (p: b2.Vec2, size: f32, color: b2.Color, context_: rawptr) {
    rl.DrawPixelV(p, b2_color_to_rl(color))
}

b2_color_to_rl :: proc "contextless" (color: b2.Color) -> rl.Color {
    c := linalg.array_cast(color * 255, u8)
    return rl.Color(c)
}