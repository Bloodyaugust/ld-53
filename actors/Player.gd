extends Sprite2D

enum STATES {
  RUNNING,
  JUMPING,
  DOUBLEJUMPING,
  TRIPPING,
  DRIVING,
}

@export var data: PlayerData

var _state: STATES = STATES.RUNNING
var _time_running: float = 0.0
var _tween: Tween

func _jump() -> void:
  if _tween:
    _tween.kill()

  _tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)  

  match _state:
    STATES.RUNNING:
      _state = STATES.JUMPING
    STATES.JUMPING:
      _state = STATES.DOUBLEJUMPING

  _tween.tween_property(self, "position", Vector2(position.x, position.y - 80.0), 0.25)

  match _state:
    STATES.JUMPING:
      _tween.tween_property(self, "position", Vector2(position.x, 0), 0.25)
    STATES.DOUBLEJUMPING:
      _tween.tween_property(self, "position", Vector2(position.x, 0), 0.5)

  _tween.tween_callback(func(): _state = STATES.RUNNING)

func _process(delta):
  _time_running = clampf(_time_running + delta, 0.0, data.time_to_max_move_speed)

  Store.state.move_speed = data.max_move_speed * (_time_running / data.time_to_max_move_speed)

  match _state:
    STATES.RUNNING:
      if Input.is_action_just_pressed("move_up"):
        _jump()
    STATES.JUMPING:
      if Input.is_action_just_pressed("move_up") && _tween.get_total_elapsed_time() > 0.25 && _tween.get_total_elapsed_time() < 0.35:
        _jump()
