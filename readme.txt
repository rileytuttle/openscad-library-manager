this repo will manage all the libraries for openscad


// option 1 ----------------------------
to use this make sure the OPENSCADPATH environment variable exists and points to this repos path
ie
>> echo "export OPENSCADPATH=$pwd" >> my-rc-file.zshrc

the above is not working for some reason. my guess is that snap does not use the same environment variables as what we are setting (I have also tried the recommended
>> sudo sh -c 'echo "OPENSCADPATH=$HOME/openscad/libraries" >>/etc/profile'
with a reboot but that also does not work)

// option 2 -----------------------------

so I will try to link the individual libraries inside the openscad library path (which can be found from help->library info)
above worked
so find the user library path
help->library info->User Library Path
will be something like /home/username/.local/share/OpenSCAD/libraries
that directory hopefully wont exist yet (haven't figured out how to handle if that exists and has something in it)
create symbolic link to that path

>> mkdir -p <USER_LIBRARY_PATH>/..
>> ln -s <OPENSCAD_LIBRARY_MANAGER_PATH> <USER_LIBRARY_PATH>

// option 3 -------------------------------
clone this repo to whereever you need to use it and use the following include statement
    include <openscad-library-manager/rosetta-stone/std.scad>

this method is a little cumbersome but probably is the best method because it provides for an easy way to control for version matching

// updating ------------------------------
periodically we should pull the latest commits in the repos
>> git submodule foreach git pull origin master
or something to that effect
then check in if it works well 
