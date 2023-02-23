#!/bin/bash
a=$1
b=$2
val=`expr $a + $b`
echo "total value is $val"
echo "a - b is `expr $a - $b`"
echo "a + b is `expr $a + $b`"
echo "a * b is `expr $a \* $b`"
echo "a / b is `expr $a / $b`"
echo "a == b is `expr $a == $b`"



