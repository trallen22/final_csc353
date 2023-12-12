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

function queryCallback(queryType, callback) {

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