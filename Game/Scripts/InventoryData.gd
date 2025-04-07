extends Node
var collected_items :Array[bool]=[false,false,false,false]
signal updateInventory

func collect_item(id: int) -> void:
	id-=1
	if(!collected_items[id]):
		collected_items[id]=true
		updateInventory.emit(id)
