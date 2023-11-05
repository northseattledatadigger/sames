    1.      Make sure all non-reporting tests run correctly.
    2.      Add tests to simply check for sane size and perhaps existence of critical characters.
    3.      Program app to read arbitrary csv file:
            a.  Use scdf file with same main name if it is accompanied.
            b.  Use specifiable scdf file.
            c.  Use specifiable scdf argument.
    4.      Set up acceptance tests:
            a.  On small downloaded files in testdata directory.
            b.  On repeatably downloadable files.  From Data.gov if possible, but it would be good to know how long life of those is.
            c.  Skel for run comparison tests to make sure output is duplicated on each implementation.
    
