package game

import rl "vendor:raylib"
import b2 "../odin-box2d"

DT :: 1.0 / 120.0

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
}

deinit :: proc() {
    b2.destroy_world(world.id)
    delete(world.bodies)
}

update :: proc(dt: f32, cursor: rl.Vector2) {
    world.dt_acc += dt

    for world.dt_acc >= DT {
        world.dt_acc -= DT
        fixed_update(cursor)
    }
}

fixed_update :: proc(cursor: rl.Vector2) {
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

    b2.world_step(world.id, DT, velocity_iterations = 8, position_iterations = 3)
}

draw :: proc(cursor: rl.Vector2) {
    for body in world.bodies {
        pos := b2.body_get_position(body)
        rl.DrawCircleV(pos, 1, rl.WHITE)
    }
}
