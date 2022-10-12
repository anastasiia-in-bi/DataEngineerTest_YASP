import csv
import psycopg2
import xlrd
from pyxlsb import convert_date

#Fill in perations table
conn = psycopg2.connect(
            host="localhost",
            database="yasp",
            user="postgres",
            password="password")
cur = conn.cursor()
with open('data_for_import/operation.csv', 'r') as f:
    reader = csv.reader(f, delimiter=',', quotechar='"')
    next(reader)  # Skip the header row
    for row in reader:
        cur.execute(
        "INSERT INTO custom.operations VALUES (%s, %s, %s::text, TO_DATE(%s,'DD.MM.YYYY'), %s::text, %s);COMMIT;",
        row
    )
# cur.execute('select * from custom.operations;') #Check the result of insert
# print(cur.fetchall())                           #Check the result of insert
cur.close()
conn.close()


# Fill in org table
book = xlrd.open_workbook("data_for_import/org.xls")
sheet = book.sheet_by_name("Лист1")
conn = psycopg2.connect(
    host="localhost",
    database="yasp",
    user="postgres",
    password="password")
cur = conn.cursor()
query = """INSERT INTO custom.org VALUES (%s, %s, %s, %s, %s);"""

for r in range(1, sheet.nrows):
    org_id1 = sheet.cell(r, 0).value
    org_id = int(org_id1)
    parent_id1 = sheet.cell(r, 1).value
    if parent_id1 == '':
        parent_id = None
    else:
        parent_id = int(parent_id1)
    dt1 = sheet.cell(r, 2).value
    dt = format(convert_date(dt1), '%Y-%m-%d')
    name = sheet.cell(r, 3).value
    tlg = sheet.cell(r, 4).value
    values = (org_id, parent_id, dt, name, tlg)
    cur.execute(query, values)
conn.commit()

# cur.execute('select * from custom.org;')  # Check the result of insert
# print(cur.fetchall())  # Check the result of insert

cur.close()
conn.commit()
conn.close()


# Fill in summary table
conn = psycopg2.connect(
    host="localhost",
    database="yasp",
    user="postgres",
    password="password")
cur = conn.cursor()
with open('data_for_import/summary.txt', 'r') as f:
    lines = f.readlines()[1:]
    query = """INSERT INTO custom.summary VALUES (%s, TO_DATE(%s,'YYYY.MM.DD'), %s); COMMIT;"""
    for line in lines:
        line = line.split(';')
        line = [i.strip() for i in line]
        org_id = int(line[0])
        dt = line[1]
        amount = int(line[2])

        values = (org_id, dt, amount)
        cur.execute(query, values)

# cur.execute('select * from custom.summary;') #Check the result of insert
# print(cur.fetchall())                            #Check the result of insert
cur.close()
conn.close()
