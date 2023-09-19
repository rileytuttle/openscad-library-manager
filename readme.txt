this repo will manage all the libraries for openscad

to use this make sure the OPENSCADPATH environment variable exists and points to this repos path
ie
>> echo "export OPENSCADPATH=$pwd" >> my-rc-file.zshrc

the above is not working for some reason. my guess is that snap does not use the same environment variables as what we are setting (I have also tried the recommended
>> sudo sh -c 'echo "OPENSCADPATH=$HOME/openscad/libraries" >>/etc/profile'
with a reboot but that also does not work)

so I will try to link the individual libraries inside the openscad library path (which can be found from help->library info)
above worked
so find the user library path
help->library info->User Library Path
will be something like /home/username/.local/share/OpenSCAD/libraries
that directory hopefully wont exist yet (haven't figured out how to handle if that exists and has something in it)
create symbolic link to that path

>> mkdir -p <USER_LIBRARY_PATH>
>> ln -s <OPENSCAD_LIBRARY_MANAGER_PATH> <USER_LIBRARY_PATH>
