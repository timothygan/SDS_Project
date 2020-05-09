import numpy
import os
import sys
import pandas
import csv

os.chdir('data')
qb_stats = pandas.read_csv('OL_stats_formatted.csv')

with open('combine.csv', newline='') as cd:
    with open('ol_games_started.csv', 'w', newline='') as qb_csv:
        fieldnames = [  'year', 'name', 'firstname', 'lastname', 'position', 'heightfeet', 'heightinches', 
        'heightinchestotal', 'weight', 'arms', 'hands', 'fortyyd', 'twentyyd', 'tenyd', 'twentyss', 'threecone', 'vertical', 
        'broad', 'bench', 'round', 'college', 'pick', 'pickround', 'picktotal', 'wonderlic', 'nflgrade', 'games_played']
        combined_data_writer = csv.DictWriter(qb_csv, fieldnames=fieldnames, delimiter=',')
        combine_data = csv.DictReader(cd, delimiter=',')
        combined_data_writer.writeheader()
        for cd_row in combine_data:
            with open('OL_stats_formatted.csv', newline='') as qb:
                qb_stats = csv.DictReader(qb, delimiter=',')
                for qb_row in qb_stats:
                    if qb_row['Name'] == cd_row['name']:
                        combined_data_writer.writerow({
                            'year' : cd_row['year'], 
                            'name' : cd_row['name'], 
                            'firstname' : cd_row['firstname'], 
                            'lastname' : cd_row['lastname'], 
                            'position' : cd_row['position'], 
                            'heightfeet' : cd_row['heightfeet'], 
                            'heightinches' : cd_row['heightinches'], 
                            'heightinchestotal' : cd_row['heightinchestotal'], 
                            'weight' : cd_row['weight'], 
                            'arms' : cd_row['arms'], 
                            'hands' : cd_row['hands'], 
                            'fortyyd' : cd_row['fortyyd'], 
                            'twentyyd' : cd_row['twentyyd'], 
                            'tenyd' : cd_row['tenyd'],
                            'twentyss' : cd_row['twentyss'], 
                            'threecone' : cd_row['threecone'], 
                            'vertical' : cd_row['vertical'], 
                            'broad' : cd_row['broad'], 
                            'bench' : cd_row['bench'], 
                            'round' : cd_row['round'], 
                            'college' : cd_row['college'], 
                            'pick' : cd_row['pick'], 
                            'pickround' : cd_row['pickround'], 
                            'picktotal' : cd_row['picktotal'], 
                            'wonderlic' : cd_row['wonderlic'], 
                            'nflgrade' : cd_row['nflgrade'], 
                            'games_played' : qb_row['Games Played']}
                        )