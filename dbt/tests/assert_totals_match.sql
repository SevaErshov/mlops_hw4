with raw_totals as (
    select count() as n, sum(toDecimal64(toString(amount), 2)) as amount
    from {{ source('raw', 'transactions') }}
)
{% for model in ['mart_daily_state_metrics', 'mart_fraud_by_category', 'mart_fraud_by_state', 'mart_customer_risk_profile'] %}
select '{{ model }}' as model
from (select sum(transaction_count) as n, sum(total_amount) as amount from {{ ref(model) }}) as m
cross join raw_totals as r
where m.n != r.n or m.amount != r.amount
{% if not loop.last %}union all{% endif %}
{% endfor %}
