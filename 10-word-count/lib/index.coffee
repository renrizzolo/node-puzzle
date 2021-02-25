through2 = require 'through2'


module.exports = ->
  words = 0
  lines = 1
  chars = 0
  transform = (chunk, encoding, cb) ->
    # trim so as to not include empty 
    # new line as extra line/word
    lines = chunk.trim().split(/\r\n/)
    # regex for quoted strings
    rx = new RegExp('"[^"]*"');
    capsRx = new RegExp('([A-Z]+[a-z0-9]+){2,}')
 
    # loop through lines, flatmap to flatten 
    # the returned split() array
    tokens = lines.flatMap((line) -> 
      # count the characts in this line and
      # add it to chars
      # if line.length == 0 then return
      chars += line.length + 1
      # separate camel case words (actually PascalCase)

      # line = line.replace(/(^[A-Z][a-z]*)([A-Z][a-z]*)/g, '$1 $2')

      # return the whole line if quoted
      if rx.test(line)
        return line
      # return caps-split camel case tokens
      if capsRx.test(line)
        return line.split(/(?=[A-Z])/)
      else 
      # return space-split tokens
        return line.split ' '
    )
    # filter out empty lines from being counted as words
    .filter((token) -> 
      if token.length != 0 then return token
    )
    # console.log(lines, tokens)
    # results
    lines = lines.length
    words = tokens.length
    return cb()

  flush = (cb) ->
    this.push {words, lines, chars}
    this.push null
    return cb()

  return through2.obj transform, flush
