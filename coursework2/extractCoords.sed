#usage: cat ng_position.nt | sed -n -f extractCoords.sed
s%<http://data.ordnancesurvey.co.uk/id/postcodeunit/\(.*\)> <http://www.w3.org/2003/01/geo/wgs84_pos#\(.*\)> "\(.*\)"^^<http://www.w3.org/2001/XMLSchema#decimal>.%\1 \2 \3%p
s%<http://data.ordnancesurvey.co.uk/id/postcodeunit/\(.*\)> <http://data.ordnancesurvey.co.uk/ontology/spatialrelations/\(.*\)> "\(.*\)"^^<http://www.w3.org/2001/XMLSchema#decimal>.%\1 \2 \3%p