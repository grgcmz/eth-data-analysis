import psycopg2

import utils.helper as h
import utils.database as d

# This script helps in setting up different tables used for an analysis of
# the Ethereum blockchain.


# setup transaction and block table as per Ethereum ETL schema
def setup_for_extraction(cur):
    try:
        print("Setting up Tables for Ethereum ETL")
        cur.execute(open("sql_scripts/01_extraction_tables.sql", "r").read())
        print("done")
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        choose()



# Setup final star schema
def setup_star_schema(cur):
    try:
        print("\nSetting up Star Schema")
        cur.execute(open("sql_scripts/02_star_schema.sql", "r").read())
        print("done")
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        choose()


# setup all extraction, transformation and loading tables
def setup_etl_schema(cur):
    print(
        "Choose the start block for the ETL process:\n"
        "(DEFAULT: first until last block)\n"
    )
    print("\n")
    number_from = int(
        input("block number from = ")
    )
    number_to = int(
        input("\nblock number to = ")
    )
    if number_to == "" and number_from == "":
        try:
            print("\nSetting up tables for ETL Process")
            cur.execute(open("sql_scripts/03_etl.sql", "r").read())
            print("done")
        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
        finally:
            choose()
    else:
        try:
            cur.execute(open("sql_scripts/04_extraction_tables.sql", "r").read())
            cur.execute('''INSERT INTO e_d_transaction (hash,
                                         nonce,
                                         transaction_index,
                                         from_address,
                                         to_address,
                                         value,
                                         gas,
                                         gas_price,
                                         input,
                                         receipt_cumulative_gas_used,
                                         receipt_gas_used,
                                         receipt_contract_address,
                                         receipt_root,
                                         receipt_status,
                                         block_timestamp,
                                         block_number,
                                         block_hash)

                            SELECT hash,
                                    nonce,
                                    transaction_index,
                                    from_address,
                                    to_address,
                                    value,
                                    gas,
                                    gas_price,
                                    input,
                                    receipt_cumulative_gas_used,
                                    receipt_gas_used,
                                    receipt_contract_address,
                                    receipt_root,
                                    receipt_status,
                                    block_timestamp,
                                    block_number,
                                    block_hash
                            FROM transactions
                            WHERE block_number >= %s and block_number <= %s;''', (number_from, number_to)
            )
            cur.execute('''INSERT INTO e_d_block (number,
                                   hash,
                                   parent_hash,
                                   nonce,
                                   sha3_uncles,
                                   logs_bloom,
                                   transactions_root,
                                   state_root,
                                   receipts_root,
                                   miner,
                                   difficulty,
                                   total_difficulty,
                                   size,
                                   extra_data,
                                   gas_limit,
                                   gas_used,
                                   timestamp,
                                   transaction_count)
                            SELECT number,
                                    hash,
                                    parent_hash,
                                    nonce,
                                    sha3_uncles,
                                    logs_bloom,
                                    transactions_root,
                                    state_root,
                                    receipts_root,
                                    miner,
                                    difficulty,
                                    total_difficulty,
                                    size,
                                    extra_data,
                                    gas_limit,
                                    gas_used,
                                    timestamp,
                                    transaction_count
                            FROM blocks
                            WHERE number >= %s and number <= %s;''',
              (number_from, number_to))
            cur.execute(open("sql_scripts/05_etl_restricted.sql", "r").read())

        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
        finally:
            choose()


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
            "1. Table for Ethereum ETL\n"
            "2. Star Schema\n"
            "3. ETL Tables\n"
            "4. All Tables\n"
            "5. Commit and Quit\n"
        )
    )
    try:
        if choice == 1:
            setup_for_extraction(cur)
        elif choice == 2:
            setup_star_schema(cur)
        elif choice == 3:
            setup_etl_schema(cur)
        elif choice == 4:
            setup_all_tables(cur)
        elif choice == 5:
            print("Quitting...")
        else:
            choose(dbcon)
    finally:
        close_connection(con, cur)


# Get some input from the user
def get_user_input():
    h.clear()
    choice = input(
        "Do you want to generate a database.ini file(y) or not(n)?\n"
        "Only choose no if you already have one in the current directory\n"
        "(DEFAULT: y)\n")
    if choice == "":
        choice = "y"

    if choice == "y":
        try:
            h.get_info(2)
        except IOError:
            print("Something went wrong")
        finally:
            choose()
    else:
        choose()


def main():
    get_user_input()


if __name__ == "__main__":
    main()
