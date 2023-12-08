import * as sqlite3 from 'sqlite3'

const connection = new sqlite3.default.Database(
	"./students.db",
	sqlite3.OPEN_READWRITE,
	(error) => {
	    if (error) {
		console.log("Getting error " + error)
		process.exit(1)
	    }
	}
)

function connect() {
	console.log("Not necessary if your DB is a local file")
}

function queryCallback(callback) {
	connection.all("SELECT * FROM Student", (error, results, fields) => {
		if (error) throw error;

		console.log(results)
		callback(results);
	});

	// With parameters:
	// "... WHERE name = ?", ['Fernanda'], (error ...)
}

function disconnect() {
	console.log("Not necessary if your DB is a local file")
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