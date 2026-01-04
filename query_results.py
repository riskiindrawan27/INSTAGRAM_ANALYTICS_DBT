import duckdb

conn = duckdb.connect('instagram_analytics.duckdb')
result = conn.execute('SELECT * FROM current_content_unengagement ORDER BY created_time DESC LIMIT 10').fetchall()

print('ID | CREATED_TIME | USER_ID | MEDIA_TYPE | MEDIA_PRODUCT_TYPE | UNENGAGEMENTS')
print('-' * 100)
for row in result:
    print(f'{row[0]} | {row[1]} | {row[2]} | {row[3]} | {row[4]} | {row[5]}')

conn.close()
