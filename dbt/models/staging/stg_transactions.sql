with cleaned as (
    select
        transaction_id,
        parseDateTimeBestEffort(transaction_time, 'UTC') as transaction_time,
        trimBoth(merch) as merchant,
        lower(trimBoth(cat_id)) as category,
        toDecimal64(toString(amount), 2) as amount,
        upper(trimBoth(gender)) as gender,
        upper(trimBoth(us_state)) as state,
        lower(trimBoth(name_1)) as first_name,
        lower(trimBoth(name_2)) as last_name,
        lower(trimBoth(street)) as street,
        toFloat64(lat) as lat,
        toFloat64(lon) as lon,
        toUInt8(target) as is_fraud
    from {{ source('raw', 'transactions') }}
)
select
    transaction_id,
    transaction_time,
    toDate(transaction_time) as transaction_date,
    {{ dbt_date.day_of_week('transaction_time') }} as day_of_week,
    merchant,
    category,
    amount,
    {{ amount_bucket('amount') }} as amount_bucket,
    gender,
    state,
    hex(MD5(concat(first_name, '|', last_name, '|', street, '|', toString(lat), '|', toString(lon)))) as customer_id,
    is_fraud
from cleaned
