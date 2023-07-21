extends CharacterBody2D
class_name Slime

var _player_ref = null
var _is_dead: bool = false

@export_category("Objects")
@export var _texture: Sprite2D = null
@export var _animation: AnimationPlayer = null

#Detectar entrada do personagem na zona de colisão
func _on_detecção_personagem_body_entered(_body):
	if _body.is_in_group("personagem"):
		_player_ref = _body
#Detectar saída do personagem da zona de colisão
func _on_detecção_personagem_body_exited(_body):
	if _body.is_in_group("personagem"):
		_player_ref = null
		
#Perseguir o jogador caso ele entre em sua zona de colisão
func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	_animate()
	if _player_ref != null:
		if _player_ref._is_dead:
			velocity = Vector2.ZERO
			move_and_slide()
			return
		var _direction: Vector2 = global_position.direction_to(_player_ref.global_position)
		var _distance: float = global_position.distance_to(_player_ref.global_position)
		
		if _distance < 16:
			_player_ref.die()
		velocity = _direction * 20
		move_and_slide()

func _animate() -> void:
	#Flip H de acordo com a direção da gosma
	if velocity.x > 0:
		_texture.flip_h = false
	elif velocity.x < 0:
		_texture.flip_h = true
		
	#Animação de Caminhada
	if velocity != Vector2.ZERO:
		_animation.play("walking_gosma")
		return
	#Animação Idle
	_animation.play("idle_gosma")

func update_health() -> void:
	_is_dead = true
	_animation.play("morte_gosma")

func _on_animação_animation_finished(_anim_name: String) -> void:
	queue_free()
