import csv
from tempfile import NamedTemporaryFile
import shutil
import os 

os.chdir('data')
filename = "Career_Stats_Offensive_Line.csv"
writer = csv.writer(open('OL_stats_formatted.csv', 'w'))
with open(filename, "r") as csvFile:
	reader = csv.reader(csvFile, delimiter=',', quotechar='"')
	i = 0
	for row in reader:
		if i == 0:
			writer.writerow(row)
		else:
			print("getting here")
			new_row = row
			print(row[1])
			name_list = row[1].split(", ")
			name_list.reverse()
			name = " ".join(name_list)
			new_row[1] = name
			print(new_row)
			writer.writerow(new_row)
		i += 1