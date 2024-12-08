import mysql.connector

db_conn = mysql.connector.connect(host="localhost", user="root", password="waeuds298qwaergdjD")
cursor = db_conn.cursor()

cursor.execute("SHOW")
output = cursor.fetchall()
print (output)