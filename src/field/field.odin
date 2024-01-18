package field

import "core:math/linalg"
import rl "vendor:raylib"
import "../ngui"

field: Field
cow_texture: rl.Texture

Field :: struct {
    cows: [dynamic]Cow,
}

Cow :: struct {
    pos: rl.Vector2,
    angle: f32,
}

init :: proc() {
    cow_texture = rl.LoadTexture("assets/cow.png")
}

deinit :: proc() {
    rl.UnloadTexture(cow_texture)
    delete(field.cows)
}

update :: proc(dt: f32, cursor: rl.Vector2) {
    if !ngui.want_mouse() && rl.IsMouseButtonPressed(.LEFT) {
        append(&field.cows, Cow{pos = cursor})
    }

    for &cow in field.cows {
        cow.angle += dt * linalg.TAU
    }
}

draw :: proc() {
    PHI :: 1.618033988749 // Golden ratio
    FIELD_HEIGHT :: 700
    FIELD_SIZE :: rl.Vector2{PHI * FIELD_HEIGHT, FIELD_HEIGHT}
    rl.DrawRectangleV(-0.5 * FIELD_SIZE, FIELD_SIZE, rl.GREEN)

    for cow in field.cows {
        // rl.DrawTextureEx(cow_texture, cow.pos - 64, cow.angle, 1, rl.WHITE)
        SIZE :: 128
        pos := cow.pos - SIZE/2

        midpoint := rl.Rectangle{
            pos.x + SIZE/2,
            pos.y + SIZE/2,
            SIZE, SIZE,
        }
        rl.DrawTexturePro(cow_texture, {0, 0, SIZE, SIZE}, midpoint, SIZE/2, cow.angle, rl.WHITE)
    }
}