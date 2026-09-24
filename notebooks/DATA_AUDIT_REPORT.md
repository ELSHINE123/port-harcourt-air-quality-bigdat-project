# Niger Delta Environmental Big Data Audit: Phase 0 Baseline Report

## 1. Executive Summary & Exhibition Headline
* **Dataset Scope:** 1,294 continuous daily observations (August 2022 – February 2026).
* **Key Finding:** In over 3.5 years of monitoring in Port Harcourt, **"Good" air quality was recorded on only 3 days (< 0.25%)**. 
* Over **99.7% of days** fell into Moderate, Unhealthy for Sensitive Groups, Unhealthy, or Very Unhealthy categories.

## 2. Data Cleaning & Integrity Summary
* **Missing Value Treatment:** The first 4 initialization records (August 1–4, 2022) were unpopulated by the satellite feed (< 0.31% of data) and were cleanly dropped without introducing synthetic bias.
* **Physical Sanity:** 100% of recorded values across all 11 environmental parameters are non-negative ($\ge 0.00$), confirming high sensor validity.

## 3. Key Environmental Indicators & Port Harcourt Soot Signature
* **Particulate Matter (Black Soot):**
  * $PM_{2.5}$ Mean: $29.16\ \mu\text{g/m}^3$ | Peak: $167.28\ \mu\text{g/m}^3$ (exceeding WHO guidelines by >11x).
  * $PM_{10}$ Mean: $43.21\ \mu\text{g/m}^3$ | Peak: $299.30\ \mu\text{g/m}^3$.
  * US AQI peaked at **203.00** (Emergency "Very Unhealthy" tier).
* **Industrial & Gas Flaring Fingerprint ($SO_2$):**
  * Sulphur Dioxide exhibited **157 spike days (12.1% outliers)** with peaks up to $14.40\ \mu\text{g/m}^3$, closely tied to refinery corridors and active gas flares.
* **Harmattan Seasonal Dynamics (Dust):**
  * Baseline median dust is low ($4.21\ \mu\text{g/m}^3$), but surges up to $313.21\ \mu\text{g/m}^3$ during dry Harmattan periods (November–February).

## 4. Downstream Architectural Implications
* **For PostgreSQL Schema (Phase 2):** High dynamic range requires `NUMERIC(6,2)` precision; partitioning must support location-based querying by Local Government Area (LGA).
* **For Generative ML (Phase 3):** Scikit-Learn's Gaussian Mixture Model must model multimodal distributions to accurately capture both rainy season baselines and Harmattan soot/dust spikes.