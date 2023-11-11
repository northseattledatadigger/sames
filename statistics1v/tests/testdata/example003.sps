* Example sps file
data list / v0 to v2 1-9.
begin data.
12 12 89
56 12 77
78 12 73
90 91
37 97 85
end data.

descript all
/stat=all
/format=serial.
SAVE TRANSLATE
  /OUTFILE="newcsvfile.csv"  //location for your new file
  /TYPE=CSV
  /FIELDNAMES       //optional command to insert fieldnames in the top row
  /CELLS=LABELS.   //optional command specifying to export "labels" from the SPSS codebook (e.g. excellent). Change "labels" to "values" for value reponses (e.g. "5" for "excellent")

