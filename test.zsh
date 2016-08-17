#!/bin/zsh

coffee tempora.coffee -- replace > fragment.re.js
diff <(node fragment.js) <(node fragment.re.js) && echo "Output is identical -- test passed."
