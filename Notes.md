## Interesting Files
  - cameras/debug.json
	May work by adding something like this (from third_person.json):
	```jsonc
	"activation_rule": {
		"type": "option",
		"camera_option": "third_person"
	}
	```

	May also require modifications to:
	  - player.animation_controllers.json

		!! resource_packs\vanilla\entity\player.entity.json > description > materials !!


## Interesting Keywords in game data (search with later)
	- inventory_item_renderer
	- ui_common.json inventory_panel.inventory_grid.grid_dimensions
	- button_mappings
	- button.menu_inventory_drop_all, button.controller_secondary_select, button.menu_inventory_drop, button.drop_one
