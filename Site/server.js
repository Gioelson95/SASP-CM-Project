const express = require("express");
const app = express();

app.use(express.static(__dirname));

let serverPort = process.env.PORT || 5000;

// start server
app.listen(serverPort, function () {
	console.log("Your app is ready at port " + serverPort);
});
