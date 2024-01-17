package main

import "core:time"
import rl "vendor:raylib"
import b2 "odin-box2d"
import "game"

import "ngui"
import "rlutil"

draw_gui :: proc(camera: ^rl.Camera2D) {
    ngui.update()

    if ngui.begin_panel("Game", {0, 0, 300, 0}) {
        if ngui.flex_row({0.2, 0.4, 0.2, 0.2}) {
            ngui.text("Camera")
            ngui.vec2(&camera.target, label = "Target")
            ngui.float(&camera.zoom, min = 0.5, max = 10, label = "Zoom")
            ngui.float(&camera.rotation, min = -360, max = 360, label = "Angle")
        }

        if ngui.flex_row({0.25, 0.25, 0.25}) {
            ngui.float(&timescale, min = 0, max = 10, label = "Timescale")
            b2_stats := b2.world_get_counters(game.world.id)
            ngui.text("Bodies: %v", b2_stats.body_count)
            ngui.text("Bytes: %v MB", b2_stats.byte_count / 1_000_000)
        }

        if ngui.flex_row({1}) {
            if ngui.graph_begin("Time", 256, lower = 0, upper = f32(time.Second) / 120) {
                ngui.graph_line("Update", rlutil.profile_duration("update"), rl.SKYBLUE)
                ngui.graph_line("Draw", rlutil.profile_duration("draw"), rl.RED)
            }
        }
    }

    rl.DrawFPS(rl.GetScreenWidth() - 80, 0)
}