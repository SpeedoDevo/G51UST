# modified count by week and month
BEGIN {
FS="\t"
count = 0
# in the beginning the script creates a 2dim array [12, 7] only with zeros
for(i=1;i<=12;i++)
{
	for(j=1;j<=7;j++)
	{
		counters[i, j]=0
	}
}
}

{
	# get the month from file with split
	split($6,date,"/")
	# delete leading zero to work with array
	gsub ("^0*", "", date[2])
	# add 1 to proper counter in array
	++counters[date[2], $7]
}

END{
for(i=1;i<=12;i++)
{
	# print month number on start of line
	printf i"\t"
	# print counters for month
	for(j=1;j<=7;j++)
	{
		printf counters[i, j]"\t"
	}
	# newline for obvious reasons
	printf "\n"
}
}