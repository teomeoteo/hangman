#!/bin/bash

if [ ! -f "sketch.rb" ]; then
    echo "Error: sketch.rb does not exist!"
    exit 1
fi

awk '
# 1. Handle Requires (with or without comments)
/^[[:space:]]*require[[:space:]]+/ {
    if (match($0, /#[[:space:]]*/)) {
        req_line = substr($0, 1, RSTART - 1)
        comment_part = substr($0, RSTART + RLENGTH)
        
        n = split(comment_part, classes, ",")
        for (i = 1; i <= n; i++) {
            c = classes[i]
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", c)
            
            # Use assignment (=) instead of concatenation (requires[c] = requires[c] ...)
            # to prevent piling up newlines.
            requires[c] = req_line
        }
    } else {
        general_requires = general_requires $0 "\n"
    }
    next
}

/^[[:space:]]*require[[:space:]]+/ { next }

# 2. Detection of the start of a new class
/^[[:space:]]*class[[:space:]]+/ {
    if (in_main) { close("main.rb"); in_main = 0 }

    class_name = $2
    sub(/<.*/, "", class_name)
    gsub(/[[:space:]\r\n]/, "", class_name)

    filename = class_name
    while (match(filename, /[a-z0-9][A-Z]/)) {
        filename = substr(filename, 1, RSTART) "_" substr(filename, RSTART + 1)
    }
    filename = tolower(filename)
    created_files[filename] = 1 
    
    filename = filename ".rb"
    in_class = 1
    
    if (class_name in requires) {
        print requires[class_name] > filename
        print "" > filename
    }
    
    print $0 > filename
    next
}

# 3. Catch the end of the class
in_class && /^[[:space:]]*end[[:space:]]*$/ {
    if ($0 ~ /^end[[:space:]]*$/) {
        print $0 > filename
        close(filename)
        in_class = 0
        print "Created file for class: " filename
        next
    }
}

# 4. Copy the regular class body
in_class {
    print $0 > filename
    next
}

# 5. Anything else goes to main.rb
!in_class && /[^[:space:]]/ {
    if (!in_main) {
        print "# Automatically generated runner file\n" > "main.rb"
        for (f in created_files) {
            print "require_relative \047" f "\047" > "main.rb"
        }
        print "" > "main.rb"
        in_main = 1
    }
    print $0 > "main.rb"
}

END {
    if (in_main) {
        close("main.rb")
        print "Created runner file: main.rb"
    }
}
' sketch.rb

echo "🎉 Extraction complete! All components are in their respective files."