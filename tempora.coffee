fs      = require 'fs'
y       = require 'escodegen'
z       = require 'estraverse'
escope  = require 'escope'
cj      = require 'circular-json'
esprima = require 'esprima'


syntax  = esprima.parse fs.readFileSync 'fragment.js'

# z.replace syntax
#     ,
#         leave:
#             (n, p) -> if n.type == 'Identifier' and n.name == 'e' then return {
#                 type: 'Identifier'
#                 name: 'I_Really_Love_You'
#             }

scopes = escope.analyze syntax

console.log cj.stringify (escope.analyze syntax), null, 2
