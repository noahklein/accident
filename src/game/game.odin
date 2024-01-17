package game

import "core:math/linalg"
import "core:runtime"
import rl "vendor:raylib"
import b2 "../odin-box2d"

import "../rlutil"
import "../ngui"

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

    create_wall :: proc(pos, size: rl.Vector2) -> (b2.Body_ID, b2.Shape_ID) {
        body_def := b2.DEFAULT_BODY_DEF
        body_def.position = pos
        body_id := b2.create_body(world.id, &body_def)

        box := b2.make_box(size.x, size.y)
        shape_def := b2.DEFAULT_SHAPE_DEF
        shape_id := b2.create_polygon_shape(body_id, &shape_def, &box)
        return body_id, shape_id
    }

    create_wall({0, 40}, {50, 10})
    create_wall({-60, -50}, {10, 100})
    create_wall({60, -50}, {10, 100})

}

deinit :: proc() {
    b2.destroy_world(world.id)
    delete(world.bodies)
}

update :: proc(dt: f32, cursor: rl.Vector2) {
    // if rl.IsMouseButtonPressed(.LEFT) {
    if !ngui.want_mouse() && rl.IsMouseButtonDown(.LEFT) {
        body_def := b2.DEFAULT_BODY_DEF
        body_def.type = .Dynamic
        body_def.position = cursor
        body_id := b2.create_body(world.id, &body_def)

        shape := b2.DEFAULT_SHAPE_DEF
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
    when ODIN_DEBUG {
        b2.world_draw(world.id, &debug_draw)
    }
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