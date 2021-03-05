import os
from getpass import getpass


# in windows use cls to clear, all others use clear
# from stackoverflow answer https://stackoverflow.com/a/2084628 (accessed 27.02.2020)
def clear():
    os.system("cls" if os.name == "nt" else "clear")


# Get info about database and/or etl 
# etl = 1
# only db = 2
def get_info(topic):
    if topic == 1:
        return etl_info()
    else:
        return db_info()


def write_db_file(usn, psd, ip_addr, port, db_name):
    print("Writing database.ini")
    f = open("database.ini", "w")
    f.write("[database_connection_details]")
    f.write("\nhost=" + ip_addr)
    f.write("\ndatabase=" + db_name)
    f.write("\nuser=" + usn)
    f.write("\npassword=" + psd)
    f.write("\nport=" + port)  # add standard postgres port
    f.close()
    print("done")


# Get DB information and information needed for Ethereum ETL
def etl_info():
    choice = input(
        "\nDo you want to automatically create a database.ini file(y) or not(n)? (DEFAULT: y)\n")
    if choice == "":
        choice = "y"
    clear()
    print("Please type in the requested information about your database and hit ENTER")
    usn = input("User: ").replace(" ", "")
    psd = getpass()
    ip_addr = input("IP Address(DEFAULT: localhost): ").replace(" ", "")
    if ip_addr == "":
        ip_addr = "localhost"
    port = input("Port(DEFAULT: 5432): ").replace(" ", "")
    if port == "":
        port = "5432"
    db_name = input("Database name: ").replace(" ", "")
    provider_uri = input("provider_uri (DEFAULT: /$HOME/.local/share/openethereum/jsonrpc.ipc):\n").replace(" ", "")
    if provider_uri == "":
        provider_uri = "/$HOME/.local/share/openethereum/jsonrpc.ipc"
    s = input(
        "Start extracting from specific block number (1) or from last synced block (2)? \n"
    )
    if s == "1":
        start = "--start-block " + input("Start block number: ").replace(" ", "")
    else:
        start = ""
    entities = input("What entities do you want to extract(comma separated)?\nDEFAULT: transaction, block\nAll: "
                     "transaction, block, log, token_transfer, trace,token\n").replace(" ", "")
    if entities == "":
        entities = "transaction,block"

    extra_options = input("If you have any further options supported by Ethereum ETL you can add the here in the "
                          "proper format. (DEFAULT: no extra options)\n")

    # If user chooses to opt in
    # write database.ini file for later use while we are at it
    if choice == "y":
        write_db_file(usn, psd, ip_addr, port, db_name)

    # return part of the command with start block and database information
    return (
            "--provider-uri FILE:/"
            + provider_uri
            + " "
            + start
            + " "
            + "--output postgresql+pg8000://"
            + usn
            + ":"
            + psd
            + "@"
            + ip_addr
            + ":"
            + port
            + "/"
            + db_name
            + " -e "
            + entities
            + " "
            + extra_options
    )


# Get user info about Database
def db_info():
    clear()
    print("Please type in the requested information about your database and hit ENTER")
    usn = input("User: ")
    psd = getpass()
    ip_addr = input("IP Address(DEFAULT: localhost): ")
    if ip_addr == "":
        ip_addr = "localhost"
    port = input("Port(DEFAULT: 5432): " or "5432")
    if port == "":
        port = "5432"
    db_name = input("Database name: ")
    # Write information to database.ini
    write_db_file(usn, psd, ip_addr, port, db_name)
