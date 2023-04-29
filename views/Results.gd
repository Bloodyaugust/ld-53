extends Control

@onready var _main_menu_button: Button = %ResultsMainMenu
@onready var _packages: Label = %ResultsPackages

func _on_main_menu_button_pressed() -> void:
  ViewController.set_client_view(ViewController.CLIENT_VIEWS.MAIN_MENU)
  Store.set_state("game", GameConstants.GAME_OVER)

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "packages":
      _packages.text = "Packages: %s" % substate

func _ready():
  Store.state_changed.connect(_on_store_state_changed)
  _main_menu_button.connect("pressed", self._on_main_menu_button_pressed)

  ViewController.register_view(ViewController.CLIENT_VIEWS.RESULTS, self)