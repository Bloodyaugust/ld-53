extends Control

@onready var _packages: Label = %HUDPackages

var _tween: Tween

func _on_state_changed(state_key: String, substate):
  match state_key:
    "packages":
      if substate == 1:
        _packages.text = "%s package" % substate
      else:
        _packages.text = "%s packages" % substate        
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
          _tween.tween_callback(func(): visible = false)

func _ready():
  Store.state_changed.connect(self._on_state_changed)
