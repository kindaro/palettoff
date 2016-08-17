fs      = require 'fs'
y       = require 'escodegen'
z       = require 'estraverse'
escope  = require 'escope'
cj      = require 'circular-json'
esprima = require 'esprima'

require './lib'


syntax  = esprima.parse fs.readFileSync 'fragment.js'
scopes = escope.analyze syntax

target = "~scopes~0~through~0~from~variables~3"
refs = []
refs.push Object.deepExtract x, Object.parseRef '~identifier' for x in Object.deepExtract scopes
            , Object.parseRef target + '~references'
refs.push x for x in Object.deepExtract scopes
            , Object.parseRef target + '~identifiers'

ref["name"] = 'replaced' for ref in refs

switch process.argv[2]
    when "scopes"  then console.log cj.stringify (escope.analyze syntax), null, 2
    when "show"    then console.log cj.stringify (refs), null, 2
    when "replace" then console.log y.generate syntax
    else console.log process.argv[2]
