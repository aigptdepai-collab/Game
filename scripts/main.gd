extends Node2D

const WORLD_WIDTH: float = 4200.0
const FLOOR_Y: float = 610.0
const GRAVITY: float = 1900.0
const MOVE_SPEED: float = 430.0
const JUMP_SPEED: float = -760.0

var player_x: float = 180.0
var player_y: float = FLOOR_Y - 62.0
var velocity_y: float = 0.0
var camera_x: float = 0.0
var on_floor: bool = true
var move_touch: int = -1
var move_direction: float = 0.0
var jump_requested: bool = false
var elapsed: float = 0.0

var platforms: Array[Rect2] = [
    Rect2(0, FLOOR_Y, 900, 180),
    Rect2(1020, FLOOR_Y, 780, 180),
    Rect2(1900, FLOOR_Y, 900, 180),
    Rect2(3000, FLOOR_Y, 1200, 180),
    Rect2(900, 520, 120, 24),
    Rect2(1450, 470, 150, 24),
    Rect2(2250, 510, 160, 24),
    Rect2(2700, 450, 150, 24)
]

func _process(delta: float) -> void:
    elapsed += delta
    queue_redraw()

func _physics_process(delta: float) -> void:
    var direction: float = 0.0
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        direction -= 1.0
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        direction += 1.0
    if move_touch != -1:
        direction = move_direction

    player_x = clampf(player_x + direction * MOVE_SPEED * delta, 35.0, WORLD_WIDTH - 35.0)

    var wants_jump: bool = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP) or jump_requested
    if on_floor and wants_jump:
        velocity_y = JUMP_SPEED
        on_floor = false
    jump_requested = false

    velocity_y += GRAVITY * delta
    var previous_y: float = player_y
    player_y += velocity_y * delta
    on_floor = false

    var feet_before: float = previous_y + 62.0
    var feet_after: float = player_y + 62.0
    if velocity_y >= 0.0:
        for platform: Rect2 in platforms:
            var overlaps_x: bool = (player_x + 20.0 > platform.position.x) and (player_x - 20.0 < platform.end.x)
            if overlaps_x and feet_before <= platform.position.y + 4.0 and feet_after >= platform.position.y:
                player_y = platform.position.y - 62.0
                velocity_y = 0.0
                on_floor = true
                break

    if player_y > 900.0:
        player_x = maxf(180.0, player_x - 250.0)
        player_y = FLOOR_Y - 62.0
        velocity_y = 0.0
        on_floor = true

    camera_x = clampf(player_x - get_viewport_rect().size.x * 0.38, 0.0, WORLD_WIDTH - get_viewport_rect().size.x)

func _input(event: InputEvent) -> void:
    var screen_w: float = get_viewport_rect().size.x
    if event is InputEventScreenTouch:
        if event.pressed:
            if event.position.x < screen_w * 0.48:
                move_touch = event.index
                move_direction = -1.0 if event.position.x < screen_w * 0.24 else 1.0
            else:
                jump_requested = true
        elif move_touch == event.index:
            move_touch = -1
            move_direction = 0.0
    elif event is InputEventScreenDrag and move_touch == event.index:
        move_direction = -1.0 if event.position.x < screen_w * 0.24 else 1.0

func _draw() -> void:
    var size: Vector2 = get_viewport_rect().size
    draw_rect(Rect2(Vector2.ZERO, size), Color("#071326"))
    draw_circle(Vector2(size.x * 0.78, 150), 230, Color(0.10, 0.22, 0.42, 0.18))

    for i in range(95):
        var sx: float = fposmod(float(i * 173) - camera_x * 0.12, size.x)
        var sy: float = float((i * 79) % 360) + 25.0
        draw_circle(Vector2(sx, sy), 1.5, Color(0.55, 0.82, 1.0, 0.65))

    for i in range(18):
        var bx: float = fposmod(float(i * 190) - camera_x * 0.25, size.x + 220.0) - 100.0
        var bh: float = 100.0 + float((i * 47) % 170)
        draw_rect(Rect2(bx, FLOOR_Y - bh, 105, bh), Color("#101f38"))
        for wy in range(3, int(bh / 24.0)):
            for wx in range(2):
                if (i + wx + wy) % 3 != 0:
                    draw_rect(Rect2(bx + 14 + wx * 38, FLOOR_Y - bh + wy * 24 + 12, 7, 10), Color(0.10, 0.62, 0.82, 0.48))

    draw_rect(Rect2(0, FLOOR_Y - 3, size.x, 3), Color("#25d9e8"))

    for platform: Rect2 in platforms:
        var rect: Rect2 = Rect2(platform.position.x - camera_x, platform.position.y, platform.size.x, platform.size.y)
        if rect.position.x > size.x or rect.end.x < 0.0:
            continue
        draw_rect(rect, Color("#182b42"))
        draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 7), Color("#26b8d4"))
        for x in range(int(rect.position.x) + 12, int(rect.end.x) - 12, 48):
            draw_rect(Rect2(x, rect.position.y + 22, 25, 5), Color("#31516c"))

    for i in range(12):
        var px: float = 520.0 + float(i) * 310.0 - camera_x
        var py: float = FLOOR_Y - 105.0 - float(i % 3) * 35.0
        if px > -30.0 and px < size.x + 30.0:
            draw_circle(Vector2(px, py), 13, Color(0.15, 0.9, 1.0, 0.18))
            draw_circle(Vector2(px, py), 6, Color("#6ffaff"))

    var p: Vector2 = Vector2(player_x - camera_x, player_y)
    _draw_shadow(p + Vector2(0, 64), Vector2(27, 7))
    var run: float = sin(elapsed * 13.0) * 7.0 if on_floor else -5.0
    draw_line(p + Vector2(-8, 38), p + Vector2(-12 + run, 57), Color("#8bd5e8"), 9)
    draw_line(p + Vector2(8, 38), p + Vector2(12 - run, 57), Color("#8bd5e8"), 9)
    draw_rect(Rect2(p.x - 22 + run, p.y + 53, 19, 8), Color("#15283d"))
    draw_rect(Rect2(p.x + 4 - run, p.y + 53, 19, 8), Color("#15283d"))
    draw_rect(Rect2(p.x - 17, p.y + 12, 34, 31), Color("#1c7897"))
    draw_rect(Rect2(p.x - 17, p.y + 12, 34, 7), Color("#72e7ed"))
    draw_circle(p + Vector2(-17, 20), 8, Color("#a5f5f0"))
    draw_circle(p + Vector2(17, 20), 8, Color("#a5f5f0"))
    draw_circle(p + Vector2(0, 0), 17, Color("#b6d9e6"))
    draw_rect(Rect2(p.x - 12, p.y - 4, 24, 8), Color("#087eaa"))
    draw_rect(Rect2(p.x - 8, p.y - 2, 16, 3), Color("#8effff"))
    draw_rect(Rect2(p.x - 24, p.y + 17, 8, 22), Color("#d58b42"))

    draw_rect(Rect2(22, 20, 300, 62), Color(0.015, 0.055, 0.11, 0.82))
    draw_rect(Rect2(22, 20, 4, 62), Color("#35e5f2"))
    draw_string(ThemeDB.fallback_font, Vector2(42, 47), "NEBULA // SECTOR 01", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#bafaff"))
    draw_string(ThemeDB.fallback_font, Vector2(42, 70), "EXPLORER  |  ENERGY  100%", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#72b9d1"))
    draw_string(ThemeDB.fallback_font, Vector2(size.x - 210, 45), "DISTANCE  %04d" % int(player_x), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#a6eaff"))

    draw_circle(Vector2(88, size.y - 95), 52, Color(0.20, 0.75, 0.9, 0.10))
    draw_arc(Vector2(88, size.y - 95), 52, 0, TAU, 48, Color(0.45, 0.9, 1.0, 0.45), 3)
    draw_string(ThemeDB.fallback_font, Vector2(55, size.y - 88), "MOVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#bafaff"))
    draw_circle(Vector2(size.x - 92, size.y - 95), 52, Color(0.20, 0.75, 0.9, 0.10))
    draw_arc(Vector2(size.x - 92, size.y - 95), 52, 0, TAU, 48, Color(0.45, 0.9, 1.0, 0.45), 3)
    draw_string(ThemeDB.fallback_font, Vector2(size.x - 119, size.y - 88), "JUMP", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#bafaff"))

func _draw_shadow(center: Vector2, radii: Vector2) -> void:
    draw_set_transform(center, 0.0, radii)
    draw_circle(Vector2.ZERO, 1.0, Color(0, 0, 0, 0.35))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
