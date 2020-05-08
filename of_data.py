import numpy
import os
import sys
import pandas
import csv

# create qb.csv file
os.chdir('data')
i = 0
names = []
with open('combined_data.csv', newline='') as cd:
    with open('of.csv', 'w', newline='') as of_csv:
        fieldnames = [  'position', 
                        'heightinchestotal', 
                        'weight', 
                        'fortyyd', 
                        'twentyss',
                        'vertical', 
                        'broad', 
                        'bench',
                        'picktotal']
        of_writer = csv.DictWriter(of_csv, fieldnames=fieldnames, delimiter=',')
        combine_data = csv.DictReader(cd, delimiter=',')
        of_writer.writeheader()
        for cd_row in combine_data:
            if (cd_row['position'] == 'C' or cd_row['position'] == 'OT' or cd_row['position'] == 'OG') and cd_row['picktotal'] != '0' and cd_row['name'] not in names:
                of_writer.writerow({
                            'position' : cd_row['position'],     
                            'heightinchestotal' : cd_row['heightinchestotal'], 
                            'weight' : cd_row['weight'], 
                            'fortyyd' : cd_row['fortyyd'], 
                            'twentyss' : cd_row['twentyss'], 
                            'vertical' : cd_row['vertical'], 
                            'broad' : cd_row['broad'], 
                            'bench' : cd_row['bench'],    
                            'picktotal' : cd_row['picktotal']
                            
                })
                names.append(cd_row['name'])
    



