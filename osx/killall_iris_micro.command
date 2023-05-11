#!/bin/bash
cd -- "$(dirname "$0")"

echo Killing all previous Iris micro processes
killall iris-micro