import csv
import os
import argparse
from pathlib import Path

parser = argparse.ArgumentParser(description='Test bench output checker')
parser.add_argument('-i', dest='inFile', type=str, help='Path to source .csv')

def check_tb_output(inFile):
    with open(inFile, 'r') as file:
        csvreader = csv.reader(file)
        tb_name = Path(inFile).stem

        for row in csvreader:
            if (len(row) == 0):
                continue

            test_name = row[0].strip()
        
            for i in range(1, len(row), 3):
                signal_name, actual_val, expected_val = row[i].strip(), int(row[i + 1].strip()), int(row[i + 2].strip())

                if (actual_val != expected_val):
                    raise Exception(f'Testbench "{tb_name}" fails at test case "{test_name}", signal "{signal_name}" is {actual_val}, but should be {expected_val}')

        print("PASSED")


if __name__ == "__main__":
  args = parser.parse_args()

  if not os.path.exists(args.inFile):
    print(f"File does not exist at path {args.inFile}")
  else:
    check_tb_output(args.inFile)
