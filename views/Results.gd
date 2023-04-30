extends Control

@onready var _main_menu_button: TextureButton = %ResultsMainMenu
@onready var _packages: Label = %ResultsPackages

func _on_main_menu_button_pressed() -> void:
  Store.set_state("game", GameConstants.GAME_OVER)

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "packages":
      _packages.text = "%s" % substate

func _ready():
  Store.state_changed.connect(_on_store_state_changed)
  _main_menu_button.connect("pressed", self._on_main_menu_button_pressed)

  ViewController.register_view(ViewController.CLIENT_VIEWS.RESULTS, self)
