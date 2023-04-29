extends Sprite2D

var _tween: Tween

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_OVER:
          if _tween:
            _tween.kill()
            
          _tween = create_tween().set_trans(Tween.TRANS_LINEAR)
          _tween.tween_property(self, "position", Vector2(-500.0, 120.0), 1.0)

func _process(delta):
  match Store.state.game:
    GameConstants.GAME_IN_PROGRESS:
      position -= Vector2(Store.state.move_speed * delta, 0.0)

func _ready():
  Store.state_changed.connect(_on_store_state_changed)
