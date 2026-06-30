#!/bin/bash

if [ ! -f "sketch.rb" ]; then
    echo "Error: sketch.rb does not exist!"
    exit 1
fi

awk '
# 1. Read and map require lines
/^[[:space:]]*require[[:space:]]+/ && /#[[:space:]]*/ {
    req_part = $0
    sub(/[[:space:]]*#.*/, "", req_part)
    
    # Compatibility fix: manually match and extract
    if (match($0, /#[[:space:]]*[A-Za-z0-9_]+/)) {
        class_str = substr($0, RSTART, RLENGTH)
        sub(/#[[:space:]]*/, "", class_str)
        requires[class_str] = req_part
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