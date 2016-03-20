
Object.deep_extract =
    (obj, props) ->
        if props.length == 0
            obj
        else
            prop = props[0]
            if obj[prop]? then Object.deep_extract obj[prop], props[1..] else undefined

