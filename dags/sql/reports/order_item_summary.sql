{% if is_modified %}
DROP MATERIALIZED VIEW IF EXISTS {{ destination_schema }}.order_item_summary CASCADE;
{% end %}
CREATE MATERIALIZED VIEW IF NOT EXISTS {{ destination_schema }}.order_item_summary AS
    SELECT
        o.id AS order_id,
        COUNT(oi.id) AS total_items,
        COUNT(CASE WHEN oi.fulfilled = TRUE THEN 1 END) AS num_items_fulfilled,
        COUNT(CASE WHEN oi.purchased = TRUE THEN 1 END) AS num_purchased,
        COUNT(CASE WHEN oi.returned = TRUE THEN 1 END) AS num_returned,
        COUNT(CASE WHEN oi.purchased = TRUE AND oi.returned = FALSE THEN 1 END) AS num_bought,
        COUNT(CASE WHEN oi.preorder = TRUE THEN 1 END) AS num_preorder,
        COUNT(CASE WHEN oi.received = TRUE THEN 1 END) AS num_received_by_customer,
        COUNT(CASE WHEN oi.received_by_warehouse = TRUE THEN 1 END) AS num_received_by_warehouse
    FROM
        public.orders o
    JOIN
        order__items oi ON o.id = oi.order_id
    GROUP BY
        o.id;
WITH NO DATA;
{% if is_modified %}
CREATE UNIQUE INDEX order_item_summary_idx ON {{ destination_schema }}.order_item_summary (id);
{% end %}
REFRESH MATERIALIZED VIEW {{ destination_schema }}.order_item_summary;
