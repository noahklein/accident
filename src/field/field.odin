package field

import "core:math/linalg"
import "core:math/rand"
import rl "vendor:raylib"

import "../ngui"

field: Field
cow_texture: rl.Texture

Field :: struct {
    cows: [dynamic]Cow,
}

CowState :: enum u8 { Idle, Move }

Cow :: struct {
    pos: rl.Vector2,
    angle: f32,

    hop_offset: f32,
    direction: rl.Vector2,

    state: CowState,
    state_timer: f32,
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
        append(&field.cows, Cow{pos = cursor, direction = rand_direction()})
    }

    for &cow in field.cows {
        if rand.float32() > 0.999 {
            cow.direction = rand_direction()
        }

        cow.state_timer -= dt
        switch cow.state {
        case .Idle:
            if cow.state_timer <= 0 {
                cow.state = .Move
                cow.state_timer = 3
            }
        case .Move:
            cow.pos += 5 * cow.direction * dt

            // TODO: pingpong in range.
            if cow.hop_offset >= 10 do cow.hop_offset -= 10*dt
            else                    do cow.hop_offset += 10*dt

            if cow.state_timer <= 0 {
                cow.state = .Idle
                cow.state_timer = 3
            }
        }

        // cow.angle += linalg.TAU * dt
    }
}

draw :: proc() {
    PHI :: 1.618033988749 // Golden ratio
    FIELD_HEIGHT :: 700
    FIELD_SIZE :: rl.Vector2{PHI * FIELD_HEIGHT, FIELD_HEIGHT}
    rl.DrawRectangleV(-0.5 * FIELD_SIZE, FIELD_SIZE, rl.GREEN)

    for cow in field.cows {
        SIZE :: 128
        pos := cow.pos - SIZE/2

        midpoint := rl.Rectangle{
            pos.x + SIZE/2,
            pos.y + cow.hop_offset + SIZE/2,
            SIZE, SIZE,
        }

        width: f32 = SIZE if cow.direction.x < 0 else -SIZE
        source := rl.Rectangle{0, 0, width, SIZE}

        rl.DrawTexturePro(cow_texture, source, midpoint, SIZE/2, cow.angle, rl.WHITE)
    }
}

rand_direction :: proc() -> (dir: rl.Vector2) {
    dir = {
        rand.float32_range(-1, 1),
        rand.float32_range(-1, 1),
    }
    return linalg.normalize(dir)
}