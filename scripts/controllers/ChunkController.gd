extends Node2D

const CHUNKS_GENERATED: int = 3

@onready var _background_chunks_container: Node2D = %BackgroundChunks

var _background_chunk_scenes: Array

func _process(delta):
  var _chunks = _background_chunks_container.get_children()

  _chunks.sort_custom(func(a, b): return a.position.x > b.position.x)

  for _chunk in _chunks:
    if _chunk.position.x <= -1920.0:
      print("deleting chunk")
      _chunk.queue_free()

  if _chunks.size() < CHUNKS_GENERATED:
    print("adding chunk")
    var _new_chunk = _background_chunk_scenes[0].instantiate()

    _new_chunk.position = Vector2(_chunks[_chunks.size() - 1].position.x + 1920.0, 0.0)
    _background_chunks_container.add_child(_new_chunk)

func _ready():
  var _chunk_scenes = DirAccess.get_files_at("res://actors/BackgroundChunks/")

  for _chunk_path in _chunk_scenes:
    _background_chunk_scenes.append(load("res://actors/BackgroundChunks/" + _chunk_path))
