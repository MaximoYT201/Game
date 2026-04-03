extends KinematicBody2D

# --- Variables de Movimiento ---
export var speed = 150
export var jump_speed = -300
export var gravity = 700
export var jump_limit = -100
export var jump_cutoff_gravity = 1100

# --- Variables de Habilidades (Progresión) ---
var tiene_dash = false
var tiene_doble_salto = false

# --- Lógica de Dash ---
export var dash_speed = 500
export var dash_duration = 0.15
var is_dashing = false
var can_dash_cooldown = true # Controla el tiempo de recarga

# --- Lógica de Doble Salto ---
var saltos_realizados = 0
var max_saltos = 1 # Cambia a 2 cuando consigas la habilidad
var can_double_jump_cooldown = true

var velocity = Vector2()
var is_jumping = false

# --- Referencias a Nodos ---
onready var animation_player = $AnimationPlayer
onready var sprite_2d = $Sprite 

func _physics_process(delta):
	# Si estamos en Dash, ignoramos el resto del movimiento
	if is_dashing:
		velocity = move_and_slide(velocity, Vector2.UP)
		return

	var move_dir = 0
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		move_dir += 1
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		move_dir -= 1
	
	velocity.x = move_dir * speed

	# ENTRADAS DE SALTO
	var jump_just_pressed = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	var holding_jump = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	
	# ENTRADA DE DASH (Shift o J)
	var dash_pressed = Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_J)

	# 3. VOLTEAR EL SPRITE
	if move_dir == 1:
		sprite_2d.flip_h = false
	elif move_dir == -1:
		sprite_2d.flip_h = true

	# 4. LÓGICA DE DASH (Solo si no está saltando y tiene la habilidad)
	if dash_pressed and tiene_dash and can_dash_cooldown and move_dir != 0:
		ejecutar_dash(move_dir)
		return # Detiene el resto del código para que el dash sea prioritario

	# 5. LÓGICA DE SALTO (Normal y Doble)
	if is_on_floor():
		is_jumping = false
		saltos_realizados = 0
		if jump_just_pressed:
			saltar()
	else:
		# Lógica de Doble Salto
		if jump_just_pressed and tiene_doble_salto and saltos_realizados < max_saltos and can_double_jump_cooldown:
			saltar()
			iniciar_cooldown_doble_salto()

		# Salto variable
		if is_jumping and not holding_jump and velocity.y < jump_limit:
			velocity.y = jump_limit
		
		# Gravedad
		if velocity.y < 0 and not holding_jump:
			velocity.y += jump_cutoff_gravity * delta
		else:
			velocity.y += gravity * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	actualizar_animaciones(move_dir)

func saltar():
	velocity.y = jump_speed
	is_jumping = true
	saltos_realizados += 1

func ejecutar_dash(dir):
	is_dashing = true
	can_dash_cooldown = false
	velocity.x = dir * dash_speed
	velocity.y = 0 # El dash es horizontal puro
	
	if animation_player.has_animation("Dash"):
		animation_player.play("Dash")
	
	# Tiempo que dura el impulso
	yield(get_tree().create_timer(dash_duration), "timeout")
	is_dashing = false
	
	# Tiempo de recarga (Cooldown) del Dash
	yield(get_tree().create_timer(0.8), "timeout") 
	can_dash_cooldown = true

func iniciar_cooldown_doble_salto():
	can_double_jump_cooldown = false
	# Tiempo de recarga para poder hacer otro doble salto (ej: 0.5 seg)
	yield(get_tree().create_timer(0.5), "timeout")
	can_double_jump_cooldown = true

func actualizar_animaciones(direccion):
	if is_dashing: return # No interrumpir anim de dash
	
	if is_on_floor():
		if direccion == 0:
			animation_player.play("Idle")
		else:
			animation_player.play("Walk")
	else:
		if velocity.y < 0:
			animation_player.play("Jump")
		else:
			animation_player.play("Fall")
