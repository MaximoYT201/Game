extends KinematicBody2D

# --- Variables de movimiento ---
export var speed = 150
export var jump_speed = -300
export var gravity = 700
export var jump_limit = -90
export var jump_cutoff_gravity = 900 

var velocity = Vector2()
var is_jumping = false

# --- Referencias a Nodos ---
onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite 

func _physics_process(delta):
	# 1. RESETEAR VELOCIDAD HORIZONTAL
	velocity.x = 0
	
	# 2. DETECTAR ENTRADAS (Corregido para que la flecha arriba no falle)
	var move_right = Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D)
	var move_left = Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A)
	
	# Detectar si se acaba de presionar cualquiera para saltar
	var jump_just_pressed = Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_SPACE)
	
	# Detectar si se mantiene presionada cualquiera para el salto largo
	var holding_jump = Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_SPACE)

	# 3. MOVIMIENTO HORIZONTAL (Animación Invertida)
	if move_right:
		velocity.x = speed
		sprite.flip_h = true  # AHORA TRUE ES DERECHA (INVERTIDO)
	elif move_left:
		velocity.x = -speed
		sprite.flip_h = false # AHORA FALSE ES IZQUIERDA (INVERTIDO)
		
	# 4. LÓGICA DE SALTO
	if is_on_floor():
		is_jumping = false
		if jump_just_pressed:
			velocity.y = jump_speed
			is_jumping = true
	else:
		# Si dejas de presionar la tecla antes de llegar al límite, el salto se corta
		if is_jumping and not holding_jump and velocity.y < jump_limit:
			velocity.y = jump_limit
		
	# 5. APLICAR GRAVEDAD
	if velocity.y < 0 and not holding_jump:
		velocity.y += jump_cutoff_gravity * delta
	else:
		velocity.y += gravity * delta
	
	# 6. EJECUTAR MOVIMIENTO
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# 7. ACTUALIZAR ANIMACIONES
	update_animation()

func update_animation():
	if is_on_floor():
		if abs(velocity.x) > 0.1:
			anim_player.play("Walk")
		else:
			anim_player.play("Idle")
	else:
		# Si tienes animación de salto, puedes ponerla aquí
		pass
