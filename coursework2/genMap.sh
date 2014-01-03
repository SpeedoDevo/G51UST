#!/bin/sh      

### note I used a different API that's why I used a bit more commands and variables; result: all markers are show on generated map

echo "checking argument number..."
# argument number checking
if [ "$#" -ne 2 ]; then
	echo "usage: $0 POSTCODE RADIUS"
	exit
fi


# saving argument to readable variable
radius=$2

echo "normalising postcode..."
# normalising postcode w/ previously made script
postcode=$(echo $1 | sed -f normalise.sed)

echo "getting areacode..."
# getting areacode w/ previously made script
areacode=$(echo $postcode | sed -f areacode.sed)

echo "extracting coordinates..."
# grepping lines only containing postcode; extracting postcode coordinates w/ previously made script; tr dos carriage return as it may mess up the script; save everything into buffer
coords=($(grep "$postcode" ${areacode}_position.nt | sed -n -f extractCoords.sed | cut -d\  -f3 | tr -d "\r"))
if [ -n "${coords[5]}" -o -z "${coords[0]}" ]; then
	echo Wrong postcode.
	exit
fi
# saving coordinates to readable variables
lat=${coords[0]}
long=${coords[1]}
easting=${coords[2]}
northing=${coords[3]}

echo "fetching accidents around $postcode in $radius meters..."
# getting coordinates for map markers w/ previously made script; sort w/ -n flag for accurate ordering; cut to only show cordinates, note no need for -d as tab is in fact the standard delimiter
targetbuffer=($(cat DfTRoadSafety_Accidents_2012.csv | awk -v EASTING=$easting -v NORTHING=$northing -v RADIUS=$radius -f nearby-accidents.awk | sort -n | cut -f4,5))

# close program if no accidents
if [ -z "${targetbuffer[0]}" ]; then
	echo No accidents found.
	exit
fi

echo "generating map markers..."
i=0
for i in {0..14}; do
	targetlong[i]=${targetbuffer[$((2 * i))]} # save array of markers
	targetlat[i]=${targetbuffer[$((2 * i + 1))]}
	markers+=${targetlong[i]},${targetlat[i]} # generating marker string for url
	if [ -z "${targetbuffer[$((2 * i + 2))]}"  -o "$i" -eq 14 ]; then # break loop if there are no more coordinates or early break to leave out unnecessary semicolon from marker string
		break
	fi
	markers+=';'
done

echo "zooming and centering map..."
## I need this because I use a different API that centers on a box
if [ "$i" -eq 0 ]; then # create box around marker if there's only one
	minlong=$(echo "${targetlong[0]}-0.0005" | bc -l)
	minlat=$(echo "${targetlat[0]}-0.0005" | bc -l)
	maxlong=$(echo "${targetlong[0]}+0.0005" | bc -l)
	maxlat=$(echo "${targetlat[0]}+0.0005" | bc -l)
else # finding min and max coordinates for centering and zooming map
	# awk oneliner that finds min and max values in every record; echo w/ -e flag to use newline
	minmaxbuffer=($(( echo -e "${targetlat[*]}\n${targetlong[*]}" ) | awk '{ max=$1; min=$1; for (i=1; i<=NF; i++)	{ if ($i>max) max=$i; if ($i<min) min=$i; }; printf "%0g\t%0g\t", min, max; }')) 
	minlat=${minmaxbuffer[0]}
	maxlat=${minmaxbuffer[1]}
	minlong=${minmaxbuffer[2]}
	maxlong=${minmaxbuffer[3]}
fi

echo "downloading map..."
# curl w/ -s flag to stay silent
curl -# -o "map_${postcode}.png" "http://pafciu17.dev.openstreetmap.org/?module=map&bbox=${minlong},${maxlat},${maxlong},${minlat}&height=700&width=900&points=${markers}&color=255,0,0"

echo "opening result: map_${postcode}.png..."
# opening generated map; xview w/ -quiet to stay silent
xview -quiet map_${postcode}.png