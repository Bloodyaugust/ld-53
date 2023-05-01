extends Node2D

enum STATES {
  RUNNING,
  JUMPING,
  DOUBLEJUMPING,
  TRIPPING,
  DRIVING,
  RESETTING,
}

signal damaged

const TRIP_EFFECT_SCENE: PackedScene = preload("res://actors/TripEffect.tscn")

@export var data: PlayerData

@onready var _area2D: Area2D = %PlayerArea
@onready var _dropoff_package_effect: CPUParticles2D = %DropoffPackageEffect
@onready var _dropoff_star_effect: CPUParticles2D = %DropoffStarEffect
@onready var _health: int = data.health
@onready var _shadow: Sprite2D = %PlayerShadow
@onready var _shadow_baseline: Vector2 = _shadow.global_position
@onready var _shadow_baseline_scale: Vector2 = _shadow.scale
@onready var _sprite: AnimatedSprite2D = %PlayerSprite
@onready var _truck: Node2D = %Truck

var _mailbox: Node2D
var _state: STATES = STATES.RUNNING
var _time_running: float = 0.0
var _tween: Tween

func _jump() -> void:
  if _tween:
    _tween.kill()

  _sprite.pause()
  _tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

  match _state:
    STATES.RUNNING:
      _state = STATES.JUMPING
    STATES.JUMPING:
      _state = STATES.DOUBLEJUMPING

  _tween.tween_property(self, "position", Vector2(position.x, position.y - data.jump_height), data.jump_time_to_apex)
  _tween.set_ease(Tween.EASE_IN)

  match _state:
    STATES.JUMPING:
      _tween.tween_property(self, "position", Vector2(position.x, 0), data.jump_time_to_fall)
    STATES.DOUBLEJUMPING:
      _tween.tween_property(self, "position", Vector2(position.x, 0), data.jump_time_to_fall * 2)

  _tween.tween_callback(func():
    _state = STATES.RUNNING
    _sprite.play_backwards()
  )

func _on_area_2d_entered(area: Area2D) -> void:
  if area.is_in_group("obstacle") && Store.state.game == GameConstants.GAME_IN_PROGRESS:
    if _tween:
      _tween.kill()

    var _new_trip_effect: Node2D = TRIP_EFFECT_SCENE.instantiate()
    get_tree().get_root().add_child(_new_trip_effect)
    _new_trip_effect.global_position = _sprite.global_position

    _health -= 1
    emit_signal("damaged")

    if _health <= 0:
      _state = STATES.RESETTING
      Store.state.move_speed = 0.0
      Store.set_state("game", GameConstants.GAME_ENDING)
    else:
      _sprite.pause()
      _state = STATES.TRIPPING
      _tween = create_tween().set_trans(Tween.TRANS_CUBIC)

      _tween.tween_property(self, "global_position", Vector2(global_position.x, 0.0), 0.15)
      _tween.tween_callback(func():
        _state = STATES.RUNNING
        _sprite.play_backwards()
      )

  if area.is_in_group("dropoff"):
    _mailbox = area.get_parent()

func _on_area_2d_exited(area: Area2D) -> void:
  if area.is_in_group("dropoff"):
    _mailbox = null

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_OVER:
          _health = data.health
          _state = STATES.DRIVING
          Store.state.move_speed = data.max_move_speed
          _area2D.monitorable = false
          _area2D.monitoring = false
        GameConstants.GAME_RESULTS:
          if _tween:
            _tween.kill()

          _tween = create_tween().set_trans(Tween.TRANS_LINEAR)
          _tween.tween_property(self, "global_position", _truck.global_position, 1.0)
        GameConstants.GAME_STARTING:
          if _tween:
            _tween.kill()

          _area2D.monitorable = true
          _area2D.monitoring = true
          _tween = create_tween().set_trans(Tween.TRANS_LINEAR)
          _state = STATES.RESETTING
          Store.state.move_speed = 0.0
          _tween.tween_property(self, "position", Vector2(-600.0, 0.0), 1.0)
          _tween.tween_callback(func():
            _state = STATES.RUNNING
            _sprite.play_backwards()

            Store.set_state("game", GameConstants.GAME_IN_PROGRESS)
          )

func _process(delta):
  match _state:
    STATES.RUNNING, STATES.JUMPING, STATES.DOUBLEJUMPING:
      _time_running = clampf(_time_running + delta, 0.0, data.time_to_max_move_speed)
      _shadow.global_position = Vector2(global_position.x, _shadow_baseline.y)
      _shadow.scale = _shadow_baseline_scale - (_shadow_baseline_scale * abs(global_position.y / 600))
      Store.state.move_speed = data.max_move_speed * (_time_running / data.time_to_max_move_speed)
    STATES.TRIPPING:
      _time_running = 0.0
      Store.state.move_speed = 0.0
    STATES.DRIVING:
      position = _truck.position
      _shadow.global_position = Vector2(global_position.x, global_position.y + 160.0)
    STATES.RESETTING:
      _shadow.global_position = Vector2(global_position.x, global_position.y + 160.0)      

  match _state:
    STATES.RUNNING:
      _sprite.speed_scale = Store.state.move_speed / data.max_move_speed

      if Input.is_action_just_pressed("move_up"):
        _jump()

      if GDUtil.reference_safe(_mailbox) && Input.is_action_just_pressed("move_down"):
        if _mailbox.deliver():
          _dropoff_package_effect.emitting = true
          get_tree().create_timer(0.5).timeout.connect(func(): _dropoff_star_effect.emitting = true)
          Store.set_state("packages", Store.state.packages + 1)

    STATES.JUMPING:
      if Input.is_action_just_pressed("move_up") && _tween.get_total_elapsed_time() > data.jump_time_to_apex - (data.jump_time_to_double_after_apex / 2) && _tween.get_total_elapsed_time() < data.jump_time_to_apex + (data.jump_time_to_double_after_apex / 2):
        _jump()

func _ready():
  Store.state_changed.connect(_on_store_state_changed)
  _area2D.area_entered.connect(_on_area_2d_entered)
  _area2D.area_exited.connect(_on_area_2d_exited)
