extends KinematicBody2D

# --- Variables de Movimiento ---
export var speed = 150
export var jump_speed = -300     # Fuerza inicial del salto
export var gravity = 700         # Gravedad normal (caída)
export var jump_limit = -100     # Punto donde se corta el salto si sueltas
export var jump_cutoff_gravity = 1100 # Gravedad fuerte al soltar botón

var velocity = Vector2()
var is_jumping = false

# --- Referencias a Nodos (Asegúrate de que se llamen así) ---
onready var animation_player = $AnimationPlayer
onready var sprite_2d = $Sprite 

func _physics_process(delta):
	# 1. RESETEAR VELOCIDAD HORIZONTAL
	var move_dir = 0
	
	# 2. DETECTAR ENTRADAS (Soporta WASD y Flechas)
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		move_dir += 1
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		move_dir -= 1
	
	velocity.x = move_dir * speed

	# Detectar si se ACABA de presionar para saltar
	var jump_just_pressed = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	# Detectar si se MANTIENE presionado para salto variable
	var holding_jump = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)

	# 3. VOLTEAR EL SPRITE (FLIP)
	if move_dir == 1:
		sprite_2d.flip_h = false
	elif move_dir == -1:
		sprite_2d.flip_h = true

	# 4. LÓGICA DE SALTO VARIABLE
	if is_on_floor():
		is_jumping = false
		if jump_just_pressed:
			velocity.y = jump_speed
			is_jumping = true
	else:
		# SI EL JUGADOR SUELTA EL BOTÓN EN EL AIRE:
		# Cortamos el impulso hacia arriba aplicando el límite
		if is_jumping and not holding_jump and velocity.y < jump_limit:
			velocity.y = jump_limit
		
		# 5. APLICAR GRAVEDAD (Variable)
		# Si vamos hacia arriba pero no estamos presionando saltar, caemos más rápido (salto corto)
		if velocity.y < 0 and not holding_jump:
			velocity.y += jump_cutoff_gravity * delta
		else:
			velocity.y += gravity * delta
	
	# 6. EJECUTAR MOVIMIENTO
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# 7. LLAMAR A LAS ANIMACIONES
	actualizar_animaciones(move_dir)

# --- Función de Animaciones (Unificada con Lógica del Video) ---
func actualizar_animaciones(direccion):
	if is_on_floor():
		if direccion == 0:
			animation_player.play("Idle")
		else:
			animation_player.play("Walk") # O "Run", como lo hayas nombrado
	else:
		# Lógica de aire: Salto y Caída
		if velocity.y < 0:
			animation_player.play("Jump")
		else:
			animation_player.play("Fall")
