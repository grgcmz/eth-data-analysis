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
    
def etl_info():
    clear()
    print(
        "Please note that this tool will write your database password into a local"\
        "file called database.ini. This file is later used in the etl python script"\
        "to create some tables. It NEVER leaves your PC, but you might want to opt"\
        "out if you don't need it or already have one."
    )
    choice = input(
        "\nDo you want to automatically create a database.ini file(y) or not(n)? (DEFAULT: y)\n")
    if choice == "":
        choice = "y"    
    clear()
    print("Please type in the requested information about your database and hit ENTER")
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

# Get user info about Database
def db_info():
    clear()
    print("Please type in the requested information about your database and hit ENTER")
    usn = input("User: ")
    pswd = getpass()
    ip_addr = input("IP Address(DEFAULT: localhost): ")
    if ip_addr == "":
        ip_addr = "localhost"
    port = input("Port(DEFAULT: 5432): " or "5432")
    if port == "":
        port = "5432"
    db_name = input("Database name: ")
    
    # Write information to database.ini
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