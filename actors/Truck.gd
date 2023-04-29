extends AnimatedSprite2D

var _tween: Tween

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_ENDING:
          if _tween:
            _tween.kill()

          play()
          _tween = create_tween().set_trans(Tween.TRANS_LINEAR)
          _tween.tween_property(self, "global_position", Vector2(0.0, global_position.y), 1.0)
          _tween.tween_callback(func():
            Store.set_state("game", GameConstants.GAME_RESULTS)
            ViewController.set_client_view(ViewController.CLIENT_VIEWS.RESULTS)
            pause()
          )
        GameConstants.GAME_OVER:
          if _tween:
            _tween.kill()

          _tween = create_tween().set_trans(Tween.TRANS_LINEAR)
          if abs(global_position.x) > 0.1:
            _tween.tween_property(self, "global_position", Vector2(0.0, global_position.y), 1.0)
          _tween.tween_callback(func(): ViewController.set_client_view(ViewController.CLIENT_VIEWS.MAIN_MENU))
          play()

        GameConstants.GAME_STARTING:
          pause()

func _process(delta):
  match Store.state.game:
    GameConstants.GAME_IN_PROGRESS:
      global_position -= Vector2(Store.state.move_speed * delta, 0.0)
      global_position = Vector2(clampf(global_position.x, -1500.0, global_position.y), global_position.y)

func _ready():
  Store.state_changed.connect(_on_store_state_changed)
