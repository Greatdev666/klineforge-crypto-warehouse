# Page 5 — Investment Outcome Simulator  
**Capital Allocation, Drawdowns & Realized Returns**

---

## 🎯 Purpose of This Page

The **Investment Outcome Simulator** allows users to perform **hindsight-based what-if analysis** on a single crypto asset.

This page answers a very practical question:

> *“If I invested X dollars in this asset on a given date, what would my outcome be today — and what risk did I experience along the way?”*

Unlike predictive or strategy-based simulators, this page is **grounded in realized market data**, prioritizing clarity, realism, and interpretability.

---

## 🧠 Design Philosophy

- **Single-asset focus** (no allocation assumptions)
- **Warehouse-first calculations**
- **Minimal DAX complexity**
- **Narrative-driven KPIs**
- **Risk is visualized, not abstracted**

This page intentionally avoids speculative modeling (e.g., win-rate projections, position sizing, or portfolio weighting), which belong in a future strategy simulator.

---

## 🎛️ User Controls (Slicers)

| Slicer | Description | Behavior |
|------|------------|---------|
| **Coin** | Selected asset (e.g., ETH) | Single-select |
| **Start Date** | Investment entry date | Filters entry price |
| **End Date** | Analysis horizon | Defines final valuation |
| **Investment Amount** | Capital invested (USD) | What-if parameter |

> ⚠️ Multi-select is intentionally disabled to prevent unrealistic capital allocation assumptions.

---

## 📊 KPI Summary Cards

### 1️⃣ Initial Investment  
**Definition:**  
User-selected capital amount.

**Purpose:**  
Establishes baseline capital reference.

---

### 2️⃣ Final Value  
**Definition:**  
Market value of the investment at the selected end date.

**Logic:**  
```
   Units Purchased × Final Price
```

---

### 3️⃣ Net P&L  
**Definition:**  
Absolute profit or loss in USD.

**Logic:**  

``` 
    Final Value − Initial Investment
```

**Color Logic:**
- Green → Profit
- Red → Loss

---

### 4️⃣ Return %  
**Definition:**  
Percentage gain or loss over the investment horizon.

**Logic:**  
```
    Net P&L ÷ Initial Investment
```


**Purpose:**  
Normalizes outcomes across different investment sizes.

---

## 📝 Hindsight Narrative

### Hindsight Summary Text

A dynamic explanatory sentence is generated to contextualize the results:

> *“If you invested $500 in ETH on the selected start date, your investment would now be worth $661 (32.12%), resulting in a net gain of $161.”*

**Why this matters:**  
- Bridges metrics into natural language
- Makes outcomes understandable to non-technical users
- Reduces cognitive load when reading KPIs

---

## 📈 Portfolio Value Over Time

### Visual: Line Chart  
**X-axis:** Date  
**Y-axis:** Portfolio Value (USD)

**Purpose:**
- Visualizes investment volatility
- Shows path dependency (not just endpoints)
- Reinforces that returns are not linear

**Interpretation:**
- Spikes → short-term gains
- Drawdowns → risk exposure
- Flat periods → opportunity cost

---

## 📉 Drawdown Over Time

### Visual: Line Chart  
**X-axis:** Open Timestamp  
**Y-axis:** Drawdown %

**Definition:**  
Drawdown is measured as the percentage decline from the running peak price.

**Why this visual exists:**
- Reveals psychological risk, not just financial return
- Shows worst-case pain endured before recovery
- Reinforces capital protection mindset

> This is intentionally plotted alongside portfolio value to contrast **reward vs. pain**.

---

## 🧱 Data Modeling Notes (Warehouse-First)

Key metrics powering this page are computed upstream in dbt marts:

- `running_peak_price`
- `drawdown_pct`
- `return_pct`
- `close_price`

This ensures:
- Deterministic calculations
- DAX simplicity
- Performance stability
- Metric consistency across pages

---

## ❌ Explicitly Excluded (By Design)

The following were intentionally **not** included:

- Win-rate simulation
- Stop-loss / take-profit logic
- Multi-asset allocation
- BTC vs Alt weighting
- Predictive or probabilistic outcomes

> These require either strategy assumptions or stochastic modeling and are better suited for a dedicated **Strategy Simulator** page or ML-driven workflows.

---

## 🧠 Key Takeaways for Users

- High returns can still come with deep drawdowns
- Entry timing matters significantly
- Risk is experienced *during* the journey, not just at the end
- Simple hindsight analysis already provides strong intuition

---

## 🔗 Relationship to Other Pages

| Page | Relationship |
|----|-------------|
| Diversification | Explains correlation risk |
| Risk Management | Explains drawdown behavior |
| Portfolio Simulator | Combines both into a single realized outcome |

This page acts as the **capstone** for the analytical journey — where all prior concepts materialize into capital outcomes.

---

## ✅ Summary

The Investment Outcome Simulator is a **grounded, honest, and interpretable** what-if tool.

It:
- Respects data realism
- Avoids overfitting or false certainty
- Encourages risk-aware thinking
- Demonstrates the power of warehouse-driven analytics

This page is not about predicting the future —  
it is about **understanding what actually happened**.

---
