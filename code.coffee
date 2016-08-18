fs        = require 'fs'
escodegen = require 'escodegen'
escope    = require 'escope'
tempora   = require './tempora'
cj        = require 'circular-json'
js2coffee = require 'js2coffee'

require './lib'

syntax = (require 'esprima').parse fs.readFileSync 'app.js'


refExpressions = Object.parseRef '~body~0~expression~expressions'
refModule = Object.parseRef '~callee~object~body~body~0'
refBase = Array::concat refModule
    , Object.parseRef '~expression~callee~name'
refName = Array::concat refModule
    , Object.parseRef '~expression~arguments~0~value'
refLibs = Array::concat refModule
    , Object.parseRef '~expression~arguments~1'
refSyntax = Array::concat refModule
    , Object.parseRef '~expression~arguments~2'
refLib_names = Array::concat refSyntax
    , Object.parseRef '~params'
refVariables = Object.parseRef '~scopes~0~variables'

data = ( (Object.deepExtract syntax, refExpressions) .
            filter (x) ->
                (Object.deepExtract x, refBase) == 'define') .
                    map (x) ->
                        name      : Object.deepExtract x, refName
                        syntax    : Object.deepExtract x, refSyntax
                        libs      : Object.deepExtract x, refLibs
                        lib_names : Object.deepExtract x, refLib_names

transform = (x) ->
        x.scopes = escope.analyze x.syntax
        console.log 'With ' + x.name + ' :: Variables: ' + x.libs.elements.length

        if x.libs.elements.length > 1
            console.log (v.value for v in x.libs.elements)
            for v, i in x.libs.elements[1..]
                try
                    tempora.rename x.scopes, (Array::concat refVariables, (i + 1)), v.value.replace /\./g, '_'
                catch e
                    console.log "can't convert " + x.name + ' :: ' + v.value + ' :: ' + e
        x.newSyntax =
              "type": "Program"
              "body": [
                       "type": "ExpressionStatement"
                       "expression":
                            "type": "AssignmentExpression"
                            "operator": "="
                            "left":
                                "type": "Identifier"
                                "name": "root"
                            "right": x.syntax
                    ]

        x.syntax = x.newSyntax

        x.js = escodegen.generate x.syntax

        try
            x.coffee = (js2coffee.build x.js).code
        catch e
            console.log e.message
            x.coffee = null
	

        x

if not fs.existsSync 'modules'
    fs.mkdirSync 'modules'

for x in data
    console.log 'Processing ' + x.name
    y = transform x
    w = (data, name, extension) -> fs.writeFileSync ('modules/' + name + '.' + extension), data if data
    s = (o) -> cj.stringify o, null, 2
    w y.js, y.name, 'js'
    w y.coffee, y.name, 'coffee'
    w (s y.scopes), y.name, 'scopes'
    w (s y.syntax), y.name, 'syntax'
    w (s y.libs), y.name, 'libs'
