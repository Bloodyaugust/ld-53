extends Control

@onready var _hearts: Control = %HUDHearts
@onready var _packages: Label = %HUDPackages
@onready var _player: Node2D = %Player

var _damages: int = 0
var _tween: Tween

func _on_player_damaged() -> void:
  _hearts.get_child(_damages).set_full(false)
  _damages += 1

func _on_state_changed(state_key: String, substate):
  match state_key:
    "packages":
      _packages.text = "%s" % substate  
    "game":
      match substate:
        GameConstants.GAME_IN_PROGRESS:
          if _tween:
            _tween.kill()

          modulate = Color.TRANSPARENT
          visible = true
          _tween = create_tween().set_trans(Tween.TRANS_QUAD)
          _tween.tween_property(self, "modulate", Color.WHITE, 0.5)
        GameConstants.GAME_ENDING:
          if _tween:
            _tween.kill()

          _tween = create_tween().set_trans(Tween.TRANS_QUAD)
          _tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
          _tween.tween_callback(func():
            visible = false
            _damages = 0
            
            var _heart_components: Array = _hearts.get_children()
            for _heart in _heart_components:
              _heart.set_full(true)
          )

func _ready():
  _player.damaged.connect(_on_player_damaged)
  Store.state_changed.connect(self._on_state_changed)
