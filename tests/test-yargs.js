
var yargs = require('yargs');
var argv = yargs.argv;

console.log(`process.argv: ${JSON.stringify(process.argv)}`);
console.log(`yargs.argv: ${JSON.stringify(argv)}`);