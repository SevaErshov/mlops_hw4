import csv
import io
import zipfile
from pathlib import Path

import clickhouse_connect

client = clickhouse_connect.get_client(host='localhost', port=8124, username='student', password='student')
archive = Path(__file__).resolve().parents[1] / 'data/teta-ml-1-2025.zip'
client.command('CREATE DATABASE IF NOT EXISTS transactions_db')
client.command('''
CREATE TABLE IF NOT EXISTS transactions_db.transactions (
    transaction_id UInt64,
    transaction_time String,
    merch String,
    cat_id String,
    amount Float64,
    name_1 String,
    name_2 String,
    gender String,
    street String,
    us_state String,
    lat Float64,
    lon Float64,
    merchant_lat Float64,
    merchant_lon Float64,
    target UInt8
) ENGINE = MergeTree ORDER BY transaction_id
''')
if client.query('SELECT count() FROM transactions_db.transactions').first_row[0]:
    raise SystemExit('Таблица уже заполнена. Повторная загрузка отменена.')
columns = ['transaction_id', 'transaction_time', 'merch', 'cat_id', 'amount', 'name_1', 'name_2', 'gender', 'street', 'us_state', 'lat', 'lon', 'merchant_lat', 'merchant_lon', 'target']
batch = []
with zipfile.ZipFile(archive) as z:
    with z.open('train.csv') as f:
        for i, row in enumerate(csv.DictReader(io.TextIOWrapper(f, encoding='utf-8-sig')), 1):
            row['transaction_id'] = i
            for key in ['amount', 'lat', 'lon', 'merchant_lat', 'merchant_lon']:
                row[key] = float(row[key])
            row['target'] = int(row['target'])
            batch.append([row[key] for key in columns])
            if len(batch) == 10000:
                client.insert('transactions_db.transactions', batch, column_names=columns)
                batch = []
        if batch:
            client.insert('transactions_db.transactions', batch, column_names=columns)
print(client.query('SELECT count(), sum(target) FROM transactions_db.transactions').result_rows)
