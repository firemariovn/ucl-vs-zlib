## To run the benchmarking on Arch Linux, you will need to install both the UCL and zlib libraries, compile the benchmarking code, and then execute it:

# Lib Install
`yay -S zlib
yay -S ucl`

# Compile and run sample
`make`

# For single file
`./benchmark [file_name]`

# Or use the bash script to benchmark whole dir:
`chmod +x test_dir.sh
./test_dir.sh [dir]`
