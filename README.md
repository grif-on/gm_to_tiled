# gm_to_tiled
Save GameMaker object instances as Tiled .tmj/.json map file !

# Why is this here ?
I write these scripts for our game - D'LIRIUM . And we use them to create "crash dumps" , "runtime dumps" and even "whole level porting from GM to Tiled" .
As this is entirely my creation , i would like this bad boy to be an open source . Maybe you will find it useful in your GM project (or some other GM game mod , *wink*-*wink*) .

NOTE - Right now scripts consist of many comments and additional code related to D'LIRIUM . Multiple layers mode is work in progress too . So ... eventually i will refactor these scripts , write the missing mode and strip of all redundant code parts from them (but this will not be soon) .

# Setup

Import scr_get_array_of_properties.gml and scr_gm_to_tiled_dump.gml into your GameMakerStudio2 project . 

(OPTIONAL) You can use my JS script - https://github.com/grif-on/dump_tools . It will allow you to do some bulk operations in Tiled with all these dumped maps .

Ideally this is all you needed . But since i have not yet strip off all the redundant code , you will need to do that by yoursefl .

# How to use to create runtime dumps

Put these lines of code wherever you want them to be triggered when you need to create a level dump .
```gml
var file = file_text_open_write(working_directory + "debug.tmj");
file_text_write_string(file,gm_to_tiled_dump(all,true,true,true));
file_text_close(file);
```
You can change `all` to an array of instances or an object index . So , you can choose which instances you want to dump .

# How to use to create crash dumps
Read about the exception unhandled handler - https://manual.yoyogames.com/GameMaker_Language/GML_Reference/Debugging/exception_unhandled_handler.htm .
You will need to put these lines above in to the exception_unhandled_handler callback .

# How to use to port whole level from GM to Tiled

To not only dump the current state of instances , but to port a whole level (i.e. so that instances in .tmj will be the same as in the GMS2 room editor) , you need to call `gm_to_tiled_dump` on room start/restart and ensure that it is called before any of your logic code (i.e. Step , Draw , Collisions , CleanUp , etc) .
In D'LIRIUM we execute it in the Begin Step - this ensures that only variable definitions and Create code are executed before it (and thus their results are included in .tmj) .
Check out gamemaker manual about event order - https://manual.yoyogames.com/The_Asset_Editors/Object_Properties/Event_Order.htm .
