
import os
import re
from datetime import datetime


PROJECT_DIR = os.path.dirname(
    os.path.dirname(os.path.abspath(__file__))
)

LOG_FILE = os.path.join(
    PROJECT_DIR, "logs", "simulation.log"
)

REPORT_DIR = os.path.join(
    PROJECT_DIR, "reports"
)

REPORT_FILE = os.path.join(
    REPORT_DIR, "fifo_simulation_report.txt"
)


def generate_report():

    if not os.path.exists(LOG_FILE):
        print("ERROR: Simulation log not found.")
        return

    with open(LOG_FILE, "r") as file:
        log_data = file.read()

    read_count = len(
        re.findall(r"PASS: Read index=", log_data)
    )

    full_count = log_data.count(
        "PASS: FIFO FULL detected"
    )

    empty_count = log_data.count(
        "PASS: FIFO EMPTY detected"
    )

    write_match = re.search(
        r"Total writes\s*=\s*(\d+)", log_data
    )

    read_match = re.search(
        r"Total reads\s*=\s*(\d+)", log_data
    )

    total_writes = int(write_match.group(1)) if write_match else 0
    total_reads = int(read_match.group(1)) if read_match else 0

    error_count = len(
        re.findall(r"ERROR:|\*F,", log_data)
    )

    warning_count = len(
        re.findall(r"\*W,", log_data)
    )

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

    os.makedirs(REPORT_DIR, exist_ok=True)

    report = """
========================================
       ASYNC FIFO SIMULATION REPORT
========================================

Generated On       : {timestamp}
Design             : 8x8 Asynchronous FIFO
Simulator          : Cadence Incisive 15.20

----------------------------------------
SIMULATION RESULTS
----------------------------------------

Overall Status     : {status}

Total Writes       : {writes}
Total Reads        : {reads}
Successful Reads   : {successful_reads}

FIFO Full Checks   : {full}
FIFO Empty Checks  : {empty}

Errors             : {errors}
Warnings           : {warnings}

========================================
""".format(
        timestamp=datetime.now(),
        status=status,
        writes=total_writes,
        reads=total_reads,
        successful_reads=read_count,
        full=full_count,
        empty=empty_count,
        errors=error_count,
        warnings=warning_count
    )

    with open(REPORT_FILE, "w") as file:
        file.write(report)

    print("Report generated successfully!")
    print("Report location:")
    print(REPORT_FILE)


if __name__ == "__main__":
    generate_report()

