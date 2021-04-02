const _ = require("lodash");

module.exports.echo = (message) => message;

module.exports.hello = (name) => `hello ${name}`;

module.exports.eq = (name1, name2) => _.eq(name1, name2);

module.exports.huge = () => "x".repeat(100000);
