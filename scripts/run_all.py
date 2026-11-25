
import os
import subprocess
import sys


SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))


def execute_script(script_name):

    script_path = os.path.join(
        SCRIPT_DIR, script_name
    )

    print("\n" + "=" * 50)
    print("EXECUTING:", script_name)
    print("=" * 50)

    result = subprocess.call(
        [sys.executable, script_path],
        cwd=SCRIPT_DIR
    )

    if result != 0:
        print("\nERROR:", script_name, "failed.")
        return False

    return True


def main():

    print("=" * 50)
    print("ASYNC FIFO COMPLETE AUTOMATION FLOW")
    print("=" * 50)

    scripts = [
        "run_simulation.py",
        "analyze_log.py",
        "generate_report.py"
    ]

    for script in scripts:

        success = execute_script(script)

        if not success:
            print("\nAUTOMATION FLOW FAILED")
            return

    print("\n" + "=" * 50)
    print("COMPLETE AUTOMATION FLOW FINISHED")
    print("Check reports/fifo_simulation_report.txt")
    print("=" * 50)


if __name__ == "__main__":
    main()

