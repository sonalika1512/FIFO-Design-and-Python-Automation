
import os
import subprocess
from datetime import datetime

# Project directory
PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Log directory
LOG_DIR = os.path.join(PROJECT_DIR, "logs")
LOG_FILE = os.path.join(LOG_DIR, "simulation.log")

# Cadence simulator command
COMMAND = [
    "irun",
    "-access", "+rwc",
    "-top", "async_fifo_tb",
    "rtl/async_fifo.v",
    "tb/async_fifo_tb.v"
]


def run_simulation():

    print("=" * 50)
    print("ASYNC FIFO PYTHON AUTOMATION")
    print("=" * 50)

    print("Starting simulation...")

    start_time = datetime.now()

    try:
        result = subprocess.run(
            COMMAND,
            cwd=PROJECT_DIR,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True
        )

        output = result.stdout

        # Save simulator output
        with open(LOG_FILE, "w") as log:
            log.write("Simulation started: " + str(start_time) + "\n")
            log.write(output)

        # Check simulation result
        if (
            result.returncode == 0
            and "ALL FIFO TESTS PASSED" in output
            and "ERROR:" not in output
        ):
            print("\nSIMULATION STATUS: PASS")
            print("All FIFO tests completed successfully.")
        else:
            print("\nSIMULATION STATUS: FAIL")
            print("Check the simulation log for details.")

        print("\nLog saved at:")
        print(LOG_FILE)

    except OSError as error:
        print("ERROR: Could not execute irun.")
        print(str(error))


if __name__ == "__main__":
    run_simulation()

