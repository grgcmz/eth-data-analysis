import subprocess as sp
import sys

import utils.helper as h
from etl_postgres import choose


# Get information from user about DB
def get_user_input():
    return h.get_info(1)


# Start Ethereum ETL with the correct command for the DB
def start_ethetl(command):
    # Write Command to file for later use
    f = open("ethereum_etl_command.txt","w")
    f.write(command)
    f.close()

    sp.run(
        [command],
        shell=True
    )

# Generate the command used for the ethereum etl stream
def generate_command(user_input):
    return (
            "ethereumetl stream "
            + user_input
    )


# Ask the user if he wants to create the tables needed
def setup_extraction_tables():
    choice = input(
        "Do you wish to automatically setup the transactions and blocks table? "
        "These tables are required by Ethereum ETL.\n"
        "Answer (y)es or (n)o: "
    )
    if choice == "y":
        choose()


def main():
    if len(sys.argv) == 1:
        h.clear()
        print(
            " note that this tool will write your database password into a local"
            "file called database.ini. This file is later used in the etl python script"
            "to create some tables. It NEVER leaves your PC, but you might want to opt"
            "out if you don't need it or already have one."
        )
        user_input = get_user_input()
        command = generate_command(user_input)
        setup_extraction_tables()
    else:
        h.clear()
        command = sys.argv[1]
    print("Starting Ethereum ETL with the following command: ", command)
    start_ethetl(command)


if __name__ == "__main__":
    main()
