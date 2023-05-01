extends AnimatedSprite2D

@onready var _truck_exhaust: CPUParticles2D = %TruckExhaust
@onready var _truck_idle_player: AudioStreamPlayer2D = %TruckIdlePlayer
@onready var _truck_startup_player: AudioStreamPlayer2D = %TruckStartupPlayer

var _tween: Tween

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_ENDING:
          if _tween:
            _tween.kill()

          _truck_startup_player.play()
          _truck_exhaust.emitting = true
          play()
          _tween = create_tween().set_trans(Tween.TRANS_LINEAR)
          _tween.tween_interval(1.7)
          _tween.tween_callback(func(): _truck_idle_player.play())
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
            _tween.tween_interval(1.7)
            _tween.tween_callback(func(): _truck_idle_player.play())
            _tween.tween_property(self, "global_position", Vector2(0.0, global_position.y), 1.0)
            _tween.tween_property(self, "global_position", Vector2(0.0, global_position.y), 2.0)
            _truck_startup_player.play()

          _tween.tween_callback(func(): ViewController.set_client_view(ViewController.CLIENT_VIEWS.MAIN_MENU))
          play()
          _truck_exhaust.emitting = true

        GameConstants.GAME_STARTING:
          pause()
          _truck_exhaust.emitting = false
          _truck_idle_player.stop()

func _process(delta):
  match Store.state.game:
    GameConstants.GAME_IN_PROGRESS:
      global_position -= Vector2(Store.state.move_speed * delta, 0.0)
      global_position = Vector2(clampf(global_position.x, -1500.0, global_position.y), global_position.y)

func _ready():
  Store.state_changed.connect(_on_store_state_changed)
