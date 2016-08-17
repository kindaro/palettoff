function tempora (e) {
    var ordinary, overridden;

    overridden = "not yet overridden"

    console.log (overridden)

    function inner () {
        var overridden;

        overridden = "overridden already"
        return (overridden)
    }

    console.log (inner())

    console.log (overridden)
}
tempora (null)
