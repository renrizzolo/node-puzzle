fs = require 'fs'
readline = require 'readline'


exports.countryIpCounter = (countryCode, cb) ->
  return cb() unless countryCode

  readStream = fs.createReadStream "#{__dirname}/../data/geo.txt"
  lines = readline.createInterface readStream
  counter = 0

  lines.on 'line', (l) ->
    line = l.split '\t'
    if line[3] == countryCode then counter += +line[1] - +line[0]

  readStream.on 'end', () -> cb null, counter