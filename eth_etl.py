import subprocess as sp
import helper as h
from etl_postgres import connect_to_db


# Get information from user about DB
def get_user_input():
    return h.get_info(1)


# Start Ethereum ETL with the correct command for the DB
def start_ethetl(command):
    # Pipe output from Ethereum ETL to file
    # with open("ethereum_etl_log.txt", "w") as f:
    sp.run(
        [command],
        shell=True  # ,
        # stdout=f,
        # stderr=f
    )


# TODO: take entities from user
# Generate the command used for the ethereum etl stream
def generate_command(input):
    return (
            "ethereumetl stream "
            "-e transaction,block "
            + input
    )


# Ask the user if he wants to create the tables needed
def setup_extraction_tables():
    choice = input(
        "Do you wish to automatically setup the transactions and blocks table? "
        "These tables are required by Ethereum ETL.\n"
        "Answer (y)es or (n)o: "
    )
    if choice == "y":
        connect_to_db()


def main():
    input = get_user_input()
    command = generate_command(input)
    setup_extraction_tables()
    print("Starting Ethereum ETL with the following command: ", command)
    print("Output from ETL piped to ethereum_etl_log.txt")
    start_ethetl(command)


if __name__ == "__main__":
    main()
