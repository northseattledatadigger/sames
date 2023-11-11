DATA LIST LIST /index(F8) var1(F8) var2(F8) var3(F8).
BEGIN DATA
2 1 1 9 
1 2 2 4 
5 3 6 9 
4 4 7 2 
3 4 8 3
END DATA.
LIST.
descript all
/stat=all
/format=serial.
