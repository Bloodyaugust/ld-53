extends Control

const SOUND_OFF: Texture2D = preload("res://sprites/buttons/sound2.png")
const SOUND_ON: Texture2D = preload("res://sprites/buttons/sound1.png")

@onready var _play_button: TextureButton = %Play
@onready var _sound_toggle: TextureButton = %SoundToggle

func _on_play_button_pressed() -> void:
  Store.start_game()

func _on_sound_toggle_pressed() -> void:
  Store.set_state("sound", !Store.state.sound)

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "sound":
      if substate:
        _sound_toggle.texture_normal = SOUND_ON
      else:
        _sound_toggle.texture_normal = SOUND_OFF

      AudioServer.set_bus_mute(0, !substate)

func _ready():
  _play_button.connect("pressed", self._on_play_button_pressed)
  _sound_toggle.pressed.connect(_on_sound_toggle_pressed)
  Store.state_changed.connect(_on_store_state_changed)

  ViewController.register_view(ViewController.CLIENT_VIEWS.MAIN_MENU, self)
