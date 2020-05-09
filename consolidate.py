import numpy
import os
import sys
import pandas
import csv

os.chdir('data')
qb_stats = pandas.read_csv('WR_stats_formatted.csv')

with open('wr_combined.csv','w', newline='') as qb_csv:
    fieldnames = [  'year', 'name', 'firstname', 'lastname', 'position', 'heightfeet', 'heightinches', 
    'heightinchestotal', 'weight', 'arms', 'hands', 'fortyyd', 'twentyyd', 'tenyd', 'twentyss', 'threecone', 'vertical', 
    'broad', 'bench', 'round', 'college', 'pick', 'pickround', 'picktotal', 'wonderlic', 'nflgrade', 'games_played']
    consolidated_data_writer = csv.DictWriter(qb_csv, fieldnames=fieldnames, delimiter=',')
    consolidated_data_writer.writeheader()
    with open('wr_games_started.csv', newline='') as qb:
        qb_stats = csv.DictReader(qb, delimiter=',')
        prev_row = {"name": "Ameer Abdullah"}
        games_played = 0
        for qb_row in qb_stats:
            if prev_row['name'] == qb_row["name"]:
                games_played += int(qb_row["games_played"])
            else:
                consolidated_data_writer.writerow({
                    'year' : prev_row['year'], 
                    'name' : prev_row["name"], 
                    'firstname' :prev_row['firstname'], 
                    'lastname' : prev_row['lastname'], 
                    'position' : prev_row['position'], 
                    'heightfeet' : prev_row['heightfeet'], 
                    'heightinches' : prev_row['heightinches'], 
                    'heightinchestotal' : prev_row['heightinchestotal'], 
                    'weight' : prev_row['weight'], 
                    'arms' : prev_row['arms'], 
                    'hands' : prev_row['hands'], 
                    'fortyyd' : prev_row['fortyyd'], 
                    'twentyyd' : prev_row['twentyyd'], 
                    'tenyd' : prev_row['tenyd'],
                    'twentyss' : prev_row['twentyss'], 
                    'threecone' : prev_row['threecone'], 
                    'vertical' : prev_row['vertical'], 
                    'broad' : prev_row['broad'], 
                    'bench' : prev_row['bench'], 
                    'round' : prev_row['round'], 
                    'college' : prev_row['college'], 
                    'pick' : prev_row['pick'], 
                    'pickround' : prev_row['pickround'], 
                    'picktotal' : prev_row['picktotal'], 
                    'wonderlic' : prev_row['wonderlic'], 
                    'nflgrade' : prev_row['nflgrade'], 
                    'games_played' : games_played})
                games_played = int(qb_row["games_played"])
            prev_row = qb_row