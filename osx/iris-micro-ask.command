#!/bin/bash
#Ask user for temperature and brightness in percentage
#For Daniel

cd -- "$(dirname "$0")"

#Ask for temperature
echo "What temperature do you want to set?"
read temp

#Ask for brightness
echo "What brightness (percent) do you want to set?"
read brightness

echo "Next time, you just need to run 'run-without-terminal.command' to run Iris micro." 
echo "If you want to edit it, just run 'iris-micro-ask.command again.'"
echo "Before running 'iris-micro-ask.command', please cover your eye and launch it, as killing iris-micro process(es) makes the screen go back to normal and there will be a flash. Remeber that."
echo "Now, please close your eyes and then press Enter. There will be a flash on the screen, which might cause seizure. You have been warned."
read

echo Killing all previous Iris micro processes
killall iris-micro

./iris-micro $temp $brightness &

#Remove old file
rm run-without-terminal.command

#Write new file
echo "#!/bin/bash" > run-without-terminal.command
echo "cd -- \"\$(dirname \"\$0\")\"" >> run-without-terminal.command
echo "killall iris-micro" >> run-without-terminal.command
echo "./iris-micro $temp $brightness &" >> run-without-terminal.command

#Setting permission for run-without-terminal.command
chmod u+x run-without-terminal.command
