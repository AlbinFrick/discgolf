const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.updateUserCount = functions.auth.user().onCreate(user => {
	var db = admin.firestore();
	var collection = db.collection('users');
	console.log('Adding new user ' + user.email + '...');

	collection
		.doc(user.uid)
		.set({
			email: user.email
		})
		.then(() => {
			console.log('Added new user');
			return;
		})
		.catch(e => {
			console.log('Error:');
			console.log(e);
			return;
		});
});
//Do what you need to do
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
