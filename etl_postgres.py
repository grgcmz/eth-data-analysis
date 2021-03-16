import psycopg2

import utils.helper as h
import utils.database as d


# setup transaction and block table as per Ethereum ETL schema
def setup_for_extraction(cur):
    try:
        print('Setting up Tables for Ethereum ETL')
        cur.execute(open("sql_scripts/01_extraction_tables.sql", "r").read())
        print('done')
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)


# Setup final star schema
def setup_star_schema(cur):
    try:
        print('Setting up Star Schema')
        cur.execute(open("sql_scripts/02_star_schema.sql", "r").read())
        print('done')
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)


# setup all extraction, transformation and loading tables
def setup_etl_schema(cur):
    try:
        print('Setting up tables for ETL Process')
        cur.execute(open("sql_scripts/03_etl.sql", "r").read())
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)

    print('done')


# Setup all tables
def setup_all_tables(cur):
    setup_for_extraction(cur)
    setup_star_schema(cur)
    setup_etl_schema(cur)


# Call disconnect from database function
def close_connection(con, cur):
    d.disconnect_from_db(con, cur)


# Choose what tables to setup
def choose(dbcon=None):
    if dbcon is None:
        dbcon = d.connect_to_db()
    con = dbcon[0]
    cur = dbcon[1]
    print("Choose which tables to create...")
    choice = int(
        input(
            "1. Table for Ethereum ETL\n2. Star Schema\n3. ETL Tables\n4. All Tables\n"
        ))
    try:
        if choice == 1:
            setup_for_extraction(cur)
        elif choice == 2:
            setup_star_schema(cur)
        elif choice == 3:
            setup_etl_schema(cur)
        elif choice == 4:
            setup_all_tables(cur)
        else:
            choose(dbcon)
    finally:
        close_connection(con, cur)

    # return dbcon


def get_user_input():
    h.clear()
    choice = input(
        "Do you want to generate a database.ini file(y) or not(n)? (DEFAULT: y)\n"
        "Only choose no if you already have one in the current directory\n")
    if choice == "":
        choice = "y"

    if choice == "y":
        try:
            h.get_info(2)
        except IOError:
            print("Something went wrong")
        finally:
            choose()
            # close_connection(con, cur)
    else:
        choose()
        # close_connection(con, cur)


def main():
    get_user_input()


if __name__ == "__main__":
    main()