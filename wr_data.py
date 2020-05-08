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
    with open('wr.csv', 'w', newline='') as wr_csv:
        fieldnames = [  'position', 
                        'heightinchestotal', 
                        'weight', 
                        'fortyyd', 
                        'twentyss',
                        'vertical', 
                        'broad', 
                        'threecone',
                        'picktotal']
        wr_writer = csv.DictWriter(wr_csv, fieldnames=fieldnames, delimiter=',')
        combine_data = csv.DictReader(cd, delimiter=',')
        wr_writer.writeheader()
        for cd_row in combine_data:
            if cd_row['position'] == 'WR' and cd_row['picktotal'] != '0' and cd_row['name'] not in names:
                wr_writer.writerow({
                            'position' : cd_row['position'],     
                            'heightinchestotal' : cd_row['heightinchestotal'], 
                            'weight' : cd_row['weight'], 
                            'fortyyd' : cd_row['fortyyd'], 
                            'twentyss' : cd_row['twentyss'], 
                            'threecone' : cd_row['threecone'], 
                            'vertical' : cd_row['vertical'], 
                            'broad' : cd_row['broad'], 
                            'picktotal' : cd_row['picktotal']
                            
                })
                names.append(cd_row['name'])
    



