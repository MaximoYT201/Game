
extends KinematicBody2D

# Variables de movimiento
var speed = 200
var jump_speed = -400
var gravity = 800
var jump_limit = -100 
var jump_cutoff_gravity = 1000 
var velocity = Vector2()
var is_jumping = false

# Nodo AnimationPlayer (asegúrate de que el nombre coincida con tu árbol de escenas)
onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite # Añadimos una referencia a tu nodo Sprite

func _physics_process(delta):
	
	# Reiniciar velocidad horizontal
	velocity.x = 0
	
	# Movimiento horizontal (izquierda y derecha)
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
		# Voltear el personaje para que mire a la derecha
		sprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -speed
		# Voltear el personaje para que mire a la izquierda
		sprite.flip_h = true
		
	# Lógica de salto (con altura variable)
	if is_on_floor():
		is_jumping = false
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = jump_speed
			is_jumping = true
	else:
		if is_jumping and Input.is_action_just_released("ui_up") and velocity.y < jump_limit:
			velocity.y = jump_limit
		
	# Aplicar gravedad
	if velocity.y < 0 and not Input.is_action_pressed("ui_up"):
		velocity.y += jump_cutoff_gravity * delta
	else:
		velocity.y += gravity * delta
	
	# Mover el personaje
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	# Llamar a la función de actualización de animación al final de la física
	update_animation()

# Función para controlar las animaciones
func update_animation():
	if is_on_floor():
		if velocity.x == 0:
			# Si está en el suelo y no se mueve
			anim_player.play("Idle")
		else:
			# Si está en el suelo y se mueve
			anim_player.play("Walk")
	else:
		# Si está en el aire (saltando o cayendo)
		# Podrías agregar una animación de "salto" si la tienes
		pass
