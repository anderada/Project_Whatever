extends Actionable
@export var letterID:int

func action()->void:
	super()
	InventoryData.collect_item(letterID)
