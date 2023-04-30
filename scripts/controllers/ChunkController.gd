extends Node2D

const CHUNKS_GENERATED: int = 3
const DROPOFF_POINT_SCENE: PackedScene = preload("res://actors/DropoffPoint.tscn")
const OBSTACLE_SCENE: PackedScene = preload("res://actors/Obstacle.tscn")

@onready var _background_chunks_container: Node2D = %BackgroundChunks
@onready var _dropoff_points_container: Node2D = %DropoffPoints
@onready var _obstacles_container: Node2D = %Obstacles

var _background_chunk_scenes: Array

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_RESULTS:
          GDUtil.queue_free_children(_dropoff_points_container)
          GDUtil.queue_free_children(_obstacles_container)

func _process(delta):
  var _chunks = _background_chunks_container.get_children()

  _chunks.sort_custom(func(a, b): return a.global_position.x < b.global_position.x)

  for _chunk in _chunks:
    if _chunk.global_position.x <= -1920.0:
      _chunk.queue_free()

  if _chunks.size() < CHUNKS_GENERATED:
    var _new_chunk = _background_chunk_scenes[0].instantiate()

    _new_chunk.global_position = Vector2(_chunks[_chunks.size() - 1].global_position.x + 1920.0, 0.0)
    _background_chunks_container.add_child(_new_chunk)

    if Store.state.game == GameConstants.GAME_IN_PROGRESS && _dropoff_points_container.get_child_count() < 1:
      var _potential_dropoffs = _new_chunk.get_dropoff_points()
      var _selected_dropoff: Node2D = _potential_dropoffs[randi() % _potential_dropoffs.size()]
      var _new_dropoff_point: Node2D = DROPOFF_POINT_SCENE.instantiate()

      _new_dropoff_point.global_position = _selected_dropoff.global_position
      _dropoff_points_container.add_child(_new_dropoff_point)

    if Store.state.game == GameConstants.GAME_IN_PROGRESS:
      var _new_obstacle = OBSTACLE_SCENE.instantiate()
      _new_obstacle.global_position = _new_chunk.global_position + Vector2(randf_range(-1920.0 / 2.0, 1920.0 / 2.0), _new_obstacle.position.y)

      _obstacles_container.add_child(_new_obstacle)

func _ready():
  Store.state_changed.connect(_on_store_state_changed)

  var _chunk_scenes = DirAccess.get_files_at("res://actors/BackgroundChunks/")

  for _chunk_path in _chunk_scenes:
    _background_chunk_scenes.append(load("res://actors/BackgroundChunks/" + _chunk_path))
