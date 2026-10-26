{% for model in ['mart_fraud_by_category', 'mart_fraud_by_state', 'mart_customer_risk_profile'] %}
select '{{ model }}' as model, fraud_rate
from {{ ref(model) }}
where fraud_rate < 0 or fraud_rate > 100
{% if not loop.last %}union all{% endif %}
{% endfor %}
