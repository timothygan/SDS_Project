import csv
from tempfile import NamedTemporaryFile
import shutil

filename = "Basic_Stats.csv"
writer = csv.writer(open('output.csv', 'w'))
with open(filename, "r") as csvFile:
	reader = csv.reader(csvFile, delimiter=',', quotechar='"')
	i = 0
	for row in reader:
		if i == 0:
			writer.writerow(row)
		else:
			print("getting here")
			new_row = row
			name_list = row[10].split(", ")
			name_list.reverse()
			name = " ".join(name_list)
			new_row[10] = name
			print(new_row)
			writer.writerow(new_row)
		i += 1