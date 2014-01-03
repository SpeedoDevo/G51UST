# Region of interest captures letters at the start of the pattern,
# then converts them to lowercase
s/\([A-Za-z]*\).*/\L\1/