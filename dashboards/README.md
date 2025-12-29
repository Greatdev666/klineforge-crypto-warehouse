# KlineForge Analytics Dashboards

## Overview

This directory contains the visualization layer of **KlineForge** — a production-grade crypto analytics platform built on top of a modern analytics engineering stack.

The dashboards translate pre-computed warehouse metrics into **interpretable market intelligence**, enabling retail traders and analysts to reason about:

- Market regimes
- Asset behavior
- Cross-asset risk
- Drawdowns
- Portfolio outcomes

All dashboards are powered by curated **Gold & Mart models**, ensuring metrics are consistent, performant, and reproducible.

---

## Dashboard Suite

### 01 — Market Pulse
**Purpose:** High-level market orientation and directional awareness.

**Answers:**
- Is the asset trending or ranging?
- How volatile is the current regime?
- Is the market moving with or against peers?

**Primary Signals:**
- Interval return
- Volatility regime
- Correlation pressure
- Price-driven mover signal

📄 Detailed documentation → [`README_Market_Pulse.md`](../readme/README_Market_Pulse.md)

---

### 02 — Coin Deep Dive
**Purpose:** Asset-level behavioral analysis.

**Answers:**
- How does this coin behave internally?
- Is momentum strengthening or weakening?
- Are indicators diverging from price?

**Primary Signals:**
- RSI
- Rolling volatility
- VWAP & price deviation
- Trend persistence

📄 Detailed documentation → [`README_Coin_Deep_Dive.md`](../readme/README_Coin_Deep_Dive.md)

---

### 03 — Correlation & Portfolio
**Purpose:** Cross-asset relationship and diversification analysis.

**Answers:**
- Are selected assets highly correlated?
- Is diversification real or illusionary?
- Where is systemic risk concentrated?

**Primary Signals:**
- Pairwise correlations
- Correlation clustering
- Portfolio concentration indicators

📄 Detailed documentation → [`README_Correlation_Portfolio.md`](../readme/README_Correlation_Portfolio.md)

---

### 04 — Risk Management
**Purpose:** Downside exposure and loss concentration awareness.

**Answers:**
- How severe are historical drawdowns?
- Which assets carry the most downside risk?
- Is risk concentrated or distributed?

**Primary Signals:**
- Worst drawdown %
- Drawdown ranking
- Volatility regime
- Risk state classification

📄 Detailed documentation → [`README_Risk_Management.md`](../readme/README_Risk_Management.md)

---

### 05 — Investment Outcome Simulator
**Purpose:** What-if investing and hindsight-based outcome exploration.

**Answers:**
- What would an investment have become over time?
- How did drawdowns evolve during holding?
- What was the realized return and risk exposure?

**Primary Signals:**
- Final portfolio value
- Net P&L
- Return %
- Portfolio value & drawdown over time

📄 Detailed documentation → [`README_Investment_Simulator.md`](../readme/README_Investment_Simulator.md)

---

## Design Principles

- **Price-first logic:** Signals prioritize price behavior over derived indicators
- **Warehouse-first metrics:** All KPIs are computed upstream (dbt marts)
- **Interpretability over prediction:** Dashboards explain behavior, not forecast outcomes
- **Retail-focused clarity:** Institutional concepts, retail-friendly delivery

---

## Release Artifacts

- Interactive Power BI dashboards
- Exported PDF snapshots for public sharing
- Supporting documentation for each analytical view

---

## Intended Audience

- Retail crypto traders seeking analytical clarity
- Analytics engineers & BI developers
- Data professionals exploring financial analytics design patterns
- Hiring teams evaluating end-to-end data ownership

---

> _Dashboards are opinions. These opinions are backed by data._
