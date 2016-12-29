if [ `getconf LONG_BIT` = "64" ]
then
    echo "Starting 64-bit Iris micro"
    `dirname $0`/iris-micro_x86-64 "$@"
else
    echo "Starting 32-bit Iris micro"
    `dirname $0`/iris-micro_x86 "$@"
fi
