# fprock_hdl


To Update tcl:

	In Vivado in tcl terminal:
	
		Move to the "project_tcl" directory, this is the location that the tcl file will be output to:
		>> cd <DIR_OFFSET>/fprock_hdl/project_tcl/
	
		Write the new tcl file:
		>> write_project_tcl -force -paths_relative_to <DIR_OFFSET>/fprock_hdl/working_dir/ <PROJECT_NAME>.tcl
		
To recreate project from tcl:

	Open Vivado, in tcl terminal:
	
		Move to the "working_dir" this is where the new project will be created:
		>> cd <DIR_OFFSET>/fprock_hdl/working_dir/
		
		Run the tcl that corresponds to the desired project:
		>> source <DIR_OFFSET>/fprock_hdl/project_tcl/<PROJECT_NAME>.tcl
		
		A newly created project should open.
