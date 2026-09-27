##🥈Runner-up (2nd place), Analytics Engineering Hackathon — Birmingham Business School × dbt Labs, 2026**

## Project overview

This dbt project uses curated Jaffle Shop data to answer a business question: **which product types generate the most gross profit, and how much of their supply cost comes from perishable ingredients?** I presented the analysis at the university hackathon and finished runner-up.

The repository began with the [dbt Labs university workshop starter](https://github.com/atrivedi-dbtlabs/university_workshop_starter). The completed project adds staging, intermediate, and mart models, data quality tests, and a profitability analysis in BigQuery. The original MIT license and Git history are retained.

## Analytical approach

The analysis uses six seed tables: customers, orders, items, products, stores, and supplies. Each row in `raw_items` represents one unit sold; the source has no quantity field. The model treats the product price as revenue per item and sums the linked supply costs as cost per item.

| Model layer | Main assets | Role in the analysis |
| --- | --- | --- |
| Staging | `stg_customers`, `stg_orders`, `stg_items`, `stg_products`, `stg_stores`, `stg_supplies` | Standardize source fields and document each table's grain. |
| Intermediate | `int_supply_costs_per_sku` | Aggregate supply costs to one row per product SKU before joining, avoiding duplicated revenue from the one-to-many supply relationship. |
| Marts | `dim_products_enriched`, `fct_order_items` | Combine item revenue, total supply cost, perishable supply cost, and gross profit at the sold-item level. |

The key measures are:

- **Gross profit:** item revenue minus aggregated supply cost.
- **Gross margin:** gross profit divided by revenue.
- **Perishable cost share:** perishable supply cost divided by total supply cost.

Schema tests cover unique and non-null identifiers, the combined supply-and-product key, and non-negative cost values. The SQL models keep monetary values in **cents**, as provided in the seed files; the dollar amounts below are presentation conversions.

## Findings

| Product type | Revenue, USD (source cents) | Supply cost, USD (source cents) | Gross profit, USD (source cents) | Gross margin | Perishable cost share |
| --- | ---: | ---: | ---: | ---: | ---: |
| Beverage | $4,510.00 (451,000) | $890.89 (89,089) | $3,619.11 (361,911) | 80.25% | 72.89% |
| Jaffle | $2,308.00 (230,800) | $514.83 (51,483) | $1,793.17 (179,317) | 77.69% | 89.18% |

Beverages lead on both revenue and gross profit; the ranking does not reverse when costs are included. Jaffles have a higher perishable cost share (89.18% versus 72.89%) and a lower gross margin (77.69% versus 80.25%). The roughly 16-percentage-point difference in perishable cost share coincides with a roughly 2.5-point difference in margin.

**Business recommendation:** Review supplier terms for the perishable ingredients used in jaffles and assess shelf-stable substitutes. These are the most relevant cost levers suggested by the observed product-type difference. Re-run the analysis by store when other locations have order history.

## Scope and limitations

All **686 orders** in the seed data belong to the Philadelphia store. The other five stores have no order history, so the data does not support a comparison of store-level profitability. The per-item cost is estimated from the static supply list and the one-unit-per-item assumption; the observed relationship between perishable cost share and margin does not establish causation.

## Reproduce the analysis

Configure a writable BigQuery project and a local dbt `profiles.yml` entry named `university_workshop` (the file is intentionally excluded from Git). Then run:

```bash
dbt deps
dbt seed
dbt build --select +fct_order_items +dim_products_enriched
```

The separate `models/moms_flower_shop/staging/` exercise is not part of this profitability analysis. Its source configuration refers to a workshop BigQuery project and needs updating before it can be built in another environment.

## Sources and license

The sample data comes from the [Jaffle Shop](https://github.com/dbt-labs/jaffle-shop) project through the [university workshop starter](https://github.com/atrivedi-dbtlabs/university_workshop_starter). The starter's [MIT license](LICENSE) remains in this repository.
