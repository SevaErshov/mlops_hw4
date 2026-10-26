with stats as (
    select
        customer_id,
        count() as transaction_count,
        sum(is_fraud) as fraud_count,
        100.0 * sum(is_fraud) / count() as fraud_rate,
        sum(amount) as total_amount,
        avg(amount) as avg_amount,
        min(transaction_time) as first_transaction,
        max(transaction_time) as last_transaction
    from {{ ref('stg_transactions') }}
    group by customer_id
)
select *,
    case
        when fraud_rate >= 5 then 'HIGH'
        when fraud_rate >= 1 then 'MEDIUM'
        else 'LOW'
    end as risk_level
from stats
