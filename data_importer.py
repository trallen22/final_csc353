''' 
authors: Tristan Allen, Will Cox, and Daniel Carter 

reads data from the NFL Play by Play csv and 
imports it into a sql database NFLdata 
'''

import mysql.connector
from mysql.connector import Error
import csv 
import os
import sys
from tqdm import tqdm  

HOST = 'localhost'
USER = 'root'
FILENAME = "NFL Play by Play 2009-2016 (v3).csv"
PASSWORD = '123456'

# these sets are used to check if values have already been inserted into the table 
gameSet = set()
playerIDmap = {}
playerIDcounter = 1
curPlayID = 0 # this keeps track of play_id from table play 

# sqlInsert: executes a SQL insert statement on a given table
# parameters: 
# 	table - str, name of table to insert values into 
#	curTuple - tuple, tuple of values to insert into table 	
def sqlInsert(table, curTuple):
	curValStr = "%s, " * len(curTuple) # "%s, %s, ..., %s"
	sqlStr = f"INSERT INTO {table} VALUES ({curValStr[:-2]});"
	try:
		cursor.execute(sqlStr, curTuple)
	except Exception as e:
		print(f"failed table: {table}")
		print(f"failed insert: {curTuple}")
		print(f"ERROR: {e}")

# playerIDbyName: gets a player id for sql database from a player name. Additionally
#					used to update the global variables playerIDmap and playerIDcounter
# parameters:
# 	playerName - str, name of player of interest 
# returns: 
# 	curPlayerID - int, player id in sql database 
# 	playerIDmap - dict, map of player name and player id -> { B. Roethlisberger: 1 }
# 	playerIDcounter+1 - int, adding 1 to increment the counter for AUTO_INCREMENT 
def playerIDbyName(playerName):
	# try to get the playerID from the dictionary 
	try: 
		curPlayerID = playerIDmap[playerName]
		nextPlayerIDcounter = playerIDcounter
	# add the player to the dictionary if they aren't already in it 
	except KeyError:
		curPlayerID = playerIDcounter
		nextPlayerIDcounter = playerIDcounter + 1
		playerIDmap[playerName] = curPlayerID
		sqlInsert('player', (curPlayerID, playerName))
	return curPlayerID, playerIDmap, nextPlayerIDcounter

################
# Main execution starts here
################

# used for testing, resets the database 
os.system(f'mysql NFLdata < "{os.getcwd()}/NFLschema.sql"')

try: 
	connection = mysql.connector.connect(host=HOST, user=USER, database="NFLdata", password=PASSWORD) 
except Exception as e:
	print(f'error: {e}')
	sys.exit()

cursor = connection.cursor()

with open(FILENAME, 'r', encoding='utf-8-sig') as curFile:
	curCsv = csv.DictReader(curFile)
	pbar = tqdm(desc='GOING PLAY BY PLAY', total=362447) # progress bar to total number of rows in the file 
	for row in curCsv:

		curPosTeam = row['posteam']
		if curPosTeam == "":
			pbar.update(1)
			continue

		curPlayID += 1
		# game table 
		if not row['GameID'] in gameSet:
			curGameTuple = (row['GameID'], 
							row['Date'], 
							row['HomeTeam'] if row['HomeTeam'] != 'JAC' else 'JAX', 
							row['AwayTeam'] if row['AwayTeam'] != 'JAC' else 'JAX', 
							row['Season'])
			sqlInsert('game', curGameTuple)
			gameSet.add(row['GameID'])

		# play table 
		curPlayTuple = (0, # curPlayID keeps track of this AUTO_INCREMENT 
						row['GameID'], 
						row['ydsnet'], 
						curPosTeam if curPosTeam != 'JAC' else 'JAX', 
						row['DefensiveTeam'] if row['posteam'] != 'JAC' else 'JAX', 
						row['Yards.Gained'], 
						row['Touchdown'], 
						row['TwoPointConv'] if row['TwoPointConv'] != 'NA' else None, 
						row['PlayType'], 
						row['RecFumbTeam'],
						1 if row['RecFumbTeam'] != 'NA' else 0,
						row['RecFumbPlayer'])
						# can change the number of decimal places for win_prob
		sqlInsert('play', curPlayTuple)
		
		# run table 
		if row['Rusher'] != 'NA':
			rushPlayerID, playerIDmap, playerIDcounter = playerIDbyName(row['Rusher'])
			sqlInsert('run', (curPlayID, rushPlayerID))

		# pass table 
		# using pass attempted because there are situations with a reciever but no passer
		if (row['PassAttempt'] == '1'): 
			if row['Passer'] != 'NA': 
				passerPlayerID, playerIDmap, playerIDcounter = playerIDbyName(row['Passer'])
			else:
				passerPlayerID = None
			if row['Receiver'] != 'NA':
				receiverPlayerID, playerIDmap, playerIDcounter = playerIDbyName(row['Receiver'])
			else:
				receiverPlayerID = None
			if row['Interceptor'] != 'NA':
				interceptorPlayerID, playerIDmap, playerIDcounter = playerIDbyName(row['Interceptor'])
			else: 
				interceptorPlayerID = None 
			curPassTuple = (curPlayID, 
							passerPlayerID, 
							1 if row['PassOutcome'] == "completion" else 0, 
							receiverPlayerID, 
							row['Reception'], 
							interceptorPlayerID)
			sqlInsert('pass', curPassTuple)

		pbar.update(1)

connection.commit()
cursor.close()
