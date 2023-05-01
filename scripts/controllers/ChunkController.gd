extends Node2D

const CHUNKS_GENERATED: int = 3
const MAILBOX_CHUNK_INTERVAL: int = 2

@onready var _background_chunks_container: Node2D = %BackgroundChunks

const _background_chunk_scenes: Array = [
  preload("res://actors/BackgroundChunks/Chunk-1.tscn"),
  preload("res://actors/BackgroundChunks/Chunk-2.tscn"),
  preload("res://actors/BackgroundChunks/Chunk-3.tscn"),
  preload("res://actors/BackgroundChunks/Chunk-4.tscn"),
  preload("res://actors/BackgroundChunks/Chunk-6.tscn"),
  preload("res://actors/BackgroundChunks/Chunk-7.tscn"),
]
const _empty_chunk_scenes: Array = [
  preload("res://actors/BackgroundChunks/Chunk-1.tscn"),
  preload("res://actors/BackgroundChunks/Chunk-1.tscn"),
  preload("res://actors/BackgroundChunks/Chunk-1.tscn"),
  preload("res://actors/BackgroundChunks/Chunk-9.tscn"),
]
const _mailbox_chunk_scenese: Array = [
  preload("res://actors/BackgroundChunks/Chunk-5.tscn"),
  preload("res://actors/BackgroundChunks/Chunk-8.tscn"),
]
const _tutorial_chunk_scenes: Array = [
  preload("res://actors/TutorialChunks/Chunk-1.tscn"),
  preload("res://actors/TutorialChunks/Chunk-2.tscn"),
  preload("res://actors/TutorialChunks/Chunk-3.tscn"),
]

var _chunks_since_mailbox: int = 0

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_STARTING:
          _chunks_since_mailbox = 0

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
      if _chunks_since_mailbox == MAILBOX_CHUNK_INTERVAL:
        _chunks_since_mailbox = 0
        _new_chunk = _mailbox_chunk_scenese[randi() % _mailbox_chunk_scenese.size()].instantiate()
      else:
        _chunks_since_mailbox += 1
        _new_chunk = _background_chunk_scenes[randi() % _background_chunk_scenes.size()].instantiate()
    else:
      _new_chunk = _empty_chunk_scenes[randi() % _empty_chunk_scenes.size()].instantiate()

    _new_chunk.global_position = Vector2(_chunks[_chunks.size() - 1].global_position.x + 1920.0, 0.0)
    _background_chunks_container.add_child(_new_chunk)

func _ready():
  Store.state_changed.connect(_on_store_state_changed)
