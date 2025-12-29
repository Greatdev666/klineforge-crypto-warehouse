# 📊 Coin Deep Dive — Analytical View

## 🎯 Purpose

The **Coin Deep Dive** page provides a focused, asset-level analysis designed to answer one core question:

> *What is happening to this coin right now, how risky is it, and is current market activity abnormal?*

This page is built for **exploratory analysis**, not execution-level trading, and prioritizes clarity, interpretability, and analytical correctness.

---

## 🔍 Drill-Through Context

- This page is accessed via **drill-through** from:
  - Market Overview tables
  - Correlation matrices
- Drill-through field: `coin`
- All visuals are scoped to a **single selected asset**

---

## 📌 Key Performance Indicators (KPIs)

### 1️⃣ Last Price

**Definition:**  
The most recent close price for the selected asset.

**Why it exists:**  
Acts as a real-time anchor for all other metrics.

**Notes:**
- Not averaged
- Not interval-aware
- Always reflects the latest available price

---

### 2️⃣ VWAP Deviation (%)

**Definition:**  
Percentage distance between the current price and the 24-hour VWAP.

**Formula:**

**Interpretation:**
- Positive → Price above fair value
- Negative → Price below fair value
- Near zero → Efficiently priced

**Why deviation is used instead of raw VWAP:**  
Raw VWAP tends to flatten visually. Deviation expresses **relative positioning**, which is analytically more useful.

---

### 3️⃣ RSI (14-period)

**Definition:**  
A momentum oscillator measuring the balance between recent gains and losses over a 14-period rolling window.

**Scale:**  
0–100

**Interpretation:**
- RSI ≥ 70 → Overbought
- RSI ≤ 30 → Oversold
- RSI ≈ 50 → Neutral momentum

**Why RSI is included:**  
Provides short-term momentum context that price alone cannot reveal.

---

### 4️⃣ Average Volume Pressure

**Definition:**  
Average of the volume spike ratio over the selected date range.

**Interpretation:**
- ~1.0 → Normal activity
- 1.5–2.0 → Elevated interest
- >2.0 → Sustained abnormal activity

**Why average (not max):**  
This KPI represents **state**, not isolated events.

---

### 5️⃣ Volume Activity State

**Definition:**  
Categorical label derived from average volume pressure.

**States:**
- Normal
- Elevated
- High Activity

**Purpose:**  
Provides an at-a-glance understanding of participation intensity.

---

## 📈 Time-Series Visuals

### Price vs VWAP Deviation

- X-axis: Hourly timestamp
- Lines:
  - Close price
  - VWAP deviation

**Why this matters:**  
Shows how price evolves relative to fair value over time.

---

### RSI Trend

- X-axis: Hourly timestamp
- Y-axis: RSI (0–100)
- Constant reference lines:
  - 30 (Oversold)
  - 70 (Overbought)

**Why this matters:**  
Highlights momentum shifts that often precede price reversals.

---

### Volatility Trend

**Metric:**  
24-hour rolling return volatility

**Interpretation:**
- Low values → Stable conditions
- Rising values → Increasing risk
- Spikes → Unstable regimes

**Why returns-based volatility:**  
Return volatility is scale-independent and better suited for cross-asset comparison.

---

### Volume Trend

**Metric:**  
Average hourly traded volume

**Why average instead of sum:**  
Captures **typical trading behavior** rather than market size.

---

### Volume Spike Indicator

**Metric:**  
Maximum volume spike ratio observed in the selected period.

**Interpretation:**
- Values represent multiples of normal activity (e.g., 5 = 5× normal volume)
- Used as an **alert**, not a state metric

---

## 🧠 Design Philosophy

- **One asset, one story**
- KPIs represent **state**
- Extremes are surfaced as **signals**
- All metrics respect:
  - Coin filters
  - Date filters
- Interval slicing is applied only where analytically meaningful

---

## ⚠️ Analytical Notes

- RSI is computed dynamically using rolling windows
- VWAP values are precomputed in the warehouse for performance
- No raw fact table is imported into Power BI
- All visuals rely on curated marts and dimensions

---

## 🚀 Future Enhancements

- Precomputed RSI in DBT for performance
- Session-based overlays (Asia / EU / US)
- Signal confidence scoring
- Trade simulation overlays

---

