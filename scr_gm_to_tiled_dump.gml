/*
MIT License

Copyright (c) 2023 Grif_on

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

function gm_to_tiled_dump(arr_instance,save_as_one_layer,save_non_json,full_debug) {
	//How this function represent game data in Tiled format :
	//
	//Game global variables     - game global.
	//Tiled map properties      - in Tiled this is 1to1 analog of the game global variables (in Tiled can be accesed via "Map" --> "Map Properties...")
	//
	//Game built-in variables   - variables that have every instance in the game .
	//Tiled object properties   - variables that have every instance in the Tiled , BUT unlike globals/mapproperties , object properties consist only of some basic game built-in variables but not all of them !
	//
	//Game instance variables   - NON built-in variables of the game instance , number of them depend on type of instance .
	//Tiled custom properties   - analog of the game instance variables , BUT also include built-in variables that are not fit in to the Tiled object properties .

	//Note -
	//For readability and convinience sake all variables don't have "s" on the end of their names .
	//To destinguishe arrays from non array look at arr_ or abscence of it in the begining of variables names (e.g. arr_instance_variable_name is array but instance_variable_name is single string) .
	
	global.gm_to_tiled_dump_all_non_json_rejected = !(save_non_json); //Please , keep it as global , so it also will be saved in to dump/save
																	  //And please , keep name gm_to_tiled_dump_all_* , so it will be shown in tiled on top of others gm_to_tiled_dump_* (since tiled sorted properies in alphabetical order) .
	var length = 0;
	var nested_length = 0;

	global.gm_to_tiled_dump_array_found = false;
	global.gm_to_tiled_dump_undefined_found = false;
	global.gm_to_tiled_dump_infinity_found = false;
	global.gm_to_tiled_dump_nan_found = false;
	global.gm_to_tiled_dump_method_found = false;
	global.gm_to_tiled_dump_struct_found = false;
	global.gm_to_tiled_dump_unknown_found = false;
	global.gm_to_tiled_dump_pointer_found = false;
	
	#region //prepare list of built-in instance variables
	var arr_builtin_var_name = [];
	
	//we need to manually add built-in variables , since they names NOT returned by variable_instance_get_names()
	array_push(arr_builtin_var_name,"direction"); //used in saving
	array_push(arr_builtin_var_name,"speed"); //used by to many objects , better to dump by default
	if (full_debug) {
		array_push(arr_builtin_var_name,"xprevious");
		array_push(arr_builtin_var_name,"yprevious");
		//array_push(arr_builtin_var_name,"friction"); //used only in obj_part_explo_piece , but always asigned in his Step thus not needed
		//array_push(arr_builtin_var_name,"gravity"); //not used in our game
		//array_push(arr_builtin_var_name,"gravity_direction"); //not used in our game
		array_push(arr_builtin_var_name,"xstart"); //this will be helpful
		array_push(arr_builtin_var_name,"ystart"); //this will be helpful
		//array_push(arr_builtin_var_name,"hspeed"); //influeced (changed) by speed and direction , thus not needed
		//array_push(arr_builtin_var_name,"vspeed"); //influeced (changed) by speed and direction , thus not needed
		array_push(arr_builtin_var_name,"alarm");
		array_push(arr_builtin_var_name,"depth");
		//array_push(arr_builtin_var_name,"persistent"); //used only in game core (our game)
		//array_push(arr_builtin_var_name,"solid"); //not used in our game
		array_push(arr_builtin_var_name,"sprite_index"); //used only by obj_Corpse
		array_push(arr_builtin_var_name,"image_alpha");
		array_push(arr_builtin_var_name,"image_angle");
		array_push(arr_builtin_var_name,"image_blend");
		array_push(arr_builtin_var_name,"image_index");
		array_push(arr_builtin_var_name,"image_speed"); //used only by obj_Corpse
		array_push(arr_builtin_var_name,"image_xscale"); //this is for debug only , since this value is a built-in width in Tiled
		array_push(arr_builtin_var_name,"image_yscale"); //this is for debug only , since this value is a built-in height in Tiled
		array_push(arr_builtin_var_name,"mask_index");
		#region //not used in our game OR fully managed variables
		/*
		array_push(arr_builtin_var_name,"path_index");
		array_push(arr_builtin_var_name,"path_position");
		array_push(arr_builtin_var_name,"path_positionprevious");
		array_push(arr_builtin_var_name,"path_speed");
		array_push(arr_builtin_var_name,"path_scale");
		array_push(arr_builtin_var_name,"path_orientation");
		array_push(arr_builtin_var_name,"path_endaction");	
		array_push(arr_builtin_var_name,"timeline_index");
		array_push(arr_builtin_var_name,"timeline_running");
		array_push(arr_builtin_var_name,"timeline_speed");
		array_push(arr_builtin_var_name,"timeline_position");
		array_push(arr_builtin_var_name,"timeline_loop");	
		array_push(arr_builtin_var_name,"in_sequence");
		array_push(arr_builtin_var_name,"sequence_instance");
			
		//And many more GameMaker built-in Physics variables
		*/
		#endregion
		#region //read only variables
		array_push(arr_builtin_var_name,"sprite_width");
		array_push(arr_builtin_var_name,"sprite_height");
		array_push(arr_builtin_var_name,"sprite_xoffset");
		array_push(arr_builtin_var_name,"sprite_yoffset");
		array_push(arr_builtin_var_name,"image_number");
		array_push(arr_builtin_var_name,"bbox_bottom"); 
		array_push(arr_builtin_var_name,"bbox_left");
		array_push(arr_builtin_var_name,"bbox_right");
		array_push(arr_builtin_var_name,"bbox_top");
		#endregion
		
	}
	#endregion
	
	#region //prepare list of "private" instance variables (they will be skiped in non-full dump/save of level)
	//It is variables that doensn't depend on other instances/globals . They changes only by instace itself (i.e. game can determenistacally handle absence of such variable)
	//Be aware , that if you save variable "A" in save file , it is BAD idea to include variable "A" here !
	var arr_excluded_instance_var_name = []; //Also note , that this array iterated for every dumped instace , so include here only essential variables that break game for sure !
	if (!(full_debug)) {
		array_push(arr_excluded_instance_var_name,"e_temp_emitter");
		array_push(arr_excluded_instance_var_name,"e_temp_sound");
		array_push(arr_excluded_instance_var_name,"e_temp_sound_name");
		array_push(arr_excluded_instance_var_name,"e_temp_sound_begin");
		array_push(arr_excluded_instance_var_name,"e_temp_sound_begin_name");
		array_push(arr_excluded_instance_var_name,"e_temp_sound_end");
		array_push(arr_excluded_instance_var_name,"e_temp_sound_end_name");
		array_push(arr_excluded_instance_var_name,"e_temp_background");
		array_push(arr_excluded_instance_var_name,"e_temp_background_name");
		array_push(arr_excluded_instance_var_name,"e_temp_portrait");
		array_push(arr_excluded_instance_var_name,"e_temp_portrait_name");
		array_push(arr_excluded_instance_var_name,"e_temp_answer_spr");
		array_push(arr_excluded_instance_var_name,"e_temp_answer_spr_name");
		array_push(arr_excluded_instance_var_name,"e_temp_playing_begin");
		array_push(arr_excluded_instance_var_name,"e_temp_playing_end");
		array_push(arr_excluded_instance_var_name,"e_temp_option_spr");
		array_push(arr_excluded_instance_var_name,"e_temp_option_spr_name");
		array_push(arr_excluded_instance_var_name,"e_temp_option_target");
		array_push(arr_excluded_instance_var_name,"e_temp_language");
		array_push(arr_excluded_instance_var_name,"e_temp_interact");
		array_push(arr_excluded_instance_var_name,"e_temp_output");
		array_push(arr_excluded_instance_var_name,"e_temp_sprite");
		array_push(arr_excluded_instance_var_name,"e_temp_sprite_name");
		array_push(arr_excluded_instance_var_name,"e_temp_mask");
		array_push(arr_excluded_instance_var_name,"e_temp_mask_name");
		array_push(arr_excluded_instance_var_name,"e_temp_wall");
		array_push(arr_excluded_instance_var_name,"e_temp_solid"); //hold object id
		//array_push(arr_excluded_instance_var_name,"e_temp_owner"); //hold object id
		//did not exist in normal dump/save , since cyclerwalls and doorwals automatically expluded
		array_push(arr_excluded_instance_var_name,"e_temp_npc"); //hold object id
		array_push(arr_excluded_instance_var_name,"e_temp_light");
		array_push(arr_excluded_instance_var_name,"e_temp_glare");
		array_push(arr_excluded_instance_var_name,"e_temp_monst"); //hold object id
		array_push(arr_excluded_instance_var_name,"e_temp_collision");
		array_push(arr_excluded_instance_var_name,"e_temp_last_collision");
		array_push(arr_excluded_instance_var_name,"e_temp_target");
		array_push(arr_excluded_instance_var_name,"e_temp_text");
		//array_push(arr_excluded_instance_var_name,"e_temp_destination");
		//We don't need to exclude it since it is strictly checked by instance_exists() before using
		array_push(arr_excluded_instance_var_name,"e_temp_ent");
		array_push(arr_excluded_instance_var_name,"e_temp_startpos_x");
		array_push(arr_excluded_instance_var_name,"e_temp_startpos_y");
		array_push(arr_excluded_instance_var_name,"e_term_loop"); //excluded to prevent ent_sound from bugging
		array_push(arr_excluded_instance_var_name,"teleport_emitter"); //hold sound emitter index
		array_push(arr_excluded_instance_var_name,"waypoint"); //hold path index
		array_push(arr_excluded_instance_var_name,"empty"); //excluded to prevent opague drawers RNG overide (i.e. this variable disable RNG of drawers)
		array_push(arr_excluded_instance_var_name,"player_grid"); //hold index
		array_push(arr_excluded_instance_var_name,"player_surface"); //hold index
		array_push(arr_excluded_instance_var_name,"monster_chase_time"); //excluded to prevent opague monster timers RNG overide
		//do not exclude "e_temp_playing" !
		//"e_temp_playing" is saved in game saves , because of different sound function with mode "loop = true" behavior (between saving/loading in the same game session)
		array_push(arr_excluded_instance_var_name,"wpt"); //hold id
		array_push(arr_excluded_instance_var_name,"shadow_temp"); //hold sprite indedx
		array_push(arr_excluded_instance_var_name,"shadow_sprite"); //hold sprite indedx
		array_push(arr_excluded_instance_var_name,"customFollow"); //hold object id
		array_push(arr_excluded_instance_var_name,"ravelampa"); //hold object id
		array_push(arr_excluded_instance_var_name,"ravelampb"); //hold object id
		array_push(arr_excluded_instance_var_name,"owner"); //hold object id (melee projectiles)
		array_push(arr_excluded_instance_var_name,"myDegan_id"); //hold object id
		array_push(arr_excluded_instance_var_name,"myDegan_ae"); //hold audio emitter index
		//array_push(arr_excluded_instance_var_name,"spr"); //hold sprite index (of monsters)
		//array_push(arr_excluded_instance_var_name,"cry"); //hold sound index (of exhausted friends)
		//array_push(arr_excluded_instance_var_name,"snd"); //hold sound index (of NPCs)
		//spr , cry and snd is auto serialized , since it is array , thus we don't need to exculude them
		array_push(arr_excluded_instance_var_name,"snd_alert"); //hold sound index (of monsters)
		array_push(arr_excluded_instance_var_name,"snd_pain"); //hold sound index (of monsters)
		array_push(arr_excluded_instance_var_name,"snd_death"); //hold sound index (of monsters)
		//array_push(arr_excluded_instance_var_name,"arcadeTrack"); //hold sound index
		//arcadeTrack is auto serialized , since it is array , thus we don't need to exculude it
		array_push(arr_excluded_instance_var_name,"color_surface");
		//array_push(arr_excluded_instance_var_name,"surface_shadows");
		//array_push(arr_excluded_instance_var_name,"tree_surface");
		//array_push(arr_excluded_instance_var_name,"surface_lightmap");
		//array_push(arr_excluded_instance_var_name,"surface_bloom");
		//array_push(arr_excluded_instance_var_name,"mapSurface");
		//We don't need to exclude them since they strictly checked by surface_exists() before using
		//array_push(arr_excluded_instance_var_name,"customFollow");
		//We don't need to exclude it since it is strictly checked by instance_exists() before using		
		array_push(arr_excluded_instance_var_name,"item_sound"); //hold sound index of item
		array_push(arr_excluded_instance_var_name,"vox_sprite"); //hold sprite index of item
		array_push(arr_excluded_instance_var_name,"e_temp_destination"); //hold instance index
		//array_push(arr_excluded_instance_var_name,"e_temp_any"); // hold struct and auto serialized , thus we don't need to exculude it
	}
	#endregion
	
	#region //Tiled layers
	var arr_tiled_layer = [];
	var next_tiled_layer_id = 0;
	var next_tiled_object_id = 0;
	var arr_next_tiled_object_id_pretendent = [];
	
	if (save_as_one_layer) { //quikly dump all objects in to single layer
		var arr_object = [];
	
		with (arr_instance) {
			var object_is_a_game_core = false //true - do not include game cores unless this is the "last breath" dump of the game (before crushing)
			var object_is_fully_managed = false; //true - do not include objects wich life cycle fully managed by other objects (via ref)
			var object_is_always_rectangle = false;
			if (object_is_ancestor(object_index,obj_dev_materials)) object_is_always_rectangle = true;
			switch (object_index) {
				case obj_dev_gameconsole:
				case obj_controller:
				case obj_dev_controller_bot:
				case obj_gamecontroller:
				case obj_FightSystem:
				case obj_scriptedSequence:
				case obj_saveMenu:
				case obj_pause:
				case obj_Cursor:
					object_is_a_game_core = true;
					break;
				case obj_doorwall:
				case obj_cyclerwall:
				case obj_cyclerwall_solid:
					object_is_fully_managed = true;
					object_is_always_rectangle = true;
					break;
				case ent_forceload:
				case ent_trigger:
				case obj_trigger_secret:
				case obj_checkbox:
				case obj_wall:
				case obj_halfwall:
				case obj_voidwall:
					object_is_always_rectangle = true;
					break;
				default:	break;
			}
			if ((!full_debug) && (object_is_a_game_core || object_is_fully_managed)) continue; //skip one cycle of with()
			
			var object = {};
		
			var arr_concatenated_instance_var_name = array_concat(variable_instance_get_names(id),arr_builtin_var_name);
		
			length = array_length(arr_excluded_instance_var_name);
			for (var i = 0;i < length;i++) { //DO NOT replace with repeat loop ! Repeat loop cause bug with continue keyword !
				var index_to_delete = array_get_index(arr_concatenated_instance_var_name,arr_excluded_instance_var_name[i]);
				if (index_to_delete < 0) continue;
				array_delete(arr_concatenated_instance_var_name,index_to_delete,1/*how many*/);
			}

	
			//Tiled object properties
			variable_struct_set(object,"height",sprite_height); //note - sprite_height is already have image_yscale multiplication in it ! The real sprite can be finded with sprite_get_height() .
			variable_struct_set(object,"width",sprite_width); //same for sprite_width
			variable_struct_set(object,"id",id);
			variable_struct_set(object,"name","");
			if ((image_xscale == 0 && image_yscale == 0) || /*point in the Tiled*/
			(image_xscale == 1 && image_yscale == 1 && (!object_is_always_rectangle)) || /*point in the room editor*/
			(sprite_height == 0 && sprite_width == 0)/*point because in game doesnt have hitbox at all*/) variable_struct_set(object,"point",true);
			variable_struct_set(object,"rotation",(-image_angle)); // rotation of object in Tiled (backward compatability with scr_custommap_loadder)
			variable_struct_set(object,"type",object_get_name(object_index));
			variable_struct_set(object,"visible",visible);
			variable_struct_set(object,"x",x);
			variable_struct_set(object,"y",y);
		
		
			//====== main work under extracting and converting instance variables in to custom properties ======//
			variable_struct_set(object,"properties",get_array_of_properties(id,arr_concatenated_instance_var_name));
			//==================================================================================================//
		
			array_push(arr_next_tiled_object_id_pretendent,id)
			array_push(arr_object,object);
		}
		var single_layer = {};
		variable_struct_set(single_layer,"draworder","topdown");
		variable_struct_set(single_layer,"id",0);
		variable_struct_set(single_layer,"name","All objects");//todo - layer_get_name()
		variable_struct_set(single_layer,"opacity",1);
		variable_struct_set(single_layer,"type","objectgroup");
		variable_struct_set(single_layer,"visible",true);
		variable_struct_set(single_layer,"x",0);
		variable_struct_set(single_layer,"y",0);
		variable_struct_set(single_layer,"objects",arr_object);
		//todo - layer_get_depth()
		next_tiled_layer_id = 1;
		array_sort(arr_next_tiled_object_id_pretendent,false);
		next_tiled_object_id = int64(arr_next_tiled_object_id_pretendent[0]) + 1;
		//int64 needed since id is a typeof = ref (and ref + number produce game crash)
		array_push(arr_tiled_layer,single_layer);
	} else { //dump objects in to their respective layers
		//todo - реализация множества слоёв
		
		//пока что набросок , код не слишком рабочий
		//construct layers
		var arr_game_layer = layer_get_all();

		length = array_length(arr_game_layer);
		for (var i = 0;i < length;i++) {
			var game_layer = arr_game_layer[i];
			var layer_elements = layer_get_all_elements(game_layer);
			nested_length = array_length(layer_elements);
			//show_debug_message("game_layer.depth = " + string(layer_get_depth(game_layer)));
			//show_debug_message("game_layer.name = " + string(layer_get_name(game_layer)));
			for (var o = 0;o < nested_length;o++) { //DO NOT replace with repeat loop ! Repeat loop cause bug with continue keyword !
				var current_thing = layer_instance_get_instance(layer_elements[o]);
				if (current_thing < 0) continue; //do nothing if this thing is not an instance
				//show_debug_message("current_thing.id = " + string(int64(current_thing.id)));
			}
			next_tiled_layer_id++;
			//array_push(arr_tiled_layer,game_layer);
		}

	}
	#endregion
	
	#region //Tiled map properties
	var arr_map_prop = [];	
	var arr_global_var_name = variable_struct_get_names(global); //yes , global is a stuct :)
	var arr_excluded_global_var_name = [];
	#region //never include this variables , even in game crush dumps and full dumps !
		array_push(arr_excluded_global_var_name,"steam_player_id"); //In any situation , do not expose player real steam id ! We need to ensure that players can safely share their level dump/saves without risk to exopose their maybe private accaunt !
		array_push(arr_excluded_global_var_name,"achiev_stat_Cheated"); //Just to prevent saved levels to be marked . Note that "dumped" levels marked as global_disable_achievements instead of vanilla achiev_stat_Cheated .
	#endregion
	if (!(full_debug)) {
		array_push(arr_excluded_global_var_name,"steam_app_id"); //This variable can be helpfull in full dumps , despite that it can only contain "670160" and "0" it can help determine whether game was been conected to steam client or not .
		array_push(arr_excluded_global_var_name,"font_classic"); //hold index
		array_push(arr_excluded_global_var_name,"font_default"); //hold index
		array_push(arr_excluded_global_var_name,"font_delirium"); //hold index
		array_push(arr_excluded_global_var_name,"font_mini"); //hold index

		array_push(arr_excluded_global_var_name,"custommap_name"); //just to prevent overwrite
		array_push(arr_excluded_global_var_name,"custommap_folder"); //just to prevent overwrite
		array_push(arr_excluded_global_var_name,"custommap_current"); //just to prevent overwrite
		array_push(arr_excluded_global_var_name,"custommap_assets"); //hold array of indexes
		array_push(arr_excluded_global_var_name,"custommap_backgrounds"); //hold array of indexes
		array_push(arr_excluded_global_var_name,"custommap_layers"); //hold array of indexes
		array_push(arr_excluded_global_var_name,"custommap_struct");
		array_push(arr_excluded_global_var_name,"game_last_save_file"); //just to prevent overwrite
		array_push(arr_excluded_global_var_name,"game_loading_file"); //just to prevent overwrite
		array_push(arr_excluded_global_var_name,"lantern_grid"); //hold index
		array_push(arr_excluded_global_var_name,"level_data"); //cached custommap data (for instance this consume 30 kilobytes in pandemonium)
		array_push(arr_excluded_global_var_name,"stat_data"); //cached globals data
		array_push(arr_excluded_global_var_name,"level_music_current"); //hold index and break music
		array_push(arr_excluded_global_var_name,"player_dialogue_current"); //hold index
		array_push(arr_excluded_global_var_name,"spr_customPlayerGame"); //hold index
		array_push(arr_excluded_global_var_name,"spr_customPlayerRender"); //hold index
		array_push(arr_excluded_global_var_name,"spr_presetPlayerGame"); //hold index
		array_push(arr_excluded_global_var_name,"surface_decal"); //hold index
		array_push(arr_excluded_global_var_name,"surface_thunder"); //hold index
		#region // particles indexes
		array_push(arr_excluded_global_var_name,"pt_Blink_Patricles");
		array_push(arr_excluded_global_var_name,"pt_Blink_Smoke");
		array_push(arr_excluded_global_var_name,"pt_Blood_Blast");
		array_push(arr_excluded_global_var_name,"pt_Blood_Blast_Smoke");
		array_push(arr_excluded_global_var_name,"pt_Blood_Splash");
		array_push(arr_excluded_global_var_name,"pt_Book");
		array_push(arr_excluded_global_var_name,"pt_Concrete");
		array_push(arr_excluded_global_var_name,"pt_Fireball_Explosion_Flame");
		array_push(arr_excluded_global_var_name,"pt_Fireball_Explosion_Flame_Quad");
		array_push(arr_excluded_global_var_name,"pt_Fireball_Explosion_Smoke");
		array_push(arr_excluded_global_var_name,"pt_Fireball_Explosion_Smoke_Quad");
		array_push(arr_excluded_global_var_name,"pt_Fireball_Flame");
		array_push(arr_excluded_global_var_name,"pt_Fireball_Flame_Quad");
		array_push(arr_excluded_global_var_name,"pt_Fireball_Smoke");
		array_push(arr_excluded_global_var_name,"pt_Fireball_Smoke_Quad");
		array_push(arr_excluded_global_var_name,"pt_Health_Up");
		array_push(arr_excluded_global_var_name,"pt_Item_Pickup_Flame");
		array_push(arr_excluded_global_var_name,"pt_Item_Pickup_Sparks");
		array_push(arr_excluded_global_var_name,"pt_Key_PickUp");
		array_push(arr_excluded_global_var_name,"pt_Pike_Flame");
		array_push(arr_excluded_global_var_name,"pt_Plasma_Explosion");
		array_push(arr_excluded_global_var_name,"pt_Plasma_Explosion_Quad");
		array_push(arr_excluded_global_var_name,"pt_Plasma_Explosion_Smoke");
		array_push(arr_excluded_global_var_name,"pt_Plasma_Explosion_Smoke_Quad");
		array_push(arr_excluded_global_var_name,"pt_Plasma_Flame");
		array_push(arr_excluded_global_var_name,"pt_Plasma_Flame_Quad");
		array_push(arr_excluded_global_var_name,"pt_Player_Infection");
		array_push(arr_excluded_global_var_name,"pt_Present_Disappear");
		array_push(arr_excluded_global_var_name,"pt_Rune_Nuke");
		array_push(arr_excluded_global_var_name,"pt_Rune_Pickup");
		array_push(arr_excluded_global_var_name,"pt_Rune_Protection");
		array_push(arr_excluded_global_var_name,"pt_Rune_Quad");
		array_push(arr_excluded_global_var_name,"pt_Sanity_Up");
		array_push(arr_excluded_global_var_name,"pt_Slime_Explosion_Flame");
		array_push(arr_excluded_global_var_name,"pt_Slime_Explosion_Smoke");
		array_push(arr_excluded_global_var_name,"pt_Slime_Flame");
		array_push(arr_excluded_global_var_name,"pt_Slime_Smoke");
		array_push(arr_excluded_global_var_name,"pt_Smoke");
		array_push(arr_excluded_global_var_name,"pt_Smoke_Big");
		array_push(arr_excluded_global_var_name,"pt_Smoke_Small");
		array_push(arr_excluded_global_var_name,"pt_Smoke_Up");
		array_push(arr_excluded_global_var_name,"pt_Smoke_Up_Big");
		array_push(arr_excluded_global_var_name,"pt_Smoke_Up_Small");
		array_push(arr_excluded_global_var_name,"pt_Spark");
		array_push(arr_excluded_global_var_name,"pt_Spark_Color");
		array_push(arr_excluded_global_var_name,"pt_Steam");
		array_push(arr_excluded_global_var_name,"pt_Teleball_Explosion_Flame");
		array_push(arr_excluded_global_var_name,"pt_Teleball_Explosion_Smoke");
		array_push(arr_excluded_global_var_name,"pt_Teleball_Smoke");
		array_push(arr_excluded_global_var_name,"pt_Teleport_Patricles");
		array_push(arr_excluded_global_var_name,"pt_Telepot_Smoke");
		array_push(arr_excluded_global_var_name,"pt_Toxin_Up");
		array_push(arr_excluded_global_var_name,"pt_explosion_center");
		array_push(arr_excluded_global_var_name,"pt_explosion_particle");
		array_push(arr_excluded_global_var_name,"pt_explosion_smoke");
		#endregion
		#region // configs
		array_push(arr_excluded_global_var_name,"config_sound");
		array_push(arr_excluded_global_var_name,"config_music");
		array_push(arr_excluded_global_var_name,"config_voice");
		array_push(arr_excluded_global_var_name,"config_controls");
		array_push(arr_excluded_global_var_name,"config_hud");
		array_push(arr_excluded_global_var_name,"config_hints");
		array_push(arr_excluded_global_var_name,"config_language");
		array_push(arr_excluded_global_var_name,"config_windowed");
		array_push(arr_excluded_global_var_name,"config_font");
		array_push(arr_excluded_global_var_name,"config_camera");
		array_push(arr_excluded_global_var_name,"config_flashlight");
		array_push(arr_excluded_global_var_name,"config_score");
		array_push(arr_excluded_global_var_name,"config_healthbars");
		array_push(arr_excluded_global_var_name,"config_time");
		array_push(arr_excluded_global_var_name,"config_inspector");
		array_push(arr_excluded_global_var_name,"config_resolution");
		array_push(arr_excluded_global_var_name,"config_shadows");
		array_push(arr_excluded_global_var_name,"config_bloom");
		array_push(arr_excluded_global_var_name,"config_noise");
		array_push(arr_excluded_global_var_name,"config_gamespeed");
		array_push(arr_excluded_global_var_name,"config_voxel");
		array_push(arr_excluded_global_var_name,"config_gui");
		array_push(arr_excluded_global_var_name,"config_ignoreerrs");
		array_push(arr_excluded_global_var_name,"config_screenshot");
		#endregion
		array_push(arr_excluded_global_var_name,"current_sigil"); //hold index
		array_push(arr_excluded_global_var_name,"spr_presetPlayerGame"); //hold index
		array_push(arr_excluded_global_var_name,"spr_customPlayerRender"); //hold index
		array_push(arr_excluded_global_var_name,"spr_customPlayerGame"); //hold index
		array_push(arr_excluded_global_var_name,"partsystem"); //hold index
		array_push(arr_excluded_global_var_name,"lantern_grid"); //hold index
		array_push(arr_excluded_global_var_name,"monster_lost"); //hold array of indexes
		array_push(arr_excluded_global_var_name,"game_forceloaded_monsters"); //hold ds_map index
	}
	//Also we need to exclude dump flags from unordered array . We will return them latter so they will be in the end of array ...
	array_push(arr_excluded_global_var_name,"gm_to_tiled_dump_array_found");
	array_push(arr_excluded_global_var_name,"gm_to_tiled_dump_undefined_found");
	array_push(arr_excluded_global_var_name,"gm_to_tiled_dump_infinity_found");
	array_push(arr_excluded_global_var_name,"gm_to_tiled_dump_nan_found");
	array_push(arr_excluded_global_var_name,"gm_to_tiled_dump_method_found");
	array_push(arr_excluded_global_var_name,"gm_to_tiled_dump_struct_found");
	array_push(arr_excluded_global_var_name,"gm_to_tiled_dump_unknown_found");
	array_push(arr_excluded_global_var_name,"gm_to_tiled_dump_pointer_found");
	length = array_length(arr_excluded_global_var_name);
	for (var i = 0;i < length;i++) { //DO NOT replace with repeat loop ! Repeat loop cause bug with continue keyword !
		var index_to_delete = array_get_index(arr_global_var_name,arr_excluded_global_var_name[i]);
		if (index_to_delete < 0) {
			if (!global.config_ignoreerrs) show_message("not existing global name in arr_excluded_global_var_name ! (" + string(arr_excluded_global_var_name[i]) + ")"); 
			continue;
			}
		array_delete(arr_global_var_name,index_to_delete,1/*how many*/);
	}
	
	// ... and here we return dump flags back . This will ensure that they always will be processed in the end , thus will track non JSON types even in global variables itselfs .
	array_push(arr_global_var_name,"gm_to_tiled_dump_array_found");
	array_push(arr_global_var_name,"gm_to_tiled_dump_undefined_found");
	array_push(arr_global_var_name,"gm_to_tiled_dump_infinity_found") ;
	array_push(arr_global_var_name,"gm_to_tiled_dump_nan_found");
	array_push(arr_global_var_name,"gm_to_tiled_dump_method_found");
	array_push(arr_global_var_name,"gm_to_tiled_dump_struct_found");
	array_push(arr_global_var_name,"gm_to_tiled_dump_unknown_found");
	array_push(arr_global_var_name,"gm_to_tiled_dump_pointer_found");
	
	//====== main work under extracting and converting global variables in to custom map properties ======//
	arr_map_prop = get_array_of_properties(global,arr_global_var_name);
	//==================================================================================================//
	
	
	#endregion

	#region //Main Tiled structure
	var final_structure = {};
	var tile_size = 8;
	variable_struct_set(final_structure,"height",room_height/tile_size);
	variable_struct_set(final_structure,"infinite",false);
	variable_struct_set(final_structure,"layers",arr_tiled_layer);
	variable_struct_set(final_structure,"nextlayerid",next_tiled_layer_id);
	variable_struct_set(final_structure,"nextobjectid",next_tiled_object_id);
	variable_struct_set(final_structure,"orientation","orthogonal");
	variable_struct_set(final_structure,"properties",arr_map_prop);
	variable_struct_set(final_structure,"renderorder","right-down");
	variable_struct_set(final_structure,"tiledversion","gm_to_tiled");
	variable_struct_set(final_structure,"tileheight",tile_size);
	variable_struct_set(final_structure,"tilesets",[]);
	variable_struct_set(final_structure,"tilewidth",tile_size);
	variable_struct_set(final_structure,"type","map");
	variable_struct_set(final_structure,"version","1.0");
	variable_struct_set(final_structure,"width",room_width/tile_size);
	#endregion

	return json_stringify(final_structure,global.force_gm_to_tiled_dump_prettify_output);
	//Single-line json (prettify = false) is faster and consume less RAM to generate (and disk space lol) . 
	//And since Tiled can read single-line type of json (and then prettify it on resaving) it is better to leave it false by default .
	//However , analising of such single-line files in the WinMerge/KDiff3/etc is a hellish mess .
	//For debuging , Tiled prettifer is a bad choice either , since it will reorganize all content in alphabeticall order (and thus , make diff tools useless) .
	//So , it is better to always have ability to switch prettify to true in the game itself !
}
