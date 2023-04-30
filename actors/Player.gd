extends Node2D

enum STATES {
  RUNNING,
  JUMPING,
  DOUBLEJUMPING,
  TRIPPING,
  DRIVING,
  RESETTING,
}

@export var data: PlayerData

@onready var _area2D: Area2D = %PlayerArea
@onready var _health: int = data.health
@onready var _truck: Node2D = %Truck

var _state: STATES = STATES.RUNNING
var _time_running: float = 0.0
var _tween: Tween

func _jump() -> void:
  if _tween:
    _tween.kill()

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

  _tween.tween_callback(func(): _state = STATES.RUNNING)

func _on_area_2d_entered(area: Area2D) -> void:
  if area.is_in_group("obstacle"):
    if _tween:
      _tween.kill()

    _health -= 1

    if _health <= 0:
      _state = STATES.RESETTING
      Store.state.move_speed = 0.0
      Store.set_state("game", GameConstants.GAME_ENDING)
    else:
      _state = STATES.TRIPPING
      _tween = create_tween().set_trans(Tween.TRANS_CUBIC)

      _tween.tween_property(self, "global_position", Vector2(global_position.x, 0.0), 0.15)
      _tween.tween_callback(func(): _state = STATES.RUNNING)

  if area.is_in_group("dropoff"):
    Store.set_state("packages", Store.state.packages + 1)

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_OVER:
          _health = data.health
          _state = STATES.DRIVING
          Store.state.move_speed = data.max_move_speed
        GameConstants.GAME_RESULTS:
          if _tween:
            _tween.kill()

          _tween = create_tween().set_trans(Tween.TRANS_LINEAR)
          _tween.tween_property(self, "global_position", _truck.global_position, 1.0)
        GameConstants.GAME_STARTING:
          if _tween:
            _tween.kill()

          _tween = create_tween().set_trans(Tween.TRANS_LINEAR)
          _state = STATES.RESETTING
          Store.state.move_speed = 0.0
          _tween.tween_property(self, "position", Vector2(-600.0, 0.0), 1.0)
          _tween.tween_callback(func():
            _state = STATES.RUNNING

            Store.set_state("game", GameConstants.GAME_IN_PROGRESS)
          )

func _process(delta):
  match _state:
    STATES.RUNNING, STATES.JUMPING, STATES.DOUBLEJUMPING:
      _time_running = clampf(_time_running + delta, 0.0, data.time_to_max_move_speed)
      Store.state.move_speed = data.max_move_speed * (_time_running / data.time_to_max_move_speed)
    STATES.TRIPPING:
      _time_running = 0.0
      Store.state.move_speed = 0.0
    STATES.DRIVING:
      position = _truck.position

  match _state:
    STATES.RUNNING:
      if Input.is_action_just_pressed("move_up"):
        _jump()
    STATES.JUMPING:
      if Input.is_action_just_pressed("move_up") && _tween.get_total_elapsed_time() > data.jump_time_to_apex - (data.jump_time_to_double_after_apex / 2) && _tween.get_total_elapsed_time() < data.jump_time_to_apex + (data.jump_time_to_double_after_apex / 2):
        _jump()

func _ready():
  Store.state_changed.connect(_on_store_state_changed)
  _area2D.area_entered.connect(_on_area_2d_entered)
