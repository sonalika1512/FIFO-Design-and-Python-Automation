
import os
import re


# Find project directory
PROJECT_DIR = os.path.dirname(
    os.path.dirname(os.path.abspath(__file__))
)

# Simulation log path
LOG_FILE = os.path.join(
    PROJECT_DIR, "logs", "simulation.log"
)


def analyze_log():

    print("=" * 50)
    print("ASYNC FIFO LOG ANALYSIS")
    print("=" * 50)

    if not os.path.exists(LOG_FILE):
        print("ERROR: Simulation log not found.")
        return

    with open(LOG_FILE, "r") as file:
        log_data = file.read()

    # Count successful operations
    read_count = len(
        re.findall(r"PASS: Read index=", log_data)
    )

    full_count = log_data.count(
        "PASS: FIFO FULL detected"
    )

    empty_count = log_data.count(
        "PASS: FIFO EMPTY detected"
    )

    # Extract total writes and reads
    write_match = re.search(
        r"Total writes\s*=\s*(\d+)", log_data
    )

    total_read_match = re.search(
        r"Total reads\s*=\s*(\d+)", log_data
    )

    total_writes = (
        int(write_match.group(1)) if write_match else 0
    )

    total_reads = (
        int(total_read_match.group(1))
        if total_read_match else 0
    )

    # Count errors and warnings
    error_count = len(
        re.findall(r"ERROR:|\\*F,", log_data)
    )

    warning_count = len(
        re.findall(r"\\*W,", log_data)
    )

    # Overall status
    if (
        "ALL FIFO TESTS PASSED" in log_data
        and read_count == 24
        and total_writes == 24
        and total_reads == 24
        and full_count == 3
        and empty_count == 3
        and error_count == 0
    ):
        status = "PASS"
    else:
        status = "FAIL"

    print("\nSIMULATION ANALYSIS")
    print("-" * 50)

    print("Overall Status       :", status)
    print("Successful Reads     :", read_count)
    print("Total Writes         :", total_writes)
    print("Total Reads          :", total_reads)
    print("FIFO Full Detections :", full_count)
    print("FIFO Empty Detections:", empty_count)
    print("Errors               :", error_count)
    print("Warnings             :", warning_count)

    print("-" * 50)


if __name__ == "__main__":
    analyze_log()

