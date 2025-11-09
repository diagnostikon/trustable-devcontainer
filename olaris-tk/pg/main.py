import sys
from pathlib import Path

def slurp_statement(file):
    """
    Read from the file until you find a line ending with ';' 
    Concatenate the lines removing the newline
    """
    lines = []
    while True:
        line = file.readline()
        if not line:
            return None
        line = line.rstrip('\n')
        if line.startswith("--") or line == "":
            continue
        if line.startswith("SET"):
            continue
        if line.startswith("CREATE TABLE"):
            line = line.replace("public.", "")
        lines.append(line.strip())
        if line.endswith(';'):
            break
    return ' '.join(lines)


def process(filename, action, max, exec):
    """
    Open a file and use slurp_statement to read a statement
    when you reach a max number of statements invoke exec passing an array of statements
    """
    with open(filename, 'r') as file:
        statements = []
        count = 0
        while True:
            count += 1
            statement = slurp_statement(file)
            #print(statement)
            if statement is None:
                if statements:
                    exec(action, statements)
                break
            statements.append(statement)
            if len(statements) >= max:
                print(f"{count}:", end="")
                exec(action, statements)
                statements = []
    
def invoke_exec(action, statements):
    """
    create a temporary json file with a key "input" and a value that is the concatenation of all the stemements separated by newlines
    then evecute "ops action invoke  <action> -P <the file>
    """
    import json
    import tempfile
    import subprocess
    
    #print("-- invoke --\n", "\n".join(statements))

    # Create temporary file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=True) as tmp:
        # Write statements to JSON file
        Path(tmp.name).write_text(json.dumps({"input": "\n".join(statements)}, indent=2))
        
        cmd = ["ops", "action", "invoke", action, "-P", tmp.name, "-r"]
        #cmd = ["cat",  tmp.name]
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        print(result.stdout)

    # Execute ops action command

def main(argv):
    print(argv)
    filename = argv[0]
    
    action = "mastrogpt/sql"
    if argv[1] != "":
        action = argv[1]

    max = 100
    try: max = int(argv[2])
    except: pass

    print(f"action: {action} file: {filename} max: {max}")
    process(filename, action, max, invoke_exec)


if __name__ == "__main__":
    main(sys.argv[1:])

