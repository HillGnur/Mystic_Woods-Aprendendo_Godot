extends CharacterBody2D

#Nome de classe do personagem
class_name Personagem

#Criamos a variável mas não a inicializamos
var _state_machine
var _is_attacking: bool = false

@export_category("Variables")
#Export das variáveis para uso de velocidade
#Nesse caso, o personagem irá se movimentar aproximadamente 5 células por segundo
@export var _movespeed: float = 80.0
#Aqui temos a aceleração e fricção, quanto mais próximo de 1, mais forte é o fator, quanto mais longe, menor
@export var _acceleration: float = 0.4 #Quanto menor, mais demorará para acelerar
@export var _friction: float = 0.8 #Quanto menor, mais demorará para parar

#Categoria de animação de objetos, para podermos animar o personagem conforme o estado de movimentação
@export_category("Objects")
#Referência de timer
@export var _attack_timer: Timer = null
#Referência de animação
@export var _animation_tree: AnimationTree = null

#Aqui temos a primeira função a ser executada no objeto, chamando ela uma única vez, utilizando a _state_machine
func _ready() -> void:
	#Caso ao mexer com as animações, esqueçamos o AnimationTree desabilitado, por segurança, o habilitamos via código
	_animation_tree.active = true
	#A partir deste playback podemos viajar no playmode pelas animações
	_state_machine = _animation_tree["parameters/playback"]

#Chamada de atualização constante da cena (permite jogar "em tempo real")
func _physics_process(delta: float) -> void:
	_move()
	_attack()
	_animate()
	#Aplicado para movimentar o corpo junto ao vetor de direção escolhida
	#Caso o corpo bata em outro corpo, irá deslizar ao invés de parar imediatamente (como um corpo empurrando outro)
	move_and_slide()
	
#Função de movimentação
func _move() -> void:
	#Coleta dos dados de movimentação como um vetor bi-dimensional, permitindo uma movimentação em 8 direções
	var _direction:Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
		
	#Verificar se a direção do personagem é diferente do Vector2.ZERO, ou seja, um vetor zerado
	#O Vetor só será 0 se nenhuma tecla de movimentação for apertada
	if _direction != Vector2.ZERO:
		#Iremos chamar a propriedade blend-position, e definiremos a direção para a qual o personagem se movimenta
		#_animation_tree[get_param, config_param]
		_animation_tree["parameters/idle/blend_position"] = _direction
		_animation_tree["parameters/walk/blend_position"] = _direction
		_animation_tree["parameters/attack/blend_position"] = _direction
		
		#Interpolação para aplicar uma aceleração
		#lerp() é uma interpolação linear, onde a velocidade atual para a direção multiplicada pela mvspd
		velocity.x = lerp(velocity.x, (_direction.normalized().x * _movespeed), _acceleration)
		velocity.y = lerp(velocity.y, (_direction.normalized().y * _movespeed), _acceleration)
		return
		
	#Caso o if não seja cumprido (movimentação = zero), o bloco abaixo seguirá normalmente
	#Interpolação para aplicar uma fricção
	velocity.x = lerp(velocity.x, (_direction.normalized().x * _movespeed), _friction)
	velocity.y = lerp(velocity.y, (_direction.normalized().y * _movespeed), _friction)
	
	#Velocity é uma palavra reservada
	#A direção deve ser normalizada e multiplicada pela velocidade, define a taxa de quadros de movimentação
	velocity = (_direction.normalized() * _movespeed)

#Função de ataque
func _attack() -> void:
	#Caso a tecla mapeada para ataque seja pressionada, e o status de ataque seja falso ele altera o status de ataque
	if Input.is_action_just_pressed("attack") and not _is_attacking:
		#Para fazer com que o personagem pare de andar para atacar, desabilitamos a physics process
		set_physics_process(false)
		#Inicializar o temporizador para o ataque
		_attack_timer.start()
		_is_attacking = true

func _animate() -> void:
	if _is_attacking:
		_state_machine.travel("attack")
		return 
	#O length é o peso do vetor de duas direções
	#X e Y são as direções, caso maiores que 1, ele irá chamar a animação walk
	#Para diminuir o tempo de atraso entre as trocas de animações, podemos aumentar a friction, ou aumentar a length
	#Neste caso, ao invés de uma length > 1, deixei uma length > 5
	if velocity.length() > 5:
		_state_machine.travel("walk")
		return
	#Caso o length seja menor que 1, ele irá chamar a animação idle
	_state_machine.travel("idle")

#Ao fim do timer, o status de ataque se torna falso
func _on_timer_ataque_timeout():
	#Retornar as variáveis para os valores originais
	_is_attacking = false
	set_physics_process(true)

#Caso um corpo entre na hitbox, ele sofrerá dano de 1-5 de forma randômica
func _on_area_ataque_body_entered(_body):
	#Verificação do tipo de objeto/corpo
	if _body.is_in_group("enemy") or _body.is_in_group("breakable"):
		_body.update_health(randi_range(1,5))
