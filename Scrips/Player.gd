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
var can_dash_cooldown = true 

# --- Lógica de Doble Salto ---
var saltos_realizados = 0
var max_saltos = 1 
var can_double_jump_cooldown = true

var velocity = Vector2()
var is_jumping = false

# --- Referencias a Nodos ---
onready var animation_player = $AnimationPlayer
onready var sprite_2d = $Sprite 

func _physics_process(delta):
	if is_dashing:
		velocity = move_and_slide(velocity, Vector2.UP)
		return

	var move_dir = 0
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		move_dir += 1
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		move_dir -= 1
	
	velocity.x = move_dir * speed

	var jump_just_pressed = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	var holding_jump = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	var dash_pressed = Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_J)

	if move_dir == 1:
		sprite_2d.flip_h = false
	elif move_dir == -1:
		sprite_2d.flip_h = true

	if dash_pressed and tiene_dash and can_dash_cooldown and move_dir != 0:
		ejecutar_dash(move_dir)
		return 

	if is_on_floor():
		is_jumping = false
		saltos_realizados = 0
		if jump_just_pressed:
			saltar()
	else:
		if jump_just_pressed and tiene_doble_salto and saltos_realizados < max_saltos and can_double_jump_cooldown:
			saltar()
			iniciar_cooldown_doble_salto()

		if is_jumping and not holding_jump and velocity.y < jump_limit:
			velocity.y = jump_limit
		
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
	# Reiniciar animación de salto para el doble salto
	if saltos_realizados > 1 and animation_player.has_animation("Jump"):
		animation_player.stop()
		animation_player.play("Jump")

func ejecutar_dash(dir):
	is_dashing = true
	can_dash_cooldown = false
	velocity.x = dir * dash_speed
	velocity.y = 0 
	
	if animation_player.has_animation("Dash"):
		animation_player.play("Dash")
	
	yield(get_tree().create_timer(dash_duration), "timeout")
	is_dashing = false
	
	yield(get_tree().create_timer(0.8), "timeout") 
	can_dash_cooldown = true

func iniciar_cooldown_doble_salto():
	can_double_jump_cooldown = false
	yield(get_tree().create_timer(0.5), "timeout")
	can_double_jump_cooldown = true

# --- FUNCIÓN DE ANIMACIONES ACTUALIZADA ---
func actualizar_animaciones(direccion):
	# 1. Prioridad: Dash
	if is_dashing:
		if animation_player.has_animation("Dash"):
			animation_player.play("Dash")
		return 
	
	# 2. Animaciones en el suelo
	if is_on_floor():
		if direccion == 0:
			animation_player.play("Idle")
		else:
			animation_player.play("Walk")
	# 3. Animaciones en el aire
	else:
		if velocity.y < 0:
			# Si tienes una animación de Doble Salto, puedes ponerla aquí
			# de lo contrario, usará la de Jump normal
			animation_player.play("Jump")
		else:
			animation_player.play("Fall")
