# Data Warehouse Layer Architecture

| | Bronze Layer | Silver Layer | Gold Layer |
|---|---|---|---|
| **Definition** | Raw, unprocessed data as-is from sources | Clean & standardised data | Business-ready data |
| **Objective** | Traceability & debugging | Prepare data for analysis (intermediate layer) | Provide data for reporting & analytics |
| **Object Type** | Tables | Tables | Views |
| **Load Method** | Full Load (Truncate & Insert) | Full Load (Truncate & Insert) | None |
| **Data Transformation** | None (as-is) | Data Cleaning, Standardization, Normalisation, Enrichment, Derived Columns | Data Integration, Aggregation, Business Logic & Rules |
| **Data Modelling** | None (as-is) | None (as-is) | Star Schema, Aggregated Objects, Flat Tables |
| **Target Audience** | Data Engineers | Data Analysts & Data Engineers | Data Analysts & Business Users |

---

## Bronze Layer — Source System Interview Guide

When creating the Bronze Layer, interviewing source system experts is beneficial for understanding business context, architecture, and extraction approach.

### Business Context & Ownership
- Who owns the data?
- What business process does it support?
- Can you provide system & data documentation?
- Can you provide the data model & data catalog?

### Architecture & Technology Stack
- How is the data stored? (e.g. SQL Server, Azure, etc.)
- What are the integration capabilities? (e.g. API, Kafka, File Extract, etc.)

### Extract & Load
- Is loading incremental or full?
- What is the data scope & historical data need?
- What is the expected size of the extracts?
- Are there any data volume limitations?
- How can we avoid impacting the source system's performance?
- What authentication & authorisation is required? (e.g. tokens, SSH keys, VPN, etc.)
