fs        = require 'fs'
escodegen = require 'escodegen'
escope    = require 'escope'

require './lib'

syntax = (require 'esprima').parse fs.readFileSync 'app.js'


# console.log ((Object.deep_extract e, ['callee', 'object', 'body', 'body', '0', 'expression', 'arguments', '0']) for e in (syntax.body[0].expression.expressions)) .filter (x) -> x?

path_to_base = Object.parseRef '~callee~object~body~body~0~expression~callee~name'
path_to_module = Object.parseRef '~callee~object~body~body~0'
path_to_name = Array.prototype.concat path_to_module, Object.parseRef '~expression~arguments~0~value'
path_to_body = Array.prototype.concat path_to_module, Object.parseRef '~expression~arguments~2'
path_to_libs = Array.prototype.concat path_to_module, Object.parseRef '~expression~arguments~1'

data = (syntax.body[0]
    .expression.expressions .filter (x) ->
        (Object.deepExtract x, path_to_base) == 'define') .
            map (x) ->
                name: Object.deepExtract x, path_to_name
                body: Object.deepExtract x, path_to_body
                libs: Object.deepExtract x, path_to_libs


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
