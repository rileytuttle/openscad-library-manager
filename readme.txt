this repo will manage all the libraries for openscad that I (rileytuttle) use on a regular basis. some of my other project repos will depend on it
mostly it is BOSL2 https://github.com/BelfrySCAD/BOSL2/ plus a "rosetta-stone" which is my way of remembering useful openscad patterns that I have used before.

I included the BOSL2 submodule just in case my work depended on a specific commit hash of that. It probably will never come up but I don't want to deal with wondering why my model breaks a year later after not touching it.

there are a few options for working with this library.

// option 1 ----------------------------
this is how it is explained in the BOSL2 library installation instructions
to use this make sure the OPENSCADPATH environment variable exists and points to this repos path
ie
>> echo "export OPENSCADPATH=$pwd" >> my-rc-file.zshrc

the above is not working for me for some reason. my guess is that snap does not use the same environment variables as what we are setting (I have also tried the recommended
>> sudo sh -c 'echo "OPENSCADPATH=$HOME/openscad/libraries" >>/etc/profile'
with a reboot but that also does not work)

// option 2 -----------------------------
Using Symlinks. I used for a while before moving on to option 3
but in short you create a symlink inside the openscad library path:

1. find the user library path
openscad->help->library info->User Library Path
will be something like /home/username/.local/share/OpenSCAD/libraries (for unix type systems anyway)
that directory hopefully wont exist yet (haven't figured out how to handle if that exists and has something in it)

2. create symbolic link to that path
>> mkdir -p <USER_LIBRARY_PATH>/..
>> ln -s <OPENSCAD_LIBRARY_MANAGER_PATH> <USER_LIBRARY_PATH>

// option 3 -------------------------------
clone this repo to where ever you need to use it and use something like the following include statement
    include <openscad-library-manager/rosetta-stone/std.scad>

this method is a little cumbersome but probably is the best method because it provides for an easy way to control for version matching

// updating ------------------------------
periodically we should pull the latest commits in the repos
>> git submodule foreach git pull origin master
or something to that effect
then check in if it works well
