This program make a VAD on wav using webrcvad librairy. And it converts the csv obtained into a csv that can be used in 2_compareCoding_R_2.0_.R


If you want to make a VAD on all the wav of a folder:
	1.Put Convert.py, VAD.py and all_VAD.py into the folder containing the wavs
	2. launch all_VAD.py

If you want to make a VAD on a specific wav:
	1. Put VAD.py and Convert.py into the folder containing the wav
	2. Put the name of the wav you want to analyze into the path variable of the main function of VAD.py
	3. Launch VAD.py

Note that VAD.py nead Convert.py to work but you can put as a comment the following line of VAD.py (contained into the big_job function) to avoid convert to pe lauched:

	from Convert import create_file
	create_file(nom_output,nom_output)


