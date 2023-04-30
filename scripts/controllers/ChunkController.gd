extends Node2D

const CHUNKS_GENERATED: int = 3

@onready var _background_chunks_container: Node2D = %BackgroundChunks

var _background_chunk_scenes: Array
var _tutorial_chunk_scenes: Array

func _on_store_state_changed(_state_key: String, _substate) -> void:
  pass

func _process(_delta):
  var _chunks = _background_chunks_container.get_children()

  _chunks.sort_custom(func(a, b): return a.global_position.x < b.global_position.x)

  for _chunk in _chunks:
    if _chunk.global_position.x <= -1920.0:
      _chunk.queue_free()

  if _chunks.size() < CHUNKS_GENERATED:
    var _new_chunk: Node2D
    
    if Store.state.game == GameConstants.GAME_IN_PROGRESS && Store.state.tutorial_completed < _tutorial_chunk_scenes.size():
      _new_chunk = _tutorial_chunk_scenes[Store.state.tutorial_completed].instantiate()
      Store.set_state("tutorial_completed", Store.state.tutorial_completed + 1)
    elif Store.state.game == GameConstants.GAME_IN_PROGRESS:
      _new_chunk = _background_chunk_scenes[randi() % _background_chunk_scenes.size()].instantiate()
    else:
      _new_chunk = _background_chunk_scenes[0].instantiate()      

    _new_chunk.global_position = Vector2(_chunks[_chunks.size() - 1].global_position.x + 1920.0, 0.0)
    _background_chunks_container.add_child(_new_chunk)

func _ready():
  Store.state_changed.connect(_on_store_state_changed)

  var _chunk_scenes = DirAccess.get_files_at("res://actors/BackgroundChunks/")

  for _chunk_path in _chunk_scenes:
    _background_chunk_scenes.append(load("res://actors/BackgroundChunks/" + _chunk_path))

  var _tutorial_chunk_paths = DirAccess.get_files_at("res://actors/TutorialChunks/")

  for _chunk_path in _tutorial_chunk_paths:
    _tutorial_chunk_scenes.append(load("res://actors/TutorialChunks/" + _chunk_path))
