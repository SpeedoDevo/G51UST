BEGIN {
FS="\t"
count = 0
}

{
	split($6,date,"/")
	if($7 == DAY && date[2] == MONTH)
	{
		++count
	}
}

END{print count}