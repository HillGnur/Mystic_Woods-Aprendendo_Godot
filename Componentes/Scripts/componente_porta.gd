extends Area2D
class_name ComponentePorta
#Referência ao personagem
var _player_ref: Personagem = null

#Teleport Casa X,Y
@export_category("Variables")
@export var _teleport_position: Vector2

#Objetos de animação
@export_category("Objects")
@export var _animation: AnimationPlayer = null

#Quando o personagem entrar na zona de colisão da porta, a animação é iniciada
func _on_body_entered(_body):
	if _body is Personagem:
		_player_ref = _body
		#Chamada da animação da porta
		_animation.play("abrindo")

#Aqui, ele será transportado a outro lugar
func _on_porta_abrindo_animation_finished(_anim_name: String) -> void:
	if _anim_name == "abrindo":
		_player_ref.global_position = _teleport_position
		#Fechar a porta ao fim da animação de abertura e teleporte
		_animation.play("fechando")
