import subprocess
from dotenv import load_dotenv

if os.path.exists(os.path.expanduser("~/.wskprops")):
    # load secrets
    command = ["ops", "-config", "-dump"]
    result = subprocess.run(command, capture_output=True, text=True)
    output = result.stdout

    # Parse the output and set environment variables
    for line in output.splitlines():
        try:
            key, value = line.split('=', 1)
            os.environ[key] = value
            print("OK:", key)
        except:
            print("ERR:", line)

# override with testenv
load_dotenv(".env")
load_dotenv("tests/.env", override=True)

class Empty: pass
self = Empty()
args = {}