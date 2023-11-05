# Tristan Allen and Will Cox 

from tabnanny import check
import mysql.connector
from mysql.connector import Error
import glob
import csv 
import os
import sys
from tqdm import tqdm  

HOST = 'localhost'
USER = 'root'
FILENAME = "NFL Play by Play 2009-2016 (v3).csv"

# these sets are used to check if values have already been inserted into the table 
gameSet = set()
playerIDmap = {}
playerIDcounter = 1
curPlayID = 0 # this keeps track of play_id from table play 

# generateString: generates a string of "%s, " for sql insert statement 
# parameters: 
# 	table - str, name of table to insert values into 
# returns: str, "%s, %s, ..., %s"
def generateString(table):
	attributeLen = 0
	curStr = ''

	if table == 'game': 
		attributeLen = 5
	elif table == 'play':
		attributeLen = 34
	elif table == 'player':
		attributeLen = 2
	elif table == 'run':
		attributeLen = 2
	elif table == 'pass': 
		attributeLen = 10
	elif table == 'special_teams':
		attributeLen = 8

	curStr = "%s, " * attributeLen
	# removes last comma and space, then returns string 
	return f"({curStr[:-2]})" 

# sqlInsert: executes a SQL insert statement on a given table
# parameters: 
# 	table - str, name of table to insert values into 
#	curTuple - tuple, tuple of values to insert into table 	
def sqlInsert(table, curTuple):
	valueStr = generateString(table)
	sqlStr = f"INSERT INTO {table} VALUES {valueStr};"
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
	# add the player to the dictionary if they aren't already in it 
	except KeyError:
		curPlayerID = playerIDcounter
		playerIDmap[playerName] = curPlayerID
		sqlInsert('player', (curPlayerID, playerName))
	return curPlayerID, playerIDmap, playerIDcounter+1

################
# Main execution starts here
################

# used for testing, resets the database 
os.system('mysql NFLdata < "/Users/tristanallen/Desktop/csc 353/final_csc353/NFLschema.sql"')

try: 
	connection = mysql.connector.connect(host=HOST, user=USER, database="NFLdata") 
except Exception as e:
	print(f'error: {e}')
	sys.exit()

cursor = connection.cursor()

i = 0
with open(FILENAME, 'r', encoding='utf-8-sig') as curFile:
	curCsv = csv.DictReader(curFile)
	pbar = tqdm(desc='GOING PLAY BY PLAY', total=362447) # progress bar to total number of rows in the file 
	for row in curCsv:
		i += 1

		curPlayID += 1

		# game table 
		if not row['GameID'] in gameSet:
			curGameTuple = (row['GameID'], 
							row['Date'], 
							row['HomeTeam'], 
							row['AwayTeam'], 
							row['Season'])
			sqlInsert('game', curGameTuple)
			gameSet.add(row['GameID'])

		# play table 
		curPlayTuple = (0, # curPlayID keeps track of this AUTO_INCREMENT 
						row['GameID'], 
						row['Drive'], 
						row['qtr'], 
						row['down'] if row['down'] != 'NA' else None, 
						row['time'], 
						row['SideofField'], 
						row['yrdln'] if row['yrdln'] != 'NA' else None, 
						row['yrdline100'] if row['yrdln'] != 'NA' else None, 
						row['ydstogo'], 
						row['ydsnet'], 
						row['GoalToGo'] if row['GoalToGo'] != 'NA' else None, 
						row['FirstDown'] if row['FirstDown'] != 'NA' else None, 
						row['posteam'], 
						row['DefensiveTeam'], 
						row['Yards.Gained'], 
						row['Touchdown'], 
						row['TwoPointConv'] if row['TwoPointConv'] != 'NA' else None, 
						row['DefTwoPoint'] if row['DefTwoPoint'] != 'NA' else None, 
						row['Safety'], 
						row['PlayType'], 
						row['Tackler1'], 
						row['Tackler2'], 
						row['RecFumbTeam'], 
						row['RecFumbPlayer'],
						row['Sack'], 
						row['Accepted.Penalty'], 
						row['PenalizedTeam'],
						row['PenaltyType'], 
						row['PenalizedPlayer'], 
						row['Penalty.Yards'], 
						row['PosTeamScore'] if row['PosTeamScore'] != 'NA' else None, 
						row['DefTeamScore'] if row['DefTeamScore'] != 'NA' else None, 
						# can change the number of decimal places for win_prob
						round(float(row['Win_Prob']), 4) if row['Win_Prob'] != 'NA' else None) 
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
							row['PassOutcome'], 
							row['AirYards'], 
							receiverPlayerID, 
							row['Reception'], 
							row['YardsAfterCatch'], 
							row['QBHit'], 
							row['PassLocation'], 
							interceptorPlayerID)
			sqlInsert('pass', curPassTuple)

		# special_teams table 
		stPlay = 1 # indicator if st play, sets to false if none are found 
		# default values are None since only one st play can occur at a time
		patResult = None 
		fgResult = None 
		puntResult = None 
		returnResult = None # need to remove 
		fgDistance = None
		returnerID = None
		# Might want to incorporate 'PlayType'
		if row['ExPointResult'] != 'NA': 
			patResult = row['ExPointResult']
		elif row['FieldGoalResult'] != 'NA': 
			if row['FieldGoalDistance'] != 'NA':
				fgDistance = row['FieldGoalDistance']
			fgResult = row['FieldGoalResult']
		elif row['PuntResult'] != 'NA':
			puntResult = row['PuntResult']
		# ReturnResult and Returner include int/fumble recoveries (not st)	
		# return result shouldn't be here (at least not only in st table)
		# schema needs to be adjusted accordingly 
		elif row['ReturnResult'] != 'NA':
			if row['Returner'] != 'NA': 
				returnerID, playerIDmap, playerIDcounter = playerIDbyName(row['Returner'])
			returnResult = row['ReturnResult'] 
		else: 
			stPlay = 0 # not a st play so set to false 
		# fill table if determined as st play 
		if (stPlay):
			if row['BlockingPlayer'] != 'NA':
				blockingPlayerID, playerIDmap, playerIDcounter = playerIDbyName(row['BlockingPlayer'])
			else: 
				blockingPlayerID = None
			curStTuple = (curPlayID, 
							puntResult, 
							returnResult, 
							returnerID, 
							blockingPlayerID, 
							fgResult, 
							fgDistance, 
							patResult)
			sqlInsert('special_teams', curStTuple)


		if i == 1000:
			break 
		pbar.update(1)

connection.commit()
cursor.close()
