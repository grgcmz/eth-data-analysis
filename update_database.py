import psycopg2
from configparser import ConfigParser
import helper as h

def main():
    choice = input ("This script assume that you have a database.ini file"
                    "in the current dirctory as well as a lasty_synced_block.txt"
                    "Type 'y' to continue or 'ctrl+c' otherwise")
    if choice == "":
        choice = "y"

    while choice != "y":
        choice = input ("Invalid input."
                        "Type 'y' to continue or 'ctrl+c' otherwise")









if __name__ == "__main__":
    main()
