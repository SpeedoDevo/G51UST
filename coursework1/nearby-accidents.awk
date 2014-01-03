BEGIN {FS=","}
{
	if(EASTING - RADIUS <= $2 && $2 <= EASTING + RADIUS && NORTHING - RADIUS <= $3 && $3 <= NORTHING + RADIUS) # making this four comparisons makes the script faster; basically this draws a square around ESTING and NORTHING with 2*RADIUS sides so the script only counts the distance for these values
	{
		distance = sqrt((EASTING - $2)^2  + (NORTHING - $3)^2)
		if(distance <= RADIUS)
			{
			print distance"\t"$2"\t"$3"\t"$4"\t"$5"\t"$10"\t"$11
			}
	}	
}