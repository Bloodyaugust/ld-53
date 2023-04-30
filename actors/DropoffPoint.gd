extends Node2D

var _delivered: bool = false

func deliver() -> bool:
  if _delivered:
    return false

  _delivered = true
  return true
