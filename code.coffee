require './lib'
fs = require 'fs'
escodegen = require 'escodegen'

syntax = (require 'esprima').parse fs.readFileSync 'app.js'


# console.log ((Object.deep_extract e, ['callee', 'object', 'body', 'body', '0', 'expression', 'arguments', '0']) for e in (syntax.body[0].expression.expressions)) .filter (x) -> x?

path_to_base = 'callee.object.body.body.0.expression.callee.name' .split '.'
path_to_module = 'callee.object.body.body.0' .split '.'
path_to_name = Array.prototype.concat path_to_module, 'expression.arguments.0.value' .split '.'
path_to_body = Array.prototype.concat path_to_module, 'expression.arguments.2' .split '.'
path_to_libs = Array.prototype.concat path_to_module, 'expression.arguments.1' .split '.'

data = (syntax.body[0]
    .expression.expressions .filter (x) ->
        (Object.deep_extract x, path_to_base) == 'define') .
            map (x) ->
                name: Object.deep_extract x, path_to_name
                body: Object.deep_extract x, path_to_body
                libs: Object.deep_extract x, path_to_libs


if not fs.existsSync 'modules'
    fs.mkdirSync 'modules'

body_transform = (x) ->
    console.log x.libs
    try
        escodegen.generate x.body
    catch e
        console.log 'can\'t convert ' + x.name + e
        JSON.stringify x.body, null, 2

fs.writeFileSync ('modules/' + x.name + '.js')
        , body_transform x for x in data
