extends Control

@onready var _main_menu_button: Button = %ResultsMainMenu

func _on_main_menu_button_pressed() -> void:
  ViewController.set_client_view(ViewController.CLIENT_VIEWS.MAIN_MENU)
  Store.set_state("game", GameConstants.GAME_OVER)

func _ready():
  _main_menu_button.connect("pressed", self._on_main_menu_button_pressed)

  ViewController.register_view(ViewController.CLIENT_VIEWS.RESULTS, self)
