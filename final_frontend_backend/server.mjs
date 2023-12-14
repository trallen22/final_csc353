// This is a framework to handle server-side content

// You have to do an 'npm install express' to get the package
// Documentation in: https://expressjs.com/en/starter/hello-world.html
import express from 'express';

import * as db from "./db_mysql.mjs";

var app = express();
let port = 3001

db.connect();

// Serve static HTML files in the current directory (called '.')
app.use(express.static('.'))

// For GET requests to "/student?field1=value1&field2=value2"
app.get('/player_pass', function(request, response){
    // If we have fields available
    // console.log(request.query["field1"]);

    db.queryCallback("",'playerPassQuery',(results) => {
        response.json(results)
    })
});

app.get('/player_rush', function(request, response){
    // If we have fields available
    // console.log(request.query["field1"]);

    db.queryCallback("",'playerRushQuery',(results) => {
        response.json(results)
    })
});

app.get('/player_rec', function(request, response){
    // If we have fields available
    // console.log(request.query["field1"]);

    db.queryCallback("",'playerRecQuery',(results) => {
        response.json(results)
    })
});

app.get('/team_pass', function(request, response){
    // If we have fields available
    // console.log(request.query["field1"]);

    db.queryCallback("",'teamPassQuery',(results) => {
        response.json(results)
    })
});

app.get('/team_rush', function(request, response){
    // If we have fields available
    // console.log(request.query["field1"]);

    db.queryCallback("",'teamRushQuery',(results) => {
        response.json(results)
    })
});

app.get('/team_rec', function(request, response){
    // If we have fields available
    // console.log(request.query["field1"]);

    db.queryCallback("",'teamRecQuery',(results) => {
        response.json(results)
    })
});

app.get('/rand_pass', function(request, response){
    // If we have fields available
    // console.log(request.query["field1"]);

    db.queryCallback("",'randPassQuery',(results) => {
        response.json(results)
    })
});

app.get('/rand_rush', function(request, response){
    // If we have fields available
    // console.log(request.query["field1"]);

    db.queryCallback("",'randRushQuery',(results) => {
        response.json(results)
    })
});

app.get('/rand_rec', function(request, response){
    // If we have fields available
    // console.log(request.query["field1"]);
    db.queryCallback("",'randRecQuery',(results) => {
        response.json(results)
    })
});

app.get('/player_table', function(request, response){
    // If we have fields available
    // console.log(request.query["field1"]);
    console.log('we got here')
    let queryParams = []
    let category = request.query["category"] 
    let year = request.query["year"]
    let way = request.query["way"]
    queryParams.push(year)
    queryParams.push(category)
    queryParams.push(way)
    db.queryCallback(queryParams, 'playerTable',(results) => {
        response.json(results)
    })
});

app.listen(port, () => console.log('Server is starting on PORT,', port))

process.on('exit', () => {
    db.disconnect()
})