fs = require 'fs'
assert = require 'assert'
WordCount = require '../lib'


helper = (input, expected, done) ->
  pass = false
  counter = new WordCount()

  counter.on 'readable', ->
    return unless result = this.read()
    assert.deepEqual result, expected
    assert !pass, 'Are you sure everything works as expected?'
    pass = true

  counter.on 'end', ->
    if pass then return done()
    done new Error 'Looks like transform fn does not work'

  counter.write input
  counter.end()


describe '10-word-count', ->

  it 'should count a single word', (done) ->
    input = 'test'
    expected =  lines: 1, words: 1, chars: 5
    helper input, expected, done

  it 'should count words in a phrase', (done) ->
    input = 'this is a basic test'
    expected =   lines: 1, words: 5, chars: 21
    helper input, expected, done

  it 'should count quoted characters as a single word', (done) ->
    input = '"this is one word!"'
    expected =  lines: 1, words: 1, chars: 20
    helper input, expected, done

  # !!!!!
  # Make the above tests pass and add more tests!
  # !!!!!

  it 'should count quoted strings as single words', (done) ->
    input = fs.readFile "#{__dirname}/fixtures/3,7,46.txt", 'utf8', (err, data) ->
      expected = lines: 3, words: 7, chars: 46
      helper data, expected, done

  it 'should count camel cased words as multiple words', (done) ->
    input = fs.readFile "#{__dirname}/fixtures/5,9,40.txt", 'utf8', (err, data) ->
      expected = lines: 5, words: 9, chars: 40 
      helper data, expected, done
  it 'should count empty lines as 1 line 0 words', (done) ->
    input = fs.readFile "#{__dirname}/fixtures/3,3,20.txt", 'utf8', (err, data) ->
      expected = lines: 3, words: 3, chars: 20 
      helper data, expected, done



fixtures = fs.readdirSync "#{__dirname}/fixtures/"
# format: LINES,WORDS,CHARACTERS.txt
textFileInputs = fixtures.flatMap((f) -> 
  data = f.split('.')[0]
  if data and data.length
    inputs = data.split(',')
    if inputs and inputs.length == 3
      return {
        lines: inputs[0],
        words: inputs[1],
        chars: inputs[2]
      }
)

describe '10-word-count -- test all fixtures', ->

  # loops through the fixtures and tests the inputs as defined in the filename
  fixtures.map((fileName, index) ->
    it "should correctly count lines/words/chars in #{fileName}", (done) ->
      input = fs.readFile "#{__dirname}/fixtures/#{fileName}", 'utf8', (err, data) ->
        expected = textFileInputs[index]
        helper data, expected, done
  )