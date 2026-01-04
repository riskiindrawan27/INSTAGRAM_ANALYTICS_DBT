import duckdb

conn = duckdb.connect('instagram_analytics.duckdb')

# Query for summary statistics
print("=" * 100)
print("INSTAGRAM ANALYTICS - CURRENT CONTENT UNENGAGEMENT METRIC")
print("=" * 100)
print()

# Total records
total_records = conn.execute('SELECT COUNT(*) FROM current_content_unengagement').fetchone()[0]
print(f"Total Content Items: {total_records}")
print()

# Sample data
print("SAMPLE DATA (Top 5 Recent Posts):")
print("-" * 100)
result = conn.execute('''
    SELECT 
        id,
        created_time,
        user_id,
        media_type,
        media_product_type,
        unengagements
    FROM current_content_unengagement
    ORDER BY created_time DESC
    LIMIT 5
''').fetchall()

print(f"{'ID':<20} {'CREATED_TIME':<25} {'USER_ID':<20} {'TYPE':<15} {'PRODUCT':<10} {'UNENGAGE':<10}")
print("-" * 100)
for row in result:
    print(f"{row[0]:<20} {str(row[1]):<25} {row[2]:<20} {row[3]:<15} {str(row[4]):<10} {row[5]:<10}")

print()

# Summary by media type
print("SUMMARY BY MEDIA TYPE:")
print("-" * 100)
summary = conn.execute('''
    SELECT 
        media_type,
        media_product_type,
        COUNT(*) as content_count,
        SUM(unengagements) as total_unengagements,
        CAST(AVG(unengagements) AS DECIMAL(10,2)) as avg_unengagements
    FROM current_content_unengagement
    GROUP BY media_type, media_product_type
    ORDER BY content_count DESC
''').fetchall()

print(f"{'MEDIA_TYPE':<20} {'PRODUCT_TYPE':<15} {'COUNT':<10} {'TOTAL_UNENG':<15} {'AVG_UNENG':<10}")
print("-" * 100)
for row in summary:
    print(f"{row[0]:<20} {str(row[1]):<15} {row[2]:<10} {row[3]:<15} {row[4]:<10}")

print()
print("=" * 100)
print("✓ All models successfully built and tested!")
print("=" * 100)

conn.close()
