import psycopg2
from configparser import ConfigParser
import utils.helper as h
import utils.database as d

con = None
cur = None
# Get user input for database.ini file
def get_user_input():
    h.clear()
    choice = input(
        "Do you want to generate a database.ini file(y) or not(n)? (DEFAULT: y)"
        "Only choose no if you already have one in the current directory\n"
    )
    if choice == "":
        choice = "y"

    if choice == "y":
        try:
            h.get_info(2)
        except IOError:
            print("Something went wrong")
        finally:
            choose()
            close_connection()
    else:
        choose()
        close_connection()
# Parse connection details from database.ini file
# def connection_details(filename='database.ini',
#                        section='database_connection_details'):
#     parser = ConfigParser()
#     parser.read(filename)

#     db = {}
#     if parser.has_section(section):
#         params = parser.items(section)
#         for param in params:
#             db[param[0]] = param[1]
#     else:
#         raise Exception('No such section in database.ini file')

#     return db


def close_connection():
    d.disconnect_from_db(con, cur)

# Choose what tables to setup
def choose():
    con, cur = d.connect_to_db()
    print("Choose which tables to create...")
    choice = int(
        input(
            "1. Table for Ethereum ETL\n2. Star Schema\n3. ETL Tables\n4. All Tables\n"
        ))
    if choice == 1:
        setup_for_extraction()
    elif choice == 2:
        setup_star_schema()
    elif choice == 3:
        setup_etl_schema()
    elif choice == 4:
        setup_all_tables()
    else:
        print("Invalid Selection, try again")
        choose()


# setup transaction and block table as per Ethereum ETL schema
def setup_for_extraction():
    try:
        print('Setting up Tables for Ethereum ETL')
        cur.execute(open("sql_scripts/01_extraction_tables.sql", "r").read())
        print('done')
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)


# Setup final star schema
def setup_star_schema():
    try:
        print('Setting up Star Schema')
        cur.execute(open("sql_scripts/02_star_schema.sql", "r").read())
        print('done')
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)

# setup all extraction, transformation and loading tables
def setup_etl_schema():
    try:
        print('Setting up tables for ETL Process')
        cur.execute(open("sql_scripts/03_etl.sql", "r").read())
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)

    print('done')


# Setup all tables
def setup_all_tables():
    setup_for_extraction()
    setup_star_schema()
    setup_etl_schema()

# Connect to the database
# def connect_to_db():
#     con = None
#     try:
#         h.clear()
#         # create connection to database
#         print("Connecting to database")
#         con = psycopg2.connect(**connection_details())

#         # creating a cursor
#         cur = con.cursor()
#         choose(cur)
#         con.commit()
#         # close cursor
#         cur.close()

#     except (Exception, psycopg2.DatabaseError) as error:
#         print(error)
#     # always close connection to database
#     finally:
#         if con is not None:
#             print("Closing connection to database...")
#             con.close()
#             print("done")


def main():
    get_user_input()


if __name__ == "__main__":
    main()
