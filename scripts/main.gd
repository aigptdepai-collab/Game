extends Node2D

# NEBULA - military side-scrolling action prototype
const WORLD_WIDTH: float = 7916.0
const FLOOR_Y: float = 590.0
const PLAYER_HALF_W: float = 17.0
const PLAYER_HEIGHT: float = 58.0
const GRAVITY: float = 1850.0
const MOVE_SPEED: float = 390.0
const JUMP_SPEED: float = -735.0
const MAX_HEALTH: int = 3

var player_x: float = 150.0
var player_y: float = FLOOR_Y - PLAYER_HEIGHT
var previous_y: float = 0.0
var velocity_y: float = 0.0
var camera_x: float = 0.0
var on_floor: bool = true
var facing: float = 1.0
var jump_buffer: float = 0.0
var coyote_timer: float = 0.0
var invulnerable_timer: float = 0.0
var elapsed: float = 0.0
var game_state: String = "playing" # playing, paused, game_over, victory
var health: int = MAX_HEALTH
var collected: int = 0
var checkpoint_x: float = 150.0
var checkpoint_reached: bool = false
var damage_flash: float = 0.0
var notice_timer: float = 0.0
var notice_text: String = ""
var touch_actions: Dictionary = {}
var keyboard_jump_was_down: bool = false
var particles: Array[Dictionary] = []
var bullets: Array[Dictionary] = []
var shoot_cooldown: float = 0.0
var muzzle_flash: float = 0.0
var player_atlas: Texture2D
var enemy_atlas: Texture2D
var map_textures: Array[Texture2D] = []
var map_positions: Array[float] = [0.0, 749.0, 1678.0, 2550.0, 3915.0, 5186.0, 6551.0]
var map_loaded: bool = false
var ground_profile: PackedVector2Array = PackedVector2Array([
    Vector2(0, 590), Vector2(749, 590), Vector2(1180, 612),
    Vector2(1678, 635), Vector2(2100, 635), Vector2(2550, 625),
    Vector2(3000, 625), Vector2(3915, 625), Vector2(4700, 625),
    Vector2(5186, 625), Vector2(6551, 625), Vector2(7916, 625)
])
var animation_clock: float = 0.0
var animation_frame: int = 0
var enemy_soldiers: Array[Dictionary] = [
    {"x": 420.0, "origin": 420.0, "y": FLOOR_Y - 58.0, "dir": -1.0, "hp": 4, "cooldown": 0.45, "speed": 58.0},
    {"x": 690.0, "origin": 690.0, "y": FLOOR_Y - 58.0, "dir": 1.0, "hp": 3, "cooldown": 0.61, "speed": 67.0},
    {"x": 930.0, "origin": 930.0, "y": FLOOR_Y - 58.0, "dir": -1.0, "hp": 3, "cooldown": 0.77, "speed": 76.0},
    {"x": 1210.0, "origin": 1210.0, "y": FLOOR_Y - 58.0, "dir": 1.0, "hp": 3, "cooldown": 0.9299999999999999, "speed": 58.0},
    {"x": 1510.0, "origin": 1510.0, "y": FLOOR_Y - 58.0, "dir": -1.0, "hp": 4, "cooldown": 0.45, "speed": 67.0},
    {"x": 1780.0, "origin": 1780.0, "y": FLOOR_Y - 58.0, "dir": 1.0, "hp": 3, "cooldown": 0.61, "speed": 76.0},
    {"x": 2070.0, "origin": 2070.0, "y": FLOOR_Y - 58.0, "dir": -1.0, "hp": 3, "cooldown": 0.77, "speed": 58.0},
    {"x": 2360.0, "origin": 2360.0, "y": FLOOR_Y - 58.0, "dir": 1.0, "hp": 3, "cooldown": 0.9299999999999999, "speed": 67.0},
    {"x": 2670.0, "origin": 2670.0, "y": FLOOR_Y - 58.0, "dir": -1.0, "hp": 4, "cooldown": 0.45, "speed": 76.0},
    {"x": 2980.0, "origin": 2980.0, "y": FLOOR_Y - 58.0, "dir": 1.0, "hp": 3, "cooldown": 0.61, "speed": 58.0},
    {"x": 3290.0, "origin": 3290.0, "y": FLOOR_Y - 58.0, "dir": -1.0, "hp": 3, "cooldown": 0.77, "speed": 67.0},
    {"x": 3610.0, "origin": 3610.0, "y": FLOOR_Y - 58.0, "dir": 1.0, "hp": 3, "cooldown": 0.9299999999999999, "speed": 76.0},
    {"x": 3940.0, "origin": 3940.0, "y": FLOOR_Y - 58.0, "dir": -1.0, "hp": 4, "cooldown": 0.45, "speed": 58.0},
    {"x": 4260.0, "origin": 4260.0, "y": FLOOR_Y - 58.0, "dir": 1.0, "hp": 3, "cooldown": 0.61, "speed": 67.0},
    {"x": 4590.0, "origin": 4590.0, "y": FLOOR_Y - 58.0, "dir": -1.0, "hp": 3, "cooldown": 0.77, "speed": 76.0},
    {"x": 4930.0, "origin": 4930.0, "y": FLOOR_Y - 58.0, "dir": 1.0, "hp": 3, "cooldown": 0.9299999999999999, "speed": 58.0},
    {"x": 5280.0, "origin": 5280.0, "y": FLOOR_Y - 58.0, "dir": -1.0, "hp": 4, "cooldown": 0.45, "speed": 67.0},
    {"x": 5620.0, "origin": 5620.0, "y": FLOOR_Y - 58.0, "dir": 1.0, "hp": 3, "cooldown": 0.61, "speed": 76.0},
    {"x": 5960.0, "origin": 5960.0, "y": FLOOR_Y - 58.0, "dir": -1.0, "hp": 3, "cooldown": 0.77, "speed": 58.0},
    {"x": 6310.0, "origin": 6310.0, "y": FLOOR_Y - 58.0, "dir": 1.0, "hp": 3, "cooldown": 0.9299999999999999, "speed": 67.0},
    {"x": 6650.0, "origin": 6650.0, "y": FLOOR_Y - 58.0, "dir": -1.0, "hp": 4, "cooldown": 0.45, "speed": 76.0},
    {"x": 6990.0, "origin": 6990.0, "y": FLOOR_Y - 58.0, "dir": 1.0, "hp": 3, "cooldown": 0.61, "speed": 58.0},
    {"x": 7330.0, "origin": 7330.0, "y": FLOOR_Y - 58.0, "dir": -1.0, "hp": 3, "cooldown": 0.77, "speed": 67.0},
    {"x": 7660.0, "origin": 7660.0, "y": FLOOR_Y - 58.0, "dir": 1.0, "hp": 3, "cooldown": 0.9299999999999999, "speed": 76.0}
]
# Each platform is a solid top surface. Gaps are intentional jumps.
var platforms: Array[Rect2] = [
    Rect2(360, 535, 105, 18), Rect2(485, 515, 90, 18),
    Rect2(1040, 535, 155, 18), Rect2(1850, 535, 150, 18),
    Rect2(2860, 520, 180, 18), Rect2(3350, 505, 150, 18),
    Rect2(4450, 535, 180, 18), Rect2(5650, 520, 190, 18),
    Rect2(6800, 535, 160, 18)
]

var cells: Array[Vector2] = []
var collected_cells: Array[bool] = []

var hazards: Array[Rect2] = []

var drones: Array[Dictionary] = []

func _ready() -> void:
    if ResourceLoader.exists("res://assets/player_atlas.png"):
        player_atlas = load("res://assets/player_atlas.png") as Texture2D
    if ResourceLoader.exists("res://assets/enemy_atlas.png"):
        enemy_atlas = load("res://assets/enemy_atlas.png") as Texture2D
    _load_map_segments()
    collected_cells.resize(cells.size())
    for i in range(collected_cells.size()):
        collected_cells[i] = false
    set_process(true)
    set_physics_process(true)

func _load_map_segments() -> void:
    map_textures.clear()
    map_loaded = false
    for i in range(1, 8):
        var png_path: String = "res://assets/map/map_%d.png" % i
        var jpg_path: String = "res://assets/map/map_%d.jpg" % i
        var texture: Texture2D = null
        if ResourceLoader.exists(png_path):
            texture = load(png_path) as Texture2D
        elif ResourceLoader.exists(jpg_path):
            texture = load(jpg_path) as Texture2D
        if texture == null:
            map_textures.clear()
            push_warning("Map segment missing: map_%d.png or map_%d.jpg" % [i, i])
            return
        map_textures.append(texture)
    map_loaded = map_textures.size() == 7
    if map_loaded:
        print("NEBULA map loaded: 7 segments")

func _draw_map_background(size: Vector2) -> void:
    for i in range(map_textures.size()):
        var texture: Texture2D = map_textures[i]
        var world_x: float = map_positions[i]
        var x: float = world_x - camera_x
        var width: float = float(texture.get_width())
        if x + width < 0.0 or x > size.x:
            continue
        var left_overlap: float = 0.0
        var right_overlap: float = 0.0
        if i > 0:
            left_overlap = maxf(0.0, map_positions[i - 1] + float(map_textures[i - 1].get_width()) - world_x)
        if i < map_textures.size() - 1:
            right_overlap = maxf(0.0, world_x + width - map_positions[i + 1])
        if i == 0:
            draw_texture(texture, Vector2(x, 0.0))
            continue
        # Cross-fade only the shared strips; draw the unique middle at full opacity.
        if left_overlap > 0.0:
            draw_texture_rect_region(texture, Rect2(x, 0.0, left_overlap, texture.get_height()), Rect2(0.0, 0.0, left_overlap, texture.get_height()), Color(1, 1, 1, 0.5))
        var middle_start: float = left_overlap
        var middle_width: float = maxf(0.0, width - left_overlap - right_overlap)
        if middle_width > 0.0:
            draw_texture_rect_region(texture, Rect2(x + middle_start, 0.0, middle_width, texture.get_height()), Rect2(middle_start, 0.0, middle_width, texture.get_height()))
        if right_overlap > 0.0:
            var right_start: float = width - right_overlap
            draw_texture_rect_region(texture, Rect2(x + right_start, 0.0, right_overlap, texture.get_height()), Rect2(right_start, 0.0, right_overlap, texture.get_height()), Color(1, 1, 1, 0.5))

func _ground_y_at(world_x: float) -> float:
    if world_x <= ground_profile[0].x:
        return ground_profile[0].y
    for i in range(ground_profile.size() - 1):
        var a: Vector2 = ground_profile[i]
        var b: Vector2 = ground_profile[i + 1]
        if world_x <= b.x:
            return lerpf(a.y, b.y, inverse_lerp(a.x, b.x, world_x))
    return ground_profile[ground_profile.size() - 1].y

func _process(delta: float) -> void:
    elapsed += delta
    if notice_timer > 0.0:
        notice_timer = maxf(0.0, notice_timer - delta)
    if damage_flash > 0.0:
        damage_flash = maxf(0.0, damage_flash - delta)
    _update_particles(delta)
    animation_clock += delta
    var frame_rate: float = 10.0 if absf(_get_move_direction()) > 0.1 and on_floor else 7.0
    animation_frame = int(animation_clock * frame_rate) % 4
    queue_redraw()

func _physics_process(delta: float) -> void:
    if game_state != "playing":
        return

    if invulnerable_timer > 0.0:
        invulnerable_timer = maxf(0.0, invulnerable_timer - delta)

    _update_enemy_soldiers(delta)
    _update_bullets(delta)
    shoot_cooldown = maxf(0.0, shoot_cooldown - delta)
    muzzle_flash = maxf(0.0, muzzle_flash - delta)
    if _shoot_is_down() and shoot_cooldown <= 0.0:
        _fire_player_bullet()
    var direction: float = _get_move_direction()
    if absf(direction) > 0.01:
        facing = signf(direction)
    player_x = clampf(player_x + direction * MOVE_SPEED * delta, PLAYER_HALF_W, WORLD_WIDTH - PLAYER_HALF_W)

    if _jump_just_pressed():
        jump_buffer = 0.14
    else:
        jump_buffer = maxf(0.0, jump_buffer - delta)

    if on_floor:
        var standing_on_platform: bool = false
        for platform: Rect2 in platforms:
            var overlaps_platform: bool = player_x + PLAYER_HALF_W > platform.position.x and player_x - PLAYER_HALF_W < platform.end.x
            if overlaps_platform and absf(player_y + PLAYER_HEIGHT - platform.position.y) < 9.0:
                standing_on_platform = true
                break
        if not standing_on_platform:
            var terrain_y: float = _ground_y_at(player_x)
            if player_y + PLAYER_HEIGHT <= terrain_y + 8.0 and player_y + PLAYER_HEIGHT >= terrain_y - 35.0:
                player_y = terrain_y - PLAYER_HEIGHT
            else:
                on_floor = false
        coyote_timer = 0.12 if on_floor else maxf(0.0, coyote_timer - delta)
    else:
        coyote_timer = maxf(0.0, coyote_timer - delta)

    if jump_buffer > 0.0 and coyote_timer > 0.0:
        velocity_y = JUMP_SPEED
        on_floor = false
        coyote_timer = 0.0
        jump_buffer = 0.0
        _spawn_burst(Vector2(player_x, player_y + PLAYER_HEIGHT), Color("#62eaff"), 7)

    previous_y = player_y
    velocity_y += GRAVITY * delta
    velocity_y = minf(velocity_y, 1250.0)
    player_y += velocity_y * delta
    on_floor = false

    var feet_before: float = previous_y + PLAYER_HEIGHT
    var feet_after: float = player_y + PLAYER_HEIGHT
    if velocity_y >= 0.0:
        for platform: Rect2 in platforms:
            var overlaps_x: bool = player_x + PLAYER_HALF_W > platform.position.x and player_x - PLAYER_HALF_W < platform.end.x
            if overlaps_x and feet_before <= platform.position.y + 5.0 and feet_after >= platform.position.y:
                player_y = platform.position.y - PLAYER_HEIGHT
                velocity_y = 0.0
                on_floor = true
                break
        var terrain_y: float = _ground_y_at(player_x)
        if not on_floor and feet_before <= terrain_y + 8.0 and feet_after >= terrain_y:
            player_y = terrain_y - PLAYER_HEIGHT
            velocity_y = 0.0
            on_floor = true

    for i in range(enemy_soldiers.size()):
        var enemy: Dictionary = enemy_soldiers[i]
        enemy["y"] = _ground_y_at(float(enemy["x"])) - PLAYER_HEIGHT
        enemy_soldiers[i] = enemy

    _check_enemy_contact()
    _check_checkpoint()

    if player_y > 900.0:
        _take_damage(true)

    camera_x = clampf(player_x - get_viewport_rect().size.x * 0.40, 0.0, WORLD_WIDTH - get_viewport_rect().size.x)

func _get_move_direction() -> float:
    var direction: float = 0.0
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        direction -= 1.0
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        direction += 1.0
    for action in touch_actions.values():
        if action == "left":
            direction -= 1.0
        elif action == "right":
            direction += 1.0
    return clampf(direction, -1.0, 1.0)

func _jump_just_pressed() -> bool:
    var keyboard_down: bool = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
    var just_pressed: bool = keyboard_down and not keyboard_jump_was_down
    keyboard_jump_was_down = keyboard_down
    if just_pressed:
        return true
    return Input.is_action_just_pressed("ui_accept")

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            var pos: Vector2 = event.position
            var size: Vector2 = get_viewport_rect().size
            if game_state == "paused":
                if _point_in_rect(pos, Rect2(size.x * 0.34, size.y * 0.48, size.x * 0.32, 62)):
                    game_state = "playing"
                elif _point_in_rect(pos, Rect2(size.x * 0.34, size.y * 0.59, size.x * 0.32, 54)):
                    _restart_level()
                return
            if game_state == "game_over" or game_state == "victory":
                if _point_in_rect(pos, Rect2(size.x * 0.34, size.y * 0.48, size.x * 0.32, 62)):
                    _restart_level()
                return
            if _point_in_rect(pos, Rect2(size.x - 94, 18, 72, 58)):
                game_state = "paused"
                return
            if pos.y > size.y * 0.66:
                if pos.x < size.x * 0.30:
                    touch_actions[event.index] = "left" if pos.x < size.x * 0.09 else "right"
                elif pos.x > size.x * 0.68:
                    if pos.x > size.x * 0.88:
                        touch_actions[event.index] = "shoot"
                    else:
                        touch_actions[event.index] = "jump"
                        jump_buffer = 0.14
        else:
            touch_actions.erase(event.index)
    elif event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
            if game_state == "playing":
                game_state = "paused"
            elif game_state == "paused":
                game_state = "playing"
        elif event.keycode == KEY_R and (game_state == "game_over" or game_state == "victory"):
            _restart_level()

func _point_in_rect(point: Vector2, rect: Rect2) -> bool:
    return rect.has_point(point)

func _shoot_is_down() -> bool:
    if Input.is_key_pressed(KEY_J) or Input.is_key_pressed(KEY_X) or Input.is_key_pressed(KEY_CTRL):
        return true
    for action in touch_actions.values():
        if action == "shoot":
            return true
    return false

func _fire_player_bullet() -> void:
    bullets.append({"x": player_x + facing * 27.0, "y": player_y + 29.0, "vx": facing * 780.0, "team": "player", "life": 1.6})
    shoot_cooldown = 0.19
    muzzle_flash = 0.07
    _spawn_burst(Vector2(player_x + facing * 27.0, player_y + 29.0), Color("#ffd27a"), 3)

func _update_enemy_soldiers(delta: float) -> void:
    for i in range(enemy_soldiers.size()):
        var enemy: Dictionary = enemy_soldiers[i]
        if int(enemy["hp"]) <= 0:
            continue
        var dx: float = player_x - float(enemy["x"])
        if absf(dx) < 900.0:
            if absf(dx) > 125.0:
                enemy["dir"] = signf(dx)
                enemy["x"] = float(enemy["x"]) + float(enemy["dir"]) * float(enemy["speed"]) * delta
            enemy["cooldown"] = float(enemy["cooldown"]) - delta
            if float(enemy["cooldown"]) <= 0.0 and absf(dx) < 760.0:
                var shot_dir: float = signf(dx)
                bullets.append({"x": float(enemy["x"]) + shot_dir * 25.0, "y": float(enemy["y"]) + 29.0, "vx": shot_dir * 500.0, "team": "enemy", "life": 1.65})
                enemy["cooldown"] = 0.78 + float(i % 3) * 0.14
        else:
            enemy["x"] = float(enemy["x"]) + float(enemy["dir"]) * float(enemy["speed"]) * 0.35 * delta
            if absf(float(enemy["x"]) - float(enemy["origin"])) > 90.0:
                enemy["dir"] = -float(enemy["dir"])
        enemy_soldiers[i] = enemy

func _update_bullets(delta: float) -> void:
    for i in range(bullets.size() - 1, -1, -1):
        var bullet: Dictionary = bullets[i]
        bullet["x"] = float(bullet["x"]) + float(bullet["vx"]) * delta
        bullet["life"] = float(bullet["life"]) - delta
        var remove_bullet: bool = float(bullet["life"]) <= 0.0
        if not remove_bullet and bullet["team"] == "player":
            for j in range(enemy_soldiers.size()):
                var enemy: Dictionary = enemy_soldiers[j]
                if int(enemy["hp"]) > 0 and absf(float(enemy["x"]) - float(bullet["x"])) < 24.0 and absf(float(enemy["y"]) + 28.0 - float(bullet["y"])) < 34.0:
                    enemy["hp"] = int(enemy["hp"]) - 1
                    enemy_soldiers[j] = enemy
                    _spawn_burst(Vector2(float(bullet["x"]), float(bullet["y"])), Color("#ffb36b"), 6)
                    remove_bullet = true
                    if int(enemy["hp"]) <= 0:
                        _spawn_burst(Vector2(float(enemy["x"]), float(enemy["y"]) + 28.0), Color("#ff805e"), 16)
                        _show_notice("HOSTILE DOWN")
                    break
        elif not remove_bullet and bullet["team"] == "enemy" and invulnerable_timer <= 0.0:
            if absf(float(bullet["x"]) - player_x) < 19.0 and absf(float(bullet["y"]) - (player_y + 29.0)) < 28.0:
                _take_damage()
                remove_bullet = true
        if remove_bullet:
            bullets.remove_at(i)
        else:
            bullets[i] = bullet

func _check_enemy_contact() -> void:
    if invulnerable_timer > 0.0:
        return
    for enemy: Dictionary in enemy_soldiers:
        if int(enemy["hp"]) > 0 and absf(float(enemy["x"]) - player_x) < 27.0 and absf(float(enemy["y"]) - player_y) < 52.0:
            _take_damage()
            return

func _draw_bullets() -> void:
    for bullet: Dictionary in bullets:
        var p: Vector2 = Vector2(float(bullet["x"]) - camera_x, float(bullet["y"]))
        var tint: Color = Color("#ffd27a") if bullet["team"] == "player" else Color("#ff657c")
        draw_line(p, p - Vector2(signf(float(bullet["vx"])) * 13.0, 0), tint, 4.0)
        draw_circle(p, 3.0, Color("#fff4ce"))

func _draw_enemy_soldiers() -> void:
    for enemy: Dictionary in enemy_soldiers:
        if int(enemy["hp"]) <= 0:
            continue
        var p: Vector2 = Vector2(float(enemy["x"]) - camera_x, float(enemy["y"]))
        if p.x < -60.0 or p.x > get_viewport_rect().size.x + 60.0:
            continue
        var dir: float = float(enemy["dir"])
        if enemy_atlas != null:
            var dx: float = absf(player_x - float(enemy["x"]))
            var row: int = 1 if dx > 125.0 and dx < 760.0 else 0
            if dx < 620.0 and float(enemy["cooldown"]) < 0.35:
                row = 3
            var frame: int = int(elapsed * (9.0 if row == 1 else 7.0)) % 4
            var source: Rect2 = Rect2(frame * 256, row * 384, 256, 384)
            var destination: Rect2 = Rect2(-43, -80, 86, 98)
            draw_set_transform(Vector2(p.x, p.y + 58.0), 0.0, Vector2(dir, 1.0))
            draw_texture_rect_region(enemy_atlas, destination, source, Color.WHITE, false, true)
            draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
        else:
            draw_rect(Rect2(p.x - 12, p.y + 36, 10, 19), Color("#343d36"))
            draw_rect(Rect2(p.x + 3, p.y + 36, 10, 19), Color("#343d36"))
            draw_rect(Rect2(p.x - 16, p.y + 14, 32, 27), Color("#596448"))
            draw_rect(Rect2(p.x - 15, p.y + 8, 30, 10), Color("#343d36"))
            draw_rect(Rect2(p.x - 13, p.y - 3, 26, 22), Color("#bd956c"))
            draw_rect(Rect2(p.x - 16, p.y - 7, 32, 9), Color("#4c583e"))
            draw_rect(Rect2(p.x - 9, p.y + 5, 18, 5), Color("#252a2a"))
            draw_line(p + Vector2(10.0 * dir, 24), p + Vector2(25.0 * dir, 27), Color("#bd956c"), 6.0)
            draw_rect(Rect2(p.x + (18.0 if dir > 0.0 else -38.0), p.y + 20, 23, 7), Color("#242d35"))
            draw_rect(Rect2(p.x + (37.0 if dir > 0.0 else -40.0), p.y + 22, 5, 3), Color("#a9bac0"))
        for h in range(int(enemy["hp"])):
            draw_rect(Rect2(p.x - 15 + h * 11, p.y - 16, 8, 3), Color("#ff765f"))

func _update_drones(delta: float) -> void:
    for i in range(drones.size()):
        var drone: Dictionary = drones[i]
        drone["x"] = float(drone["x"]) + float(drone["dir"]) * float(drone["speed"]) * delta
        if absf(float(drone["x"]) - float(drone["origin"])) >= float(drone["range"]):
            drone["dir"] = -float(drone["dir"])
        drones[i] = drone

func _check_collectibles() -> void:
    for i in range(cells.size()):
        if collected_cells[i]:
            continue
        if Vector2(player_x, player_y + 27.0).distance_to(cells[i]) < 43.0:
            collected_cells[i] = true
            collected += 1
            _spawn_burst(cells[i], Color("#ffe27a"), 12)
            _show_notice("ENERGY CELL +1")

func _check_hazards() -> void:
    var player_rect: Rect2 = Rect2(player_x - PLAYER_HALF_W, player_y + 12.0, PLAYER_HALF_W * 2.0, PLAYER_HEIGHT - 12.0)
    for hazard: Rect2 in hazards:
        if player_rect.intersects(hazard):
            _take_damage()
            return

func _check_drones() -> void:
    if invulnerable_timer > 0.0:
        return
    for drone: Dictionary in drones:
        var drone_rect: Rect2 = Rect2(float(drone["x"]) - 20.0, float(drone["y"]) - 16.0, 40.0, 32.0)
        var player_rect: Rect2 = Rect2(player_x - PLAYER_HALF_W, player_y + 5.0, PLAYER_HALF_W * 2.0, PLAYER_HEIGHT - 5.0)
        if player_rect.intersects(drone_rect):
            _take_damage()
            return

func _check_checkpoint() -> void:
    if player_x >= 2200.0 and not checkpoint_reached:
        checkpoint_reached = true
        checkpoint_x = 2260.0
        _show_notice("CHECKPOINT ACTIVATED")
        _spawn_burst(Vector2(checkpoint_x, FLOOR_Y - 65.0), Color("#69f5d0"), 18)
    if player_x >= WORLD_WIDTH - 80.0:
        game_state = "victory"
        _show_notice("SECTOR CLEARED")

func _take_damage(fall: bool = false) -> void:
    if invulnerable_timer > 0.0 and not fall:
        return
    health -= 1
    damage_flash = 0.28
    invulnerable_timer = 1.35
    _spawn_burst(Vector2(player_x, player_y + 25.0), Color("#ff647c"), 14)
    if health <= 0:
        game_state = "game_over"
        return
    player_x = checkpoint_x
    player_y = _ground_y_at(player_x) - PLAYER_HEIGHT
    velocity_y = 0.0
    on_floor = true
    _show_notice("SYSTEM REBOOT // -1 LIFE")

func _restart_level() -> void:
    player_x = 150.0
    player_y = _ground_y_at(player_x) - PLAYER_HEIGHT
    velocity_y = 0.0
    camera_x = 0.0
    on_floor = true
    health = MAX_HEALTH
    collected = 0
    checkpoint_x = 150.0
    checkpoint_reached = false
    invulnerable_timer = 0.0
    game_state = "playing"
    for i in range(collected_cells.size()):
        collected_cells[i] = false
    bullets.clear()
    _reset_enemy_wave()
    drones = [
        {"origin": 1020.0, "x": 1020.0, "y": 450.0, "range": 90.0, "speed": 65.0, "dir": 1.0},
        {"origin": 2160.0, "x": 2160.0, "y": 410.0, "range": 105.0, "speed": 78.0, "dir": -1.0},
        {"origin": 3040.0, "x": 3040.0, "y": 420.0, "range": 85.0, "speed": 70.0, "dir": 1.0}
    ]

func _show_notice(message: String) -> void:
    notice_text = message
    notice_timer = 2.0

func _spawn_burst(at: Vector2, color: Color, amount: int) -> void:
    for i in range(amount):
        var angle: float = TAU * float(i) / float(amount)
        var speed: float = 55.0 + float((i * 37) % 75)
        particles.append({"p": at, "v": Vector2(cos(angle), sin(angle)) * speed, "life": 0.55, "max": 0.55, "color": color})

func _update_particles(delta: float) -> void:
    for i in range(particles.size() - 1, -1, -1):
        var particle: Dictionary = particles[i]
        var particle_position: Vector2 = particle["p"]
        var particle_velocity: Vector2 = particle["v"]
        particle["p"] = particle_position + particle_velocity * delta
        particle["life"] = float(particle["life"]) - delta
        particle["v"] = particle_velocity * 0.94
        if float(particle["life"]) <= 0.0:
            particles.remove_at(i)
        else:
            particles[i] = particle

func _draw() -> void:
    var size: Vector2 = get_viewport_rect().size
    if map_loaded:
        _draw_map_background(size)
    else:
        _draw_background(size)
        _draw_level(size)
        _draw_military_props()
    _draw_enemy_soldiers()
    _draw_bullets()
    _draw_checkpoint()
    _draw_exit()
    _draw_player()
    _draw_particles()
    _draw_hud(size)
    _draw_touch_controls(size)
    if game_state != "playing":
        _draw_overlay(size)

func _draw_background(size: Vector2) -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color("#343b48"))
    draw_rect(Rect2(0, 0, size.x, FLOOR_Y * 0.55), Color("#59606a"))
    draw_circle(Vector2(size.x * 0.78, 150), 92, Color("#c28b62"))
    draw_circle(Vector2(size.x * 0.78, 150), 116, Color(0.85, 0.52, 0.31, 0.10))
    for i in range(16):
        var bx: float = fposmod(float(i * 193) - camera_x * 0.20, size.x + 260.0) - 130.0
        var bh: float = 115.0 + float((i * 53) % 170)
        draw_rect(Rect2(bx, FLOOR_Y - bh, 130, bh), Color("#303943"))
        draw_rect(Rect2(bx + 10, FLOOR_Y - bh + 14, 110, 5), Color("#555d62"))
        draw_rect(Rect2(bx + 18, FLOOR_Y - bh + 34, 18, 25), Color("#252e35"))
        draw_rect(Rect2(bx + 62, FLOOR_Y - bh + 34, 18, 25), Color("#252e35"))
    for i in range(2):
        var ax: float = fposmod(float(i * 610 + 380) - camera_x * 0.08, size.x + 180.0) - 90.0
        var ay: float = 145.0 + float(i * 42)
        draw_set_transform(Vector2(ax, ay), 0.0, Vector2(48, 10))
        draw_circle(Vector2.ZERO, 1.0, Color("#303943"))
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
        draw_rect(Rect2(ax - 13, ay + 8, 26, 12), Color("#303943"))
        draw_line(Vector2(ax, ay - 12), Vector2(ax, ay - 30), Color("#303943"), 2.0)

func _draw_level(size: Vector2) -> void:
    draw_rect(Rect2(0, FLOOR_Y - 2, size.x, 2), Color("#b5a27c"))
    draw_rect(Rect2(0, FLOOR_Y, size.x, size.y - FLOOR_Y + 80), Color("#45483f"))
    draw_rect(Rect2(0, FLOOR_Y + 9, size.x, 5), Color("#30352f"))
    for x in range(-int(camera_x) % 96, int(size.x), 96):
        draw_line(Vector2(x, FLOOR_Y + 24), Vector2(x + 34, FLOOR_Y + 24), Color("#77715c"), 3.0)
    for platform: Rect2 in platforms:
        if platform.position.y >= FLOOR_Y:
            continue
        var rect: Rect2 = Rect2(platform.position.x - camera_x, platform.position.y, platform.size.x, platform.size.y)
        if rect.position.x > size.x or rect.end.x < 0.0:
            continue
        draw_rect(rect, Color("#55594e"))
        draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 6), Color("#a6a18a"))
        draw_rect(Rect2(rect.position.x, rect.position.y + 7, rect.size.x, 3), Color("#292f2c"))
        for bolt_x in range(int(rect.position.x) + 12, int(rect.end.x) - 8, 34):
            draw_circle(Vector2(bolt_x, rect.position.y + 18), 2.5, Color("#c0b99b"))

func _draw_military_props() -> void:
    var props: Array[Dictionary] = [
        {"x": 700.0, "kind": "crates"},
        {"x": 1510.0, "kind": "truck"},
        {"x": 2440.0, "kind": "tank"},
        {"x": 3450.0, "kind": "container"},
        {"x": 4560.0, "kind": "tank"}
    ]
    for prop: Dictionary in props:
        var x: float = float(prop["x"]) - camera_x
        var kind: String = String(prop["kind"])
        if x < -300.0 or x > get_viewport_rect().size.x + 300.0:
            continue
        if kind == "crates":
            for n in range(3):
                var cx: float = x + float(n % 2) * 70.0
                var cy: float = FLOOR_Y - 75.0 - float(n / 2) * 75.0
                draw_rect(Rect2(cx, cy, 66, 70), Color("#655b45"))
                draw_rect(Rect2(cx + 5, cy + 5, 56, 60), Color("#897653"), false, 4.0)
                draw_line(Vector2(cx + 8, cy + 8), Vector2(cx + 58, cy + 62), Color("#4b493b"), 4.0)
                draw_line(Vector2(cx + 58, cy + 8), Vector2(cx + 8, cy + 62), Color("#4b493b"), 4.0)
        elif kind == "truck":
            draw_rect(Rect2(x, FLOOR_Y - 66, 188, 54), Color("#59634c"))
            draw_rect(Rect2(x + 8, FLOOR_Y - 104, 72, 42), Color("#68735b"))
            draw_rect(Rect2(x + 18, FLOOR_Y - 96, 48, 25), Color("#9aa0a0"))
            for wx in [x + 38, x + 148]:
                draw_circle(Vector2(wx, FLOOR_Y - 9), 18, Color("#24292a"))
                draw_circle(Vector2(wx, FLOOR_Y - 9), 8, Color("#9b9b8c"))
        elif kind == "tank":
            draw_rect(Rect2(x, FLOOR_Y - 70, 220, 58), Color("#515d46"))
            draw_rect(Rect2(x + 24, FLOOR_Y - 88, 168, 25), Color("#303a32"))
            draw_rect(Rect2(x + 73, FLOOR_Y - 112, 82, 28), Color("#687453"))
            draw_rect(Rect2(x + 130, FLOOR_Y - 106, 100, 9), Color("#343b34"))
            for tx in range(6):
                draw_circle(Vector2(x + 28 + tx * 31, FLOOR_Y - 13), 13, Color("#242a27"))
                draw_circle(Vector2(x + 28 + tx * 31, FLOOR_Y - 13), 5, Color("#8d927f"))
        elif kind == "container":
            draw_rect(Rect2(x, FLOOR_Y - 78, 170, 66), Color("#59675b"))
            draw_rect(Rect2(x + 6, FLOOR_Y - 72, 158, 54), Color("#78806b"), false, 3.0)
            for rib in range(1, 8):
                draw_line(Vector2(x + rib * 20, FLOOR_Y - 70), Vector2(x + rib * 20, FLOOR_Y - 20), Color("#414d45"), 3.0)

func _draw_collectibles() -> void:
    for i in range(cells.size()):
        if collected_cells[i]:
            continue
        var p: Vector2 = cells[i] - Vector2(camera_x, 0)
        var pulse: float = 1.0 + 0.12 * sin(elapsed * 5.0 + float(i))
        draw_circle(p, 15.0 * pulse, Color(1.0, 0.78, 0.24, 0.12))
        draw_colored_polygon(PackedVector2Array([p + Vector2(0, -10), p + Vector2(8, 0), p + Vector2(0, 10), p + Vector2(-8, 0)]), Color("#ffe17a"))
        draw_circle(p, 3.0, Color("#fff7cf"))

func _draw_hazards() -> void:
    for hazard: Rect2 in hazards:
        var x: float = hazard.position.x - camera_x
        if x > get_viewport_rect().size.x or x + hazard.size.x < 0.0:
            continue
        var count: int = int(hazard.size.x / 20.0)
        for i in range(count):
            var hx: float = x + float(i) * 20.0
            draw_colored_polygon(PackedVector2Array([Vector2(hx, FLOOR_Y), Vector2(hx + 10, FLOOR_Y - 23), Vector2(hx + 20, FLOOR_Y)]), Color("#e65370"))
            draw_line(Vector2(hx + 10, FLOOR_Y - 20), Vector2(hx + 10, FLOOR_Y - 4), Color("#ff9aab"), 2.0)

func _draw_drones() -> void:
    for drone: Dictionary in drones:
        var p: Vector2 = Vector2(float(drone["x"]) - camera_x, float(drone["y"]))
        if p.x < -50.0 or p.x > get_viewport_rect().size.x + 50.0:
            continue
        var bob: float = sin(elapsed * 4.0 + float(drone["origin"])) * 4.0
        draw_circle(p + Vector2(0, bob), 25, Color(1.0, 0.25, 0.38, 0.10))
        draw_rect(Rect2(p.x - 17, p.y - 10 + bob, 34, 20), Color("#273d59"))
        draw_rect(Rect2(p.x - 12, p.y - 6 + bob, 24, 12), Color("#45617c"))
        draw_circle(p + Vector2(0, bob), 5, Color("#ff5b78"))
        draw_line(p + Vector2(-22, bob), p + Vector2(-31, bob + 8), Color("#6dd9e7"), 3.0)
        draw_line(p + Vector2(22, bob), p + Vector2(31, bob + 8), Color("#6dd9e7"), 3.0)

func _draw_checkpoint() -> void:
    if not checkpoint_reached:
        return
    var x: float = checkpoint_x - camera_x
    draw_line(Vector2(x, FLOOR_Y), Vector2(x, FLOOR_Y - 95), Color("#65f0c8"), 5.0)
    draw_colored_polygon(PackedVector2Array([Vector2(x + 2, FLOOR_Y - 93), Vector2(x + 40, FLOOR_Y - 80), Vector2(x + 2, FLOOR_Y - 66)]), Color("#65f0c8"))
    draw_circle(Vector2(x, FLOOR_Y - 95), 11, Color(0.38, 1.0, 0.78, 0.2))

func _draw_exit() -> void:
    var x: float = 5490.0 - camera_x
    var center: Vector2 = Vector2(x, FLOOR_Y - 66)
    draw_circle(center, 55 + sin(elapsed * 3.0) * 4.0, Color(0.18, 0.9, 0.85, 0.10))
    draw_arc(center, 43, 0, TAU, 64, Color("#54f4d8"), 5.0)
    draw_arc(center, 30, 0, TAU, 64, Color("#8af8eb"), 2.0)
    draw_line(center + Vector2(0, -27), center + Vector2(0, 27), Color("#b4fff4"), 3.0)

func _draw_player() -> void:
    var p: Vector2 = Vector2(player_x - camera_x, player_y)
    if invulnerable_timer > 0.0 and int(elapsed * 14.0) % 2 == 0:
        return
    _draw_player_shadow_ellipse(p + Vector2(0, PLAYER_HEIGHT + 4), Vector2(25, 6), Color(0, 0, 0, 0.38))
    if player_atlas != null:
        var row: int = 0
        if not on_floor:
            row = 2
        elif _shoot_is_down():
            row = 3
        elif absf(_get_move_direction()) > 0.1:
            row = 1
        var source: Rect2 = Rect2(animation_frame * 256, row * 384, 256, 384)
        var destination: Rect2 = Rect2(-43, -80, 86, 98)
        draw_set_transform(Vector2(p.x, p.y + PLAYER_HEIGHT), 0.0, Vector2(facing, 1.0))
        draw_texture_rect_region(player_atlas, destination, source, Color.WHITE, false, true)
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    else:
        # Temporary fallback until assets/player_atlas.png is added to the project.
        draw_rect(Rect2(p.x - 16, p.y + 14, 32, 29), Color("#596548"))
        draw_rect(Rect2(p.x - 12, p.y - 5, 24, 23), Color("#c69a73"))
        draw_rect(Rect2(p.x - 15, p.y - 10, 30, 11), Color("#596548"))
        draw_rect(Rect2(p.x - 18, p.y + 25, 38, 7), Color("#202a2b"))
        draw_line(p + Vector2(-7, 39), p + Vector2(-10, 55), Color("#343d32"), 9.0)
        draw_line(p + Vector2(7, 39), p + Vector2(10, 55), Color("#343d32"), 9.0)
    if muzzle_flash > 0.0:
        var muzzle: Vector2 = Vector2(p.x + facing * 49.0, p.y + 29.0)
        draw_colored_polygon(PackedVector2Array([muzzle, muzzle + Vector2(facing * 13.0, -5), muzzle + Vector2(facing * 8.0, 0), muzzle + Vector2(facing * 13.0, 5)]), Color("#fff0a0"))

func _draw_player_shadow_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
    draw_set_transform(center, 0.0, radii)
    draw_circle(Vector2.ZERO, 1.0, color)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_particles() -> void:
    for particle: Dictionary in particles:
        var world_p: Vector2 = particle["p"]
        var p: Vector2 = world_p - Vector2(camera_x, 0)
        var alpha: float = clampf(float(particle["life"]) / float(particle["max"]), 0.0, 1.0)
        var color: Color = particle["color"]
        color.a *= alpha
        draw_circle(p, 3.0 * alpha + 1.0, color)

func _draw_hud(size: Vector2) -> void:
    draw_rect(Rect2(18, 16, 320, 82), Color(0.015, 0.045, 0.09, 0.86))
    draw_rect(Rect2(18, 16, 4, 82), Color("#35e5f2"))
    draw_string(ThemeDB.fallback_font, Vector2(36, 43), "NEBULA  /  SECTOR 01", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#c5fbff"))
    draw_string(ThemeDB.fallback_font, Vector2(36, 68), "HOSTILE ZONE  //  ADVANCE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#d0b58b"))
    for i in range(MAX_HEALTH):
        var heart_color: Color = Color("#ff637d") if i < health else Color("#33465a")
        _draw_heart(Vector2(37 + i * 28, 86), 8.0, heart_color)
    var progress: float = clampf(player_x / 5480.0, 0.0, 1.0)
    draw_rect(Rect2(size.x * 0.36, 28, size.x * 0.28, 8), Color(0.16, 0.25, 0.34, 0.9))
    draw_rect(Rect2(size.x * 0.36, 28, size.x * 0.28 * progress, 8), Color("#35d9e8"))
    draw_string(ThemeDB.fallback_font, Vector2(size.x * 0.36, 54), "MISSION PROGRESS  %d%%" % int(progress * 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#d0b58b"))
    draw_rect(Rect2(size.x - 88, 18, 70, 54), Color(0.015, 0.045, 0.09, 0.86))
    draw_rect(Rect2(size.x - 88, 18, 70, 54), Color(0.2, 0.7, 0.8, 0.5), false, 2.0)
    draw_string(ThemeDB.fallback_font, Vector2(size.x - 70, 51), "II", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#c5fbff"))
    if notice_timer > 0.0:
        var notice_width: float = 360.0
        draw_rect(Rect2((size.x - notice_width) * 0.5, 112, notice_width, 38), Color(0.02, 0.10, 0.16, 0.88))
        draw_string(ThemeDB.fallback_font, Vector2((size.x - notice_width) * 0.5 + 18, 137), notice_text, HORIZONTAL_ALIGNMENT_CENTER, notice_width - 36, 15, Color("#9effee"))

func _draw_heart(center: Vector2, s: float, color: Color) -> void:
    draw_circle(center + Vector2(-s * 0.45, -s * 0.15), s * 0.58, color)
    draw_circle(center + Vector2(s * 0.45, -s * 0.15), s * 0.58, color)
    draw_colored_polygon(PackedVector2Array([center + Vector2(-s, 0), center + Vector2(s, 0), center + Vector2(0, s * 1.25)]), color)

func _draw_touch_controls(size: Vector2) -> void:
    var y: float = size.y - 78.0
    _draw_control_circle(Vector2(62, y), "◀", Color(0.24, 0.76, 0.88, 0.22))
    _draw_control_circle(Vector2(146, y), "▶", Color(0.24, 0.76, 0.88, 0.22))
    _draw_control_circle(Vector2(size.x - 150, y), "FIRE", Color(1.0, 0.48, 0.20, 0.28))
    _draw_control_circle(Vector2(size.x - 65, y), "JUMP", Color(0.22, 0.85, 0.79, 0.24))

func _draw_control_circle(center: Vector2, label: String, color: Color) -> void:
    draw_circle(center, 38, color)
    draw_arc(center, 38, 0, TAU, 48, Color(0.55, 0.92, 1.0, 0.48), 2.0)
    draw_string(ThemeDB.fallback_font, center + Vector2(-17 if label != "JUMP" else -25, 6), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 15 if label != "JUMP" else 12, Color("#d4fbff"))

func _draw_overlay(size: Vector2) -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.005, 0.012, 0.03, 0.78))
    var title: String = "PAUSED" if game_state == "paused" else ("SECTOR CLEARED" if game_state == "victory" else "SIGNAL LOST")
    draw_string(ThemeDB.fallback_font, Vector2(0, size.y * 0.34), title, HORIZONTAL_ALIGNMENT_CENTER, size.x, 42, Color("#c5fbff"))
    var subtitle: String = "Take a breath, explorer." if game_state == "paused" else ("You collected %d energy cells." % collected if game_state == "victory" else "Your suit has run out of energy.")
    draw_string(ThemeDB.fallback_font, Vector2(0, size.y * 0.42), subtitle, HORIZONTAL_ALIGNMENT_CENTER, size.x, 17, Color("#91bdce"))
    _draw_menu_button(Rect2(size.x * 0.34, size.y * 0.48, size.x * 0.32, 62), "RESUME" if game_state == "paused" else "PLAY AGAIN")
    if game_state == "paused":
        _draw_menu_button(Rect2(size.x * 0.34, size.y * 0.59, size.x * 0.32, 54), "RESTART LEVEL")
    else:
        draw_string(ThemeDB.fallback_font, Vector2(0, size.y * 0.72), "Tap the button or press R", HORIZONTAL_ALIGNMENT_CENTER, size.x, 14, Color("#6f9caf"))

func _draw_menu_button(rect: Rect2, label: String) -> void:
    draw_rect(rect, Color("#12354a"))
    draw_rect(rect, Color("#35d9e8"), false, 2.0)
    draw_string(ThemeDB.fallback_font, Vector2(rect.position.x, rect.position.y + rect.size.y * 0.62), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 18, Color("#d5fbff"))
