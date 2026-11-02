-- 1. Montant des commandes payées par mois
SELECT
    date_trunc('month', o.ordered_at)::date AS mois,
    COUNT(DISTINCT o.order_id) AS commandes_payees,
    SUM(i.quantity * i.unit_price) AS montant_total
FROM retail.orders o
JOIN retail.order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY 1
ORDER BY 1;

-- 2. Les 10 produits les plus vendus en quantité
SELECT
    p.product_id,
    p.label,
    SUM(i.quantity) AS quantite_vendue,
    SUM(i.quantity * i.unit_price) AS montant_total
FROM retail.products p
JOIN retail.order_items i ON i.product_id = p.product_id
JOIN retail.orders o ON o.order_id = i.order_id
WHERE o.status = 'paid'
GROUP BY p.product_id, p.label
ORDER BY quantite_vendue DESC, p.product_id
LIMIT 10;

-- 3. Montant et panier moyen des commandes payées par région
WITH montants_commandes AS (
    SELECT
        o.order_id,
        o.customer_id,
        SUM(i.quantity * i.unit_price) AS montant
    FROM retail.orders o
    JOIN retail.order_items i ON i.order_id = o.order_id
    WHERE o.status = 'paid'
    GROUP BY o.order_id, o.customer_id
)
SELECT
    c.region,
    COUNT(*) AS commandes_payees,
    SUM(m.montant) AS montant_total,
    ROUND(AVG(m.montant), 2) AS panier_moyen
FROM montants_commandes m
JOIN retail.customers c ON c.customer_id = m.customer_id
GROUP BY c.region
ORDER BY montant_total DESC, c.region;
