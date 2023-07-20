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

function get_array_of_properties(instance_ref,arr_instance_variable_name) {
	
	gml_pragma("forceinline"); //compiler (both VM and YYC) will be forced to copy-paste function args+body as macro
							   //since this function is called for every object this will give good boost in speed
	
	//construct Tiled custom properties

	var length = array_length(arr_instance_variable_name);
	var custom_properties_array = [];
	for (var i = 0;i < length;i++) { //DO NOT replace with repeat loop ! Repeat loop cause bug with continue keyword !
		var instance_variable_name = arr_instance_variable_name[i];
		
		//todo - сделать реверс переменных f_ (аркады/сюжета) или лучше сделать скрипт для Тайлида , который будет делать то же самое , только через удобные кнопочки
		var instance_variable_value = variable_instance_get(instance_ref,instance_variable_name);
		var instance_variable_type = typeof(instance_variable_value);
		
		if (is_ptr(instance_variable_value)) { 			
			if (global.gm_to_tiled_dump_all_non_json_rejected) continue;
			global.gm_to_tiled_dump_pointer_found = true;
			instance_variable_name += "!!!POINTER!!!";
			instance_variable_type = "string";
			instance_variable_value = string(instance_variable_value);
		}
		
		//rename variables with non JSON types and mark them to be strings
		if (is_array(instance_variable_value)) {
			if (global.gm_to_tiled_dump_all_non_json_rejected) continue;
			global.gm_to_tiled_dump_array_found = true;
			instance_variable_name += "!!!ARRAY!!!";
			instance_variable_type = "string";
			instance_variable_value = string(instance_variable_value);
		}
		if (is_undefined(instance_variable_value)) {
			if (global.gm_to_tiled_dump_all_non_json_rejected) continue;
			global.gm_to_tiled_dump_undefined_found = true;
			instance_variable_name += "!!!UNDEFINED!!!";
			instance_variable_type = "string";
			instance_variable_value = string(instance_variable_value);
		}
		if (is_infinity(instance_variable_value) || (string(instance_variable_value) == "-inf" && instance_variable_type != "string")) { //yes , this shit think that is_infinity(-inf) == false :derp:
			if (global.gm_to_tiled_dump_all_non_json_rejected) continue;
			global.gm_to_tiled_dump_infinity_found = true;
			instance_variable_name += "!!!INFINITY!!!";
			instance_variable_type = "string";
			instance_variable_value = string(instance_variable_value);
		}
		//todo - обработка typeof null
		if (is_struct(instance_variable_value) && instance_variable_type != "method") {
			if (global.gm_to_tiled_dump_all_non_json_rejected) continue;
			global.gm_to_tiled_dump_struct_found = true;
			instance_variable_name += "!!!STRUCT!!!";
			instance_variable_type = "string";
			instance_variable_value = string(instance_variable_value);
		}
		if ((instance_variable_type == "method")) {
			if (global.gm_to_tiled_dump_all_non_json_rejected) continue;
			global.gm_to_tiled_dump_method_found = true;
			instance_variable_name += "!!!METHOD!!!";
			instance_variable_type = "string";
			instance_variable_value = string(instance_variable_value);
		}
		if ((instance_variable_type == "unknown")) { //if this appears then something goes terribly wrong on low level (gml manual says like memory overwrite)
			if (global.gm_to_tiled_dump_all_non_json_rejected) continue;
			global.gm_to_tiled_dump_unknown_found = true;
			instance_variable_name += "!!!UNKNOWN!!!";
			instance_variable_type = "string";
		}
		if (is_nan(instance_variable_value) && instance_variable_type != "string"/*is_nan is wierd (except for numbers) , so , it's better to do all checks before it*/) {
			if (global.gm_to_tiled_dump_all_non_json_rejected) continue;
			global.gm_to_tiled_dump_nan_found = true;
			instance_variable_name += "!!!NAN!!!";
			instance_variable_type = "string";
			instance_variable_value = string(instance_variable_value);
		}
		
		//todo - обработка typeof ref
		//(почему нету is_ref ? Как чёрт возьми оно работает ??? Окей , если это имеется ввиду индекс объекта/спрайта/звука/итд , то как отличить 1 которое число от 1 которое индекс объекта ?)
		
		//give correct Tiled types names for any number like value
		if (instance_variable_type == "number") {
			if (frac(instance_variable_value) != 0) { instance_variable_type = "float"; } else { instance_variable_type = "int"; }
		}
		if (instance_variable_type == "int32" || instance_variable_type == "int64") {instance_variable_type = "int"; }
		
		//show_debug_message(string(i) + " | " + string(instance_variable_name) + " = " + string(instance_variable_value) + " (" + instance_variable_type + ")");
		
		//todo - add "propertytype" in speceific variables (maybe it is better to do post-dump processing in Tiled itself?)
		
		var custom_propety_struct = {};
		variable_struct_set(custom_propety_struct,"name",instance_variable_name);
		variable_struct_set(custom_propety_struct,"type",instance_variable_type);
		variable_struct_set(custom_propety_struct,"value",instance_variable_value);
		array_push(custom_properties_array,custom_propety_struct);
	}
	return custom_properties_array;
}
