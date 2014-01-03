#!/bin/sh

# argument number checking
if [ "$#" -ne 2 ]; then
	echo "usage: POSTCODE RADIUS"
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
echo "counting accidents..."
# generating proper input for gnuplot with modified count-by-week-and-month script; take a look at it
# this way i can avoid going throug a temporary file several (7*12) times, and creating it at all
cat DfTRoadSafety_Accidents_2012.csv | awk -v EASTING=$easting -v NORTHING=$northing -v RADIUS=$radius -f nearby-accidents.awk | awk -f count-by-week-and-month.awk > plot.dat

echo "generating plot..."
#### week starts with sunday in accidents file
# passing settings to gnuplot
gnuplot << EOF
set xtic 1,1,12
set title "Accidents within a radius of $radius from $postcode"
set xlabel "Month"
set ylabel "Count of Accidents"
set key out vert right top
set style data linespoints
set terminal png size 1000,700
set output "plot_$postcode.png"
plot "plot.dat" u 1:3 t 'Monday', "" u 1:4 t 'Tuesday', "" u 1:5 t 'Wednesday', "" u 1:6 t 'Thursday', "" u 1:7 t 'Friday', "" u 1:8 t 'Saturday', "" u 1:2 t 'Sunday'
EOF

echo "removing temporary data file..."
rm plot.dat

echo "opening result: plot_${postcode}.png..."
xview -quiet "plot_${postcode}.png"