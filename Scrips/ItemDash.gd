extends Area2D

# Referencia al nodo de animación
onready var anim_player = $AnimationPlayer

func _ready():
	# Esto asegura que la animación "Idle" o "Flotar" comience sola
	# Cambia "Idle" por el nombre exacto que le pusiste a tu animación
	if anim_player.has_animation("Idle"):
		anim_player.play("Idle")

func _on_ItemDash_body_entered(body):
	# Verificamos si lo que entró es tu jugador
	if body.name == "KinematicBody2D": 
		body.tiene_dash = true 
		print("¡Dash desbloqueado!")
		queue_free()
		queue_free()
