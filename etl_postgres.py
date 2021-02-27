import psycopg2
from configparser import ConfigParser

def connection_details(filename='database.ini', section='database_connection_details'):
    parser = ConfigParser()
    parser.read(filename)

    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        raise Exception('No such section in database.ini file')

    return db

def setup_tables(cur):
    try:
        print('Setting up Tables for Ethereum ETL')
        cur.execute(open("scripts/01_temp_schema.sql", "r").read())
        print('done')
        print('Setting up Star Schema')
        cur.execute(open("scripts/02_star_schema.sql", "r").read())
        print('done')
        print('Doing ETL Process')
        cur.execute(open("scripts/03_etl.sql", "r").read())
        print('done')
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)

def connect_to_db():
    con = None
    try:
        # create connection to database
        print("Connecting to DB")
        con = psycopg2.connect(**connection_details())

        # creating a cursor
        cur = con.cursor()
        
        setup_tables(cur)
        con.commit()
        # close cursor
        cur.close()
        

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    # always close connection to database
    finally:
        if con is not None:
            con.close()


if __name__ == "__main__":
    connect_to_db()
