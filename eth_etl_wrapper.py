import subprocess as sp
import sys

import utils.helper as h
from etl_postgres import choose

# Author: Giorgio Camozzi
# This script is a wrapper around Ethereum ETL. It requests
# some user input before calling Ethereum ETL with that input.
# Ethereum ETL was NOT created by me. You find more
# information about Ethereum ETL here:
# https://github.com/blockchain-etl/ethereum-etl


# Start Ethereum ETL with the correct command for the DB
def start_ethetl(command):
    # Write Command to file for later use
    f = open("ethereum_etl_command.txt", "w")
    f.write(command)
    f.close()

    sp.run(
        [command],
        shell=True
    )


# Set up tables if they dont exist yet and truncate them if they do exist
def set_up_tables():
    choose()


# Just a little step more to print correct instructions for this script
def setup_extraction_tables():
    print("Please choose option 1.\n")
    set_up_tables()


# Generate the command used for the ethereum etl stream
def generate_command(user_input):
    return (
            "ethereumetl stream "
            + user_input
    )


# Get information from user about DB
def get_user_input():
    return h.get_info(1)


def main():
    # If no arguments are provided to command, ask user for input
    if len(sys.argv) == 1:
        h.clear()
        print(
            "Note that this tool will write your database password into a local"
            "file called database.ini. This file is later used in the etl python script"
            "to create some tables. It NEVER leaves your PC, but you might want to opt"
            "out if you don't need it or already have one."
        )
        user_input = get_user_input()
        command = generate_command(user_input)
        setup_extraction_tables()
    else:  # The user can also run the script directly providing the command for ethereum etl
        h.clear()
        command = sys.argv[1]
    try:
        print("Starting Ethereum ETL with the following command: ", command)
        start_ethetl(command)
    except KeyboardInterrupt:
        t = open("last_synced_block.txt", "r")
        print("Last synced block: ", t.read())
        t.close()
        print("Terminating...")
        print("done")
        sys.exit()


if __name__ == "__main__":
    main()
