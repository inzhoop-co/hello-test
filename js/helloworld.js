/*
 * Hello Hugo!
 *
 * This is the javascript for a hello world dapp that runs in Eris' DeCerver modified.
 * It lets you run a typical Ethereum-style 'namereg' contract. You will register
 * your public address as a , but storing large files using IPFS 
 * (Interplanetary Filesystem) instead of a string.
 *																				  
 * Licence: https://github.com/inzhoop-co/hello-test/blob/master/LICENSE.txt             
 *																				  
 */


var baseUrl = "/apis/hellohugo"

// The placeholder HTTP api is used to send http messages to the decerver.
var HttpAPI = function(){

	this.send = function(method, url, body) {
		var xmlHttp = new XMLHttpRequest();
		xmlHttp.open(method, url, false);
		if(typeof(body) === "undefined"){
			body = null;
		}
		xmlHttp.send(body);
		return xmlHttp.responseText;
	}

	this.sendAsync = function(method, url, body, callbackFn) {
		var xmlHttp = new XMLHttpRequest();
		xmlHttp.onreadystatechange = function(){
			if (xmlHttp.readyState === 4){
				callbackFn(xmlHttp);
			}
		};
		xmlHttp.open(method, url, true);
		if(typeof(body) === "undefined"){
			body = null;
		}
		xmlHttp.send(body);
		return;
	}
}

//***************************************************************************

var	sender = new HttpAPI();

function getFile(){
	var fName = document.getElementById('filenameGet').value;
	sender.sendAsync("GET", baseUrl + "/files/" + fName, null, function(re) {
		if (re.status === 200) {
			console.log(re);
			var body = re.response;
			body = JSON.parse(body);
	        document.getElementById('output').value = decodeURI(body.data);
	    } else {
			document.getElementById('output').value = "File not found";
		}
	});
};

function addFile(){
	var key = document.getElementById('passkey').value;
	var fName = document.getElementById('filenameAdd').value;
	var body = document.getElementById('input').value;
	
	if(key === ""){
		window.alert('You must provide a passkey!');	
		return;
	}

	if(body === "" || fName === ""){
		window.alert("You must provide a file name and some data.");
		return;
	}

	var jsonObj = { name : fName , data : encodeURI(body) , passkey : key };
	console.log(jsonObj);

	sender.sendAsync("POST", baseUrl + "/files", JSON.stringify(jsonObj), function(request) {
		if (request.status === 200) {
	        window.alert("File sent! You can now get it by its name.");
		} else {
			window.alert("Failed to add file:\n" + request.responseText);
		}
	});

};

