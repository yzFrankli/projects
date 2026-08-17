// const { parse } = require("csv-parse");
// const fs = require("fs");

// // specify the path of the CSV file
// const path = "./companies-1.csv";

// // Create a readstream
// // Parse options: delimiter and start from line 1

// fs.createReadStream(path)
//   .pipe(parse({ delimiter: ",", from_line: 1 }))
//   .on("data", function (row) {
//     // executed for each row of data
//     console.log(row);
//   })
//   .on("error", function (error) {
//     // Handle the errors
//     console.log(error.message);
//   })
//   .on("end", function () {
//     // executed when parsing is complete
//     console.log("File read successful");
//   });

var http = require('http');
var port = process.env.PORT || 3000;

console.log("this goes to the console window");
http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.write("<h2>hello world</h2>");
  res.write("success! This app is deployed online");
  res.end();
}).listen(port);


