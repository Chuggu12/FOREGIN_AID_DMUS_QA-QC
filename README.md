# 🌍 Foreign Aid & Economic Relevance Panel Dataset for DEA

### A Reproducible, QA-Driven Pipeline for Measuring Foreign Aid Efficiency

---

## 📌 Project Overview

This repository contains a **fully reproducible R pipeline** to construct, standardize, validate, and quality-audit a **multi-country panel dataset** for **Data Envelopment Analysis (DEA)**.

The dataset evaluates **foreign aid efficiency** across **36 African countries (DMUs)** over time by transforming raw, high-dimensional development data into a **DEA-ready panel structure**, followed by **extensive missing-data diagnostics**.

---

## 🎯 Core Objective

To generate a **balanced, transparent, and analytically defensible panel dataset** for measuring **foreign aid efficiency and economic performance** using DEA.

---

## 🧠 Conceptual Motivation

Foreign aid effectiveness **cannot be evaluated directly** using raw macroeconomic data.  
DEA requires:

- Clearly defined **Decision Making Units (DMUs)**
- Consistent **inputs and outputs**
- Clean, **well-structured panel data**
- Explicit handling of **missingness and coverage bias**

This pipeline ensures **methodological integrity** before efficiency estimation begins.

---

## 🧩 What the Code Does (Pipeline Overview)

### 1️⃣ Raw Data Ingestion
- Reads multi-sheet Excel files
- Handles datasets with **~44 indicators**
- Supports both:
  - Wide format (years as columns)
  - Long DEA-style indicator datasets

---

### 2️⃣ DMU Selection (36 Countries)

The analysis focuses on **36 African countries**, selected based on **regional coverage and data availability**.

#### 🌍 Selected DMUs

**West Africa (15)**  
Benin, Burkina Faso, Cote d'Ivoire, Gambia (The), Ghana, Guinea, Guinea-Bissau, Liberia, Mali, Mauritania, Niger, Nigeria, Senegal, Sierra Leone, Togo

**East Africa (13)**  
Burundi, Djibouti, Ethiopia, Kenya, Madagascar, Malawi, Mauritius, Mozambique, Rwanda, Tanzania, Uganda, Zambia, Zimbabwe

**Central Africa (3)**  
Cameroon, Chad, Congo (Rep.)

**Southern Africa (5)**  
Botswana, Eswatini, Lesotho, Namibia, South Africa

➡️ These **36 countries act as DMUs** in the DEA framework.

---

## 🔄 Data Restructuring Logic (Key Step)

The raw dataset initially contains:
- ~44 indicators
- Mixed formats
- Years spread across columns

### The pipeline converts this into:

#### Long DEA-Compatible Format

YEAR | COUNTRY | INDICATOR | VALUE

#### Final Panel Format

YEAR | COUNTRY | Indicator_1 | Indicator_2 | Indicator_3 | ... | Indicator_n

✔ This ensures:
- Time consistency  
- Cross-country comparability  
- Direct DEA compatibility  

---

## 🧪 Panel Standardization

- Year variables converted to numeric
- Country names harmonized
- Observations ordered as:

- Invalid and structurally missing rows removed
- Both **raw** and **cleaned** panels preserved

---

## 🔍 Data Balancing & QA-QC (Major Strength)

This repository performs **deep missing-data diagnostics** before DEA.

### Coverage Analysis Includes:

### 📊 Indicator-wise
- Missing vs non-missing counts
- Coverage percentage

### 🌍 Country-wise
- Total missing observations
- Identification of weakest DMUs

### 📅 Year-wise
- NA density per year
- Detection of structurally weak time periods

---

## 🧠 Advanced Diagnostics

- Country × Indicator missingness matrices
- Indicator × Year availability tables
- Binary missingness matrices
- Heatmaps for visual inspection

---

## 📈 Visual QA Tools

Using `ggplot2` and `naniar`:
- Missing data % by year
- Missing data % by country
- Missing data % by indicator
- Heatmaps for coverage diagnostics

These visuals **prevent silent bias** before DEA estimation.

---

## 📦 Outputs Generated

| File | Description |
|----|----|
| `ODA_FINAL_Countries.xlsx` | Filtered foreign aid data |
| `FINAL_PANEL_DATA.xlsx` | DEA-ready panel dataset |
| QA tables | Missingness diagnostics |
| Visual plots | Coverage & balance checks |

---

## 🎯 Final Use Case: DEA

- Each country is treated as a **DMU**
- Enables:
- Foreign aid efficiency estimation
- Cross-country benchmarking
- Temporal efficiency comparison
- Robust policy-relevant inference

---

## 🛠 Tech Stack

- **R**
- `dplyr`, `tidyr`, `readxl`, `writexl`
- `ggplot2`, `naniar`

---


