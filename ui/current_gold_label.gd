extends Label

var gold_display: int = 0

func _ready() -> void:
	PlayerGlobalStats.wallet_changed.connect(on_wallet_changed)
	
	update_display(PlayerGlobalStats.get_current_gold())
	
func update_display(amount):
	gold_display = PlayerGlobalStats.get_current_gold()
	text = str(gold_display)
	
func on_wallet_changed(amount):
	gold_display = amount
	update_display(gold_display)
