## To run the benchmarking on Arch Linux, you will need to install both the UCL and zlib libraries, compile the benchmarking code, and then execute it:

# Lib Install
``` bash
yay -S zlib
yay -S ucl
```

# Compile and run sample
``` bash
make
``` 

# For single file
``` bash
./benchmark [file_name]
``` 

# Or use the bash script to benchmark whole dir:
``` bash
chmod +x test_dir.sh
./test_dir.sh [dir]
```
