
Object.deepExtract =
    (obj, props) ->
        if props.length == 0
            obj
        else
            prop = props[0]
            if obj[prop]? then Object.deepExtract obj[prop], props[1..] else undefined

Object.parseRef =
    (ref) ->
        (ref.split '~')[1..]

