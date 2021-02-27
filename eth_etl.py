import subprocess as sp
import os
import sys
from getpass import getpass


def get_user_input():
    clear()
    print(
        "Please note that this tool will write your database password into a local"\
        "file called database.ini. This file is later used for to create some tables."\
        "It NEVER leaves your PC, but you might want to opt out if you don't need it"\
        "or already have one."
    )
    choice = input(
        "\nDo you want to automatically create a database.ini file(y) or not(n)? (DEFAULT: y)\n"
        or "y"
    )
    clear()
    print("Please type in the information requested about your database and hit ENTER")
    usn = input("User: ")
    pswd = getpass()
    ip_addr = input("IP Address(DEFAULT: localhost): ")
    if ip_addr == "":
        ip_addr = "localhost"
    port = input("Port(DEFAULT: 5432): " or "5432")
    if port == "":
        port = "5432"
    db_name = input("Database name: ")
    s = input(
        "Start extracting from specific block number (1) or from last synced block (2)? \n"
    )
    if s == "1":
        start = "--start-block " + input("Start block number: ") + " "
    else:
        start = ""

    # If user chooses to opt in
    # write database.ini file for later use while we are at it
    if choice == "y":
        print("Writing database.ini")
        f = open("database.ini", "w")
        f.write("[database_connection_details]")
        f.write("\nhost=" + ip_addr)
        f.write("\ndatabase=" + db_name)
        f.write("\nuser=" + usn)
        f.write("\npassword=" + pswd)
        f.write("\nport=5432")  # add standard postgres port
        f.close()
        print("done")

    # return part of the command with start block and database information
    return (
        start
        + "--output postgresql+pg8000://"
        + usn
        + ":"
        + pswd
        + "@"
        + ip_addr
        + ":"
        + port
        + "/"
        + db_name
    )


def start_ethetl(command):
    # Pipe output from Ethereum ETL to file
    with open("ethereum_etl_log.txt", "w") as f:
        sp.run(
            [command],
            shell=True,
            stdout=f,
            stderr=f
        )


# in windows use cls to clear, all others use clear
# from stackoverflow answer https://stackoverflow.com/a/2084628 (accessed 27.02.2020)
def clear():
    os.system("cls" if os.name == "nt" else "clear")


def main():
    output = get_user_input()
    command = (
        "ethereumetl stream \
                --provider-uri FILE://$HOME/.local/share/openethereum/jsonrpc.ipc \
                -e transaction,block "
        + output
    )
    print("Starting Ethereum ETL with the following command: {c}", command)
    print("Output from ETL piped to ethereum_etl_log.txt")
    start_ethetl(command)


if __name__ == "__main__":
    main()
