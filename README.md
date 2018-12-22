# Generations-Project-Template
This is an environment to make version control and collaboration easier for creating mods for Sonic Generations. The main function of this is the ability to work with unpacked .ar archives, where they can be easily accessed and edited, and their changes can be easily seen and recorded by git.

Using this environment involves two main directories:

### includedfiles
This directory represents the root of the Sonic Generations installation directory, and the contents are duplicated 1:1 into the build folder upon building. This is most useful for files such as movie .sfds and music .cpks/.csbs, placed inside "movie" and "Sound" subdirectories respectively. A version of the Quickboot script with custom bug fixes is included to demonstrate this function.

### modfolders
This represents the mods folder of a user's SonicGMI setup. Multiple entire mod folders are placed inside here. To make use of the handling of unpacked archives, they must be unpacked and their resulting folders' names' appended with ".ar" to indicate they represent archives. The original packed archive files must also be deleted to ensure no clashes occur upon building. Any other files including packed archives are supported: they will be simply copied over upon building. It is recommended to leave terrain archived packed due to the differences in how the archive contents of the Packed folders are intended to be split.

### Building
Simply run the build.bat file in the top directory. If a build folder already exists you will be prompted to delete it before doing so. SonicGMI/cpkredir can be pointed directly to the build/mods/modDB.ini for quick loading of mods after building (any additional mods to run alongside can be included in the modfolders directory to prevent deletion following a build).

ar0pack provided by Skyth
