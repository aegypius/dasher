var DasherButton = require('./lib/dasher')
var config = require('./config/config.json')

var buttons = []

console.dir(config, { depth:null, colors: true});

for (var i = 0; i < config.buttons.length; i++) {
  button = config.buttons[i]
  buttons.push(new DasherButton(button))
}
