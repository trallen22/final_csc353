// You have to do an 'npm install mysql2' to get the package
// Documentation in: https://www.npmjs.com/package/mysql2

import { createConnection } from 'mysql2';

var connection = createConnection({
	host: 'localhost',
	user: 'root',
	password: '123456',
	database: 'NFLdata'
});

function connect() {
	connection.connect();
}

function queryCallback(queryParams, queryType, callback) {

	if(queryParams != ""){

		console.log('here')

		if(queryType == 'playerTable'){
			if(queryParams[0] == 'Career'){

				connection.query('CALL filterPlayerStatsCareer(?, ?)', [queryParams[1], queryParams[2]], (error, results, fields) => {
					if (error) throw error;

					callback(results);
				});

			}else{
				connection.query('CALL filterPlayerStats(?, ?, ?)', [queryParams[0], queryParams[1], queryParams[2]], (error, results, fields) => {
					if (error) throw error;

					callback(results);
				});
			}

		}if(queryType == 'teamTable'){
			console.log('hello', queryParams[0])
			if(!(queryParams[0] == 'Total')){
				console.log('total query')
				connection.query('CALL filterTeamStats(?, ?, ?)', [queryParams[0], queryParams[1], queryParams[2]], (error, results, fields) => {
					if (error) throw error;
	
					callback(results);
					});

			}else{
				connection.query('CALL filterTeamStatsTotal(?, ?)', [queryParams[1], queryParams[2]], (error, results, fields) => {
				if (error) throw error;

				callback(results);
				});
			}

		}

	}else{

		if(queryType == 'playerPassQuery'){
			connection.query("CALL playerPassingTotalStats()", (error, results, fields) => {
			if (error) throw error;

			callback(results);
		});
		}else if(queryType == 'playerRushQuery'){
			connection.query("CALL playerRushingTotalStats()", (error, results, fields) => {
			if (error) throw error;

			callback(results);
		});

		}else if(queryType == 'playerRecQuery'){
			connection.query("CALL playerReceivingTotalStats()", (error, results, fields) => {
			if (error) throw error;

			callback(results);
		});

		}else if(queryType == 'teamPassQuery'){
			connection.query("CALL teamPassingTotalStats()", (error, results, fields) => {
			if (error) throw error;

			callback(results);
		});
		}else if(queryType == 'teamRushQuery'){
			connection.query("CALL teamRushingTotalStats()", (error, results, fields) => {
			if (error) throw error;

			callback(results);
		});

		}else if(queryType == 'teamRecQuery'){
			connection.query("CALL teamReceivingTotalStats()", (error, results, fields) => {
			if (error) throw error;

			callback(results);
		});

		}else if(queryType == 'randPassQuery'){
			connection.query("CALL randomPassingTotalStats()", (error, results, fields) => {
			if (error) throw error;

			callback(results);
		});

		}else if(queryType == 'randRushQuery'){
			connection.query("CALL randomRushingTotalStats()", (error, results, fields) => {
			if (error) throw error;

			callback(results);
		});

		}else if(queryType == 'randRecQuery'){
			connection.query("CALL randomReceivingTotalStats()", (error, results, fields) => {
			if (error) throw error;

			callback(results);
		});

		}

		// With parameters:
		// "... WHERE name = ?", ['Fernanda'], (error ...)
	}
}


function disconnect() {
	connection.end();
}

// Setup exports to include the external variables/functions
export {
	connection,
	connect,
	queryCallback,
	disconnect
}

// For testing:
// connect()
// queryCallback(r => console.log(r))
// disconnect()