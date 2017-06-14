
              LatticeMico8 WorkSpace Folder
              ============================


The Workspace folder for LatticeMico projects holds all the settings for the various MSB, C/C++ 
and Debugging applications and windows.  Unfortunately some of these setting files have
hard-coded, full path names included in them.  This makes it impossible to provide a
complete project that can be portable to any machine or directory location.

This Workspace is provided blank, with the following general instructions to include the
platform and C projects settings when the reference design is installed in a 
new location.




General Instructions
--------------------

1.) Install the Lattice Reference design.  This directory will be created and empty, except 
for this file.  All LatticeMico project settings will be stored here.  That is the Eclipse convention.

2.) Start LatticeMico System, choose this workspace directory for the Workspace.

3.) Add the platform file: Hardware/mico8/soc/*.msb

3.a.) Update the location of the program memory files to the new install path.  
The prom_init.mem and scratch_pad.mem will be in the Software/ directory.

3.b.) If the project uses any IPexpress generated components, then re-run IPexpress on these
components to update the path also, and generate, the NGOs.

4.) Open the C/C++ Perspective and Import Existing Projects

4.a.) The projects (directory names) are in the Software/ directory.

4.b.) For each Project, ensure that the settings under the Properties match what is needed
4.b.1) STDIO redirection to RS232 UART
4.b.2) Software->Tools->Software Deployment to Mico8 Memory Deployment to the Software directory.




