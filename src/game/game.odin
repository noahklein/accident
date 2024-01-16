package game

import "core:fmt"
import "core:math/linalg"
import rl "vendor:raylib"

player : Player

Player :: struct {
    pos, vel: rl.Vector2,
    angle: f32,

    gravity: rl.Vector2,
}

curve: Spline

POINT_RADIUS :: 0.5
hovered_point : int

update :: proc(dt: f32, cursor: rl.Vector2) {
    if rl.IsMouseButtonUp(.LEFT) {
        hovered_point = -1
    } else if rl.IsMouseButtonPressed(.LEFT) {
        hovered_point = spline_hovered_point(curve, cursor)
    }

    if hovered_point != -1 {
        curve[hovered_point] = cursor
    }
}

draw :: proc(cursor: rl.Vector2) {
    spline_draw(curve, rl.WHITE)

    for point, i in curve {

        color := rl.RED
        if i == hovered_point {
            color.b += 50
        } else if rl.CheckCollisionPointCircle(cursor, point, POINT_RADIUS) {
            color.g += 50
        }

        rl.DrawCircleV(point, POINT_RADIUS, color)

        text := fmt.ctprintf("%d", i)
        rl.DrawTextEx(rl.GetFontDefault(), text, point + {0, 1}, 2, 0, rl.WHITE)
    }
}

// A Catmull-Rom spline. See https://en.wikipedia.org/wiki/Centripetal_Catmull-Rom_spline.
Spline :: [4]rl.Vector2

spline_point :: proc(sp: Spline, t: f32, alpha: f32 = 0.5) -> rl.Vector2 {
    get_t :: proc(t, alpha: f32, a, b: rl.Vector2) -> f32 {
        sqr_dist := linalg.length2(b - a)
        b := linalg.pow(sqr_dist, alpha * 0.5)
        return b + t
    }

    t0 := f32(0)
    t1 := get_t(t0, alpha, sp[0], sp[1])
    t2 := get_t(t1, alpha, sp[1], sp[2])
    t3 := get_t(t2, alpha, sp[2], sp[3])
    t := linalg.lerp(t1, t2, t)

    a1 := (t1-t) / (t1-t0)*sp[0] + (t-t0) / (t1-t0)*sp[1]
    a2 := (t2-t) / (t2-t1)*sp[1] + (t-t1) / (t2-t1)*sp[2]
    a3 := (t3-t) / (t3-t2)*sp[2] + (t-t2) / (t3-t2)*sp[3]

    b1 := (t2-t) / (t2-t0)*a1 + (t-t0) / (t2-t0)*a2
    b2 := (t3-t) / (t3-t1)*a2 + (t-t1) / (t3-t1)*a3
    c  := (t2-t) / (t2-t1)*b1 + (t-t1) / (t2-t1)*b2

    return c
}

spline_hovered_point :: proc(spline: Spline, cursor: rl.Vector2) -> int {
    for point, i in curve {
        if rl.CheckCollisionPointCircle(cursor, point, POINT_RADIUS) {
            return i
        }
    }

    return -1
}

spline_draw :: proc(spline: Spline, color: rl.Color) {
    POINTS :: 32
    prev := spline[1]

    for i in 1..<POINTS {
        t := f32(i) / (POINTS - 1)
        point := spline_point(curve, t)
        rl.DrawLineV(prev, point, color)

        prev = point
    }
}

