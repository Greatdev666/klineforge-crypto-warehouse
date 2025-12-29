# Page 1 — Market Pulse

## Purpose
The Market Pulse page provides a high-level directional overview of a selected crypto asset.  
Its goal is to answer a single question quickly:

> *Is the market meaningfully moving, and in which direction?*

This page is designed for **orientation**, not trade execution.

---

## Key KPIs

### Avg 24h Return
- Measures average short-term price movement.
- Used to contextualize immediate momentum.

### Avg Volatility
- Indicates the current volatility regime.
- Helps distinguish between stable and turbulent periods.

### Avg Correlation
- Shows how closely the asset is moving with the broader market.
- High values suggest systemic risk or market-wide sentiment.

### Market State
- Synthesizes volatility and correlation into a qualitative regime:
  - Calm
  - Transition
  - Risk-On / Risk-Off

---

## Market Direction (Price Chart)

- Displays closing price over the selected interval.
- Uses **open timestamp** to preserve true price granularity.
- Serves as the primary visual anchor for interpretation.

---

## Top Movers Table

### Interval Return %
- Percentage price change over the selected interval.
- Forms the backbone of directional analysis.

### Mover Signal
A qualitative classification derived **solely from price movement magnitude**.

**Signal Logic:**
- Strong Bullish: ≥ +10%
- Bullish: +3% to +10%
- Weak Bullish: 0% to +3%
- Weak Bearish: 0% to -3%
- Bearish: -3% to -10%
- Strong Bearish: ≤ -10%

This design ensures that large drawdowns are never understated.

### Avg Volume Pressure
- Contextual metric showing relative trading activity.
- Used for confirmation, not signal classification.

---

## Design Philosophy
- Price action defines direction.
- Magnitude defines strength.
- Volume provides context, not override.

This approach prioritizes interpretability and aligns signals with trader intuition while remaining analytically sound.

---

## Intended Usage
- Market scanning
- Regime awareness
- Directional bias assessment

Not intended for:
- Entry timing
- Strategy backtesting
- Signal automation
