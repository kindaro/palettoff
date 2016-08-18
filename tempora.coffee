fs      = require 'fs'
y       = require 'escodegen'
escope  = require 'escope'
cj      = require 'circular-json'
esprima = require 'esprima'

require './lib'


syntax  = esprima.parse fs.readFileSync 'fragment.js'
scopes = escope.analyze syntax

rename = (scopes, target, name) ->
    refs = []
    refs.push Object.deepExtract x, Object.parseRef '~identifier' for x in Object.deepExtract scopes
                , target . concat 'references'
    refs.push x for x in Object.deepExtract scopes
                , target . concat 'identifiers'

    ref["name"] = name for ref in refs

    return refs

target = Object.parseRef "~scopes~0~through~0~from~variables~3"
refs = rename scopes, target, "x"

switch process.argv[2]
    when "scopes"  then console.log cj.stringify (escope.analyze syntax), null, 2
    when "show"    then console.log cj.stringify (refs), null, 2
    when "replace" then console.log y.generate syntax

exports.rename = rename
