// This is a framework to handle server-side content

// You have to do an 'npm install express' to get the package
// Documentation in: https://expressjs.com/en/starter/hello-world.html
import express from 'express';

import * as db from "./db.mjs";

var app = express();
let port = 3001

db.connect();

// Serve static HTML files in the current directory (called '.')
app.use(express.static('.'))

// For GET requests to "/student?field1=value1&field2=value2"
app.get('/student', function(request, response){
    // If we have fields available
    // console.log(request.query["field1"]);

    db.queryCallback((results) => {
        response.json(results)
    })
});

app.listen(port, () => console.log('Server is starting on PORT,', port))

process.on('exit', () => {
    db.disconnect()
})