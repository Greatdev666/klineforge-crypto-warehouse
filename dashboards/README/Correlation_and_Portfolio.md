# PHASE 4 — CORRELATION & PORTFOLIO ANALYSIS

## 🎯 Objective

Provide **diversification insight** by analyzing how selected crypto assets move relative to each other.
This page answers:

- Are my assets truly diversified?
- Which coins are tightly coupled?
- Where does portfolio risk concentrate?

---

## 📐 Page Layout

[ Diversification KPIs ]

[ Price Comparison (Normalized) ]

[ Correlation Heatmap ] 


---

## 🎛️ Slicers (Page Scope)

| Slicer | Purpose | Applies To |
|-----|------|------|
| Base Coin | Anchor asset (e.g. BTC, ETH) | All visuals |
| Date Range | Market regime window | All visuals |
| Interval | Correlation horizon | Correlation metrics |

> Note: Coin pair selection is driven by `base_coin` to support multiple quote assets (USDT, BNB, etc.).

---

## 📊 Visual 1 — Diversification KPIs

### Metrics

#### Diversification Score
```text
1 - average absolute correlation
```
### Interptretation
* Close to 1 → highly diversified
* Close to 0 → tightly clustered portfolio

### Avg Correlation
* Mean relationship strength across all pairs

### Max Correlation
* Worst-case dependency inside the portfolio 

---
## 🎨 KPI Color Logic

| Condition | Meaning | Color |
|-----|------|------|
| Low Correlation | Healthy Diversification |Green |
| Medium | Partial Clustering | Yellow |
| High | Risk Concentration | Red |

**Colors are driven by DAX measures (not static formatting).**

---

## 📈 Visual 2 — Price Comparison (Normalized)
#### Visual Type: Multi Line Chart

**Logic**
* All Prices indexed to a base value 
* Removes price-scale bias (BTC vs ALT Coins)
* Enables relative performance comparison

## Axes
| Axis | Field | 
|-----|------|
| X | Open Timestamp |
| Y | Normalized Price Index | 

## Tooltip
* Actual Close Price
* Normalized Return %

## Why Normalization?
**Raw rices cannot be compared directly:**
* BTC ≠ SOL ≠ DOGE 

**Normalization answers** 
* "Which assets performed better over this period ?"

## 🧩 Visual 3 — Correlation Heatmap
## Visual Type: Matrix
| Component | Field | 
|-----|------|
| Rows | base_coin |
| Columns | related_coin | 
| Values | Avg Correlation | 

## Color Scale
| Correlation | Color | 
|-----|------|
| Lows/Negative | Green |
| Near Zero | Neutral | 
| High | Red | 

## Formatting
* Background color scale
* Fixed range: -1 to +1
* No data bars

## How to read the Heatmap
* Green blocks → diversification opportunities
* Red blocks → redundancy / systemic risk
* Diagonal values are ignored (self-correlation)

## 🏁 Design Principles Applied
* KPI-first hierarchy for instant insight
* Minimal slicers to avoid cognitive overload
* Correlation semantics respected (not return-based colors)
* Institutional dark theme for contrast and focus

## ✅ Outcomes
**This page enables:**
* Portfolio risk diagnosis
* Asset selection refinement
* Diversification validation
* Strategic rebalancing decisions