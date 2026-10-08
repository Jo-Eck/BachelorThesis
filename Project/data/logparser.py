import re
import sys

# Regular expression to capture relevant log information
log_pattern = re.compile(
    r"(\d{4}-\d{2}-\d{2}:\d{2}:\d{2}:\d{2}) "  # Timestamp
    r"\[ServerDaemon\] run Line \d+ INFO \[Chapel\] "  # Log preamble
    r">>> (?P<operation>.+?) \[",  # Operation
    re.MULTILINE  # Enable multiline mode
)

# Regular expression to capture operation completion and duration
completion_pattern = re.compile(
    r"\[ServerDaemon\] run Line \d+ INFO \[Chapel\] <<< (?P<operation>.+?) took (?P<duration>.+?) sec",
    re.MULTILINE  # Enable multiline mode
)

# Regular expression to capture message information
message_pattern = re.compile(
    r"\[ServerDaemon\] sendRepMsg Line \d+ INFO \[Chapel\] repMsg: {\"msg\":\"(?P<message>.+?)\"",
    re.MULTILINE  # Enable multiline mode
)

# Iterate over each line from stdin (from the logs)
for line in sys.stdin:
    # Check for operation start
    match_op = log_pattern.search(line)
    if match_op:
        timestamp = match_op.group(1)
        operation = match_op.group("operation")
        print(f"{timestamp} | Operation started: {operation}")

    # Check for operation completion
    match_comp = completion_pattern.search(line)
    if match_comp:
        operation = match_comp.group("operation")
        duration = match_comp.group("duration")
        print(f"Operation completed: {operation} | Duration: {duration} sec")

    # Check for messages
    match_msg = message_pattern.search(line)
    if match_msg:
        message = match_msg.group("message").replace("\\\"", "\"")  # Unescape quotes
        print(f"Message: {message}")

# End of the script
    