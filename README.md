# 📊 Real-Time Data Streaming Pipeline
## Apache NiFi → Apache Kafka (Dockerized)

A production-ready streaming data pipeline that ingests CSV files and publishes records to Kafka topics in real-time, demonstrating modern data engineering practices with event-driven architecture.

---

## 📑 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Quick Start](#quick-start)
5. [Detailed Setup Guide](#detailed-setup-guide)
6. [NiFi Configuration](#nifi-configuration)
7. [Kafka Setup](#kafka-setup)
8. [Processor Configuration Reference](#processor-configuration-reference)
9. [Testing the Pipeline](#testing-the-pipeline)
10. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

This project implements a real-time streaming ETL pipeline that:
- Monitors a directory for incoming CSV files
- Processes and transforms loan application data
- Filters records based on data quality rules
- Streams clean JSON records to Kafka topics for real-time consumption

**Data Flow:**
```
CSV Files → NiFi (Ingest → Split → Filter → Transform) → Kafka Topics → [Downstream Consumers]
```

### Technology Stack

| Component | Purpose | Why Chosen |
|-----------|---------|------------|
| **Apache NiFi** | Data ingestion & streaming | Visual workflow development, built-in Kafka integration, real-time processing |
| **Apache Kafka** | Message broker & streaming platform | Scalable event streaming, decoupled architecture, real-time data distribution |
| **Docker** | Containerization | Reproducible environment, easy deployment, service orchestration |

### Dataset

The pipeline processes **financial risk assessment data** containing:
- **Demographics**: Age, Income
- **Credit Metrics**: Credit Score, Loan Amount
- **Loan Details**: Purpose, Employment Status
- **Risk Indicators**: Payment History, Risk Rating

**Output**: Standardized JSON records with snake_case field names, filtered for data quality (non-null income and credit score).

---

## 🏗️ Architecture

```
┌─────────────────┐      ┌──────────────────────────────────────┐      ┌─────────────────┐
│   CSV Files     │      │          Apache NiFi                 │      │  Apache Kafka   │
│  (./data/input) │ ───► │  GetFile → Split → Filter → Format   │ ───► │  (Topic: *)     │
└─────────────────┘      └──────────────────────────────────────┘      └─────────────────┘
                                                                                 │
                                                                                 ▼
                                                                        ┌─────────────────┐
                                                                        │   Downstream    │
                                                                        │   Consumers     │
                                                                        └─────────────────┘
```

**Processing Stages:**
1. **GetFile**: Monitors `/data/input/` for new CSV files
2. **SplitRecord**: Splits CSV into individual records
3. **QueryRecord**: Applies SQL-based filtering and field selection
4. **PublishKafkaRecord_2_6**: Publishes JSON records to Kafka topic
5. **LogMessage**: Captures processing logs and errors

---

## ✅ Prerequisites

Before starting, ensure you have:

- **Docker Desktop** (or Docker Engine) v20.10+
- **Docker Compose** v2.0+
- **Minimum 4GB RAM** allocated to Docker
- **10GB free disk space**
- **Stable internet connection** (for downloading images)

**Verify installations:**
```bash
docker --version
docker compose version
```

---

## 🚀 Quick Start

### Step 1: Clone Repository
```bash
git clone https://github.com/yourusername/nifi-kafka-streaming.git
cd nifi-kafka-streaming
```

### Step 2: Start Services
```bash
docker compose up -d
```

⏱️ **Expected Startup Time:** 3-5 minutes

### Step 3: Verify Services
```bash
docker compose ps
```

All services should show status as `Up`.

### Step 4: Access NiFi UI
- **URL**: http://localhost:8080/nifi
- **Wait**: 2-3 minutes for NiFi to fully initialize

---

## 📋 Detailed Setup Guide

### 1. Project Structure

```
nifi-kafka/
│
├── docker-compose.yaml           # Service orchestration
├── nifi-templates/
│   └── CSV-TO-INGESTION-2.xml   # Pre-configured NiFi flow
│
├── data/
│   └── input/                   # Place CSV files here
│       └── financial_risk_assessment.csv
│
└── README.md
```

---

### 2. Docker Compose Configuration

The `docker-compose.yaml` defines three services:

```yaml
services:
  zookeeper:    # Kafka dependency
  kafka:        # Message broker
  nifi:         # Data processing engine
```

**Network**: All services communicate via `nifi-kafka-net` bridge network.

**Volumes**:
- `./data/input:/data/input` - CSV input directory
- `nifi-data:/opt/nifi/nifi-current` - NiFi persistent storage

---

### 3. Start the Environment

```bash
# Start all services in detached mode
docker compose up -d

# View logs (optional)
docker compose logs -f nifi
docker compose logs -f kafka

# Check service health
docker compose ps
```

**Expected Output:**
```
NAME                  STATUS
nifi-kafka-nifi-1     Up (healthy)
nifi-kafka-kafka-1    Up
nifi-kafka-zookeeper-1 Up
```

---

## ⚙️ NiFi Configuration

### Option A: Import Pre-configured Template (Recommended)

**Step 1: Access NiFi UI**
- Navigate to http://localhost:8080/nifi
- Wait for initialization (look for blank canvas)

**Step 2: Upload Template**
1. Click the **Upload Template** icon (📤) in the toolbar
2. Click **"Select Template"**
3. Navigate to `nifi-templates/CSV-TO-INGESTION-2.xml`
4. Click **"Upload"**

**Step 3: Add Template to Canvas**
1. Drag the **Template** icon (📄) from toolbar onto canvas
2. Select **"CSV-TO-INGESTION-2"** from dropdown
3. Click **"Add"**

**Step 4: Configure Controller Services**
1. Right-click on canvas → **"Configure"**
2. Go to **"Controller Services"** tab
3. Enable the following services (click ⚡ icon):
   - **CSVReader**
   - **JsonRecordSetWriter**

**Step 5: Start the Flow**
1. Select all processors (Ctrl+A / Cmd+A)
2. Right-click → **"Start"**

---

### Option B: Manual Configuration

If building the flow manually, see [Processor Configuration Reference](#processor-configuration-reference) section below.

---

## 📡 Kafka Setup

### 1. Create Kafka Topic

```bash
# Access Kafka container
docker exec -it nifi-kafka-kafka-1 bash

# Create topic
kafka-topics --create \
  --topic financial_risk \
  --bootstrap-server localhost:9092 \
  --partitions 1 \
  --replication-factor 1

# Verify topic creation
kafka-topics --list --bootstrap-server localhost:9092
```

**Expected Output:**
```
financial_risk
```

---

### 2. Test Kafka Consumer

Monitor incoming messages in real-time:

```bash
kafka-console-consumer \
  --topic financial_risk \
  --bootstrap-server localhost:9092 \
  --from-beginning
```

**Sample Output:**
```json
{"age":49,"income":72799.0,"credit_score":688,"loan_amount":45713.0,"loan_purpose":"Business","employment_status":"Unemployed","payment_history":"Poor","risk_rating":"Low"}
{"age":57,"income":55687.0,"credit_score":690,"loan_amount":33835.0,"loan_purpose":"Auto","employment_status":"Employed","payment_history":"Fair","risk_rating":"Medium"}
```

---

### 3. Add Sample Data

Place your CSV file in the monitored directory:

```bash
# Copy sample CSV
cp financial_risk_assessment.csv data/input/

# Or create a test file
cat > data/input/test.csv << EOF
Age,Gender,Education Level,Marital Status,Income,Credit Score,Loan Amount,Loan Purpose,Employment Status,Years at Current Job,Payment History,Debt-to-Income Ratio,Assets Value,Number of Dependents,City,State,Country,Previous Defaults,Marital Status Change,Risk Rating
49,Male,PhD,Divorced,72799.0,688.0,45713.0,Business,Unemployed,19,Poor,0.15,120228.0,0.0,City1,AS,Cyprus,2.0,2,Low
EOF
```

NiFi will automatically detect and process the file.

---

## 🔧 Processor Configuration Reference

### 1️⃣ GetFile Processor

**Purpose:** Monitors directory and retrieves CSV files

| Property | Value | Description |
|----------|-------|-------------|
| **Input Directory** | `/data/input` | Directory to monitor |
| **File Filter** | `financial_risk_assessment.csv` | Specific filename to process |
| **Keep Source File** | `false` | Delete file after processing |
| **Recurse Subdirectories** | `false` | Don't scan subdirectories |
| **Polling Interval** | `10 sec` | How often to check for files |
| **Batch Size** | `10` | Max files per poll |

**Relationships:**
- `success` → SplitRecord

---

### 2️⃣ SplitRecord Processor

**Purpose:** Splits CSV file into individual records

| Property | Value | Description |
|----------|-------|-------------|
| **Record Reader** | CSVReader | Controller service to parse CSV |
| **Record Writer** | JsonRecordSetWriter | Output format |
| **Records Per Split** | `1` | One record per FlowFile |

**Controller Services:**

**CSVReader:**
| Property | Value |
|----------|-------|
| **Schema Access Strategy** | Infer Schema |
| **Treat First Line as Header** | `true` |
| **CSV Format** | Custom Format |
| **Skip Header Line** | `false` |

**Relationships:**
- `splits` → QueryRecord
- `original` → LogMessage (for tracking)
- `failure` → LogMessage

---

### 3️⃣ QueryRecord Processor

**Purpose:** Filters and transforms records using SQL

| Property | Value | Description |
|----------|-------|-------------|
| **Record Reader** | CSVReader | Input format |
| **Record Writer** | JsonRecordSetWriter | Output format |
| **Include Zero Record FlowFiles** | `false` | Drop empty results |

**SQL Query:**
```sql
SELECT 
    Age AS age,
    Income AS income,
    "Credit Score" AS credit_score,
    "Loan Amount" AS loan_amount,
    "Loan Purpose" AS loan_purpose,
    "Employment Status" AS employment_status,
    "Payment History" AS payment_history,
    "Risk Rating" AS risk_rating
FROM FLOWFILE
WHERE Income IS NOT NULL 
  AND Credit_Score IS NOT NULL
```

**What it does:**
- Selects 8 core fields
- Renames fields to snake_case
- Filters out records with null income or credit score

**JsonRecordSetWriter:**
| Property | Value |
|----------|-------|
| **Schema Write Strategy** | Do Not Write Schema |
| **Schema Access Strategy** | Inherit Record Schema |
| **Pretty Print JSON** | `false` |

**Relationships:**
- `success` → PublishKafkaRecord_2_6
- `failure` → LogMessage

---

### 4️⃣ PublishKafkaRecord_2_6 Processor

**Purpose:** Publishes records to Kafka topic

| Property | Value | Description |
|----------|-------|-------------|
| **Kafka Brokers** | `kafka:9092` | Kafka server address |
| **Topic Name** | `financial_risk` | Target Kafka topic |
| **Record Reader** | JsonRecordSetWriter | Input format |
| **Record Writer** | JsonRecordSetWriter | Output format |
| **Use Transactions** | `false` | Disable Kafka transactions |
| **Delivery Guarantee** | Best Effort | Don't wait for acks |
| **Max Request Size** | `1 MB` | Maximum message size |

**Relationships:**
- `success` → LogMessage
- `failure` → LogMessage

---

### 5️⃣ LogMessage Processors

**Purpose:** Capture processing logs and errors

| Property | Value | Description |
|----------|-------|-------------|
| **Log Level** | `info` | Logging severity |
| **Log Prefix** | `[Pipeline Step]` | Custom identifier |

**Placement:**
- After SplitRecord (original relationship)
- After QueryRecord (failure relationship)
- After PublishKafkaRecord (success/failure relationships)

**Auto-terminate relationships:** All (since it's a terminal processor)

---

## 🧪 Testing the Pipeline

### End-to-End Test

**Step 1: Verify NiFi Flow is Running**
```bash
# Check NiFi UI - all processors should be green/running
```

**Step 2: Start Kafka Consumer**
```bash
docker exec -it nifi-kafka-kafka-1 \
  kafka-console-consumer \
  --topic financial_risk \
  --bootstrap-server localhost:9092 \
  --from-beginning
```

**Step 3: Add Test CSV File**
```bash
cp financial_risk_assessment.csv data/input/
```

**Step 4: Observe Results**

In Kafka consumer terminal, you should see JSON records streaming:
```json
{"age":49,"income":72799.0,"credit_score":688,...}
{"age":57,"income":55687.0,"credit_score":690,...}
```

**Step 5: Check Processing Stats**

In NiFi UI:
- GetFile: Should show files processed
- SplitRecord: Shows total records split
- QueryRecord: Shows filtered record count
- PublishKafkaRecord: Shows messages published

---

### Verify Data Quality

Records with null income or credit score should be filtered out:

```bash
# Count total records in original CSV
wc -l data/input/financial_risk_assessment.csv

# Count messages in Kafka (should be less due to filtering)
kafka-console-consumer \
  --topic financial_risk \
  --bootstrap-server localhost:9092 \
  --from-beginning | wc -l
```

---

## 🔍 Troubleshooting

### Common Issues

**Issue: NiFi UI not accessible**
```bash
# Check NiFi logs
docker logs nifi-kafka-nifi-1

# Wait for: "NiFi has started. The UI is available"
# Can take 2-3 minutes on first startup
```

---

**Issue: Kafka topic not found**
```bash
# List existing topics
docker exec -it nifi-kafka-kafka-1 \
  kafka-topics --list --bootstrap-server localhost:9092

# Recreate topic if missing
docker exec -it nifi-kafka-kafka-1 \
  kafka-topics --create --topic financial_risk \
  --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
```

---

**Issue: No data flowing through NiFi**

1. **Check GetFile processor:**
   - Right-click → View Configuration → Properties
   - Verify Input Directory matches mounted volume: `/data/input`
   - Check File Filter matches your CSV filename

2. **Check file permissions:**
   ```bash
   # Ensure NiFi can read files
   chmod -R 755 data/input/
   ```

3. **View processor logs:**
   - Right-click processor → View Status History
   - Check for error messages

---

**Issue: PublishKafkaRecord fails**

**Error:** "Connection refused to kafka:9092"

**Solution:**
```bash
# Verify Kafka is running
docker compose ps kafka

# Check Kafka logs
docker logs nifi-kafka-kafka-1

# Restart Kafka if needed
docker compose restart kafka
```

---

**Issue: QueryRecord SQL errors**

**Error:** "Lexical error at line X, column Y"

**Solution:** Ensure column names use underscores (not spaces):
- ✅ `credit_score`
- ❌ `Credit Score`

Check CSVReader normalizes column names by replacing spaces with underscores.

---

### Viewing Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f nifi
docker compose logs -f kafka

# Last 100 lines
docker compose logs --tail=100 nifi
```

---

### Resetting the Environment

```bash
# Stop all services
docker compose down

# Remove all data (CAUTION: deletes volumes)
docker compose down -v

# Rebuild and restart
docker compose up -d --build
```

---

## 📊 Monitoring & Validation

### NiFi Metrics

Access NiFi UI and check:
- **Flow Statistics**: View data rates (MB/sec, records/sec)
- **Processor Status**: Green = running, Red = error
- **Queue Counts**: Shows data buffering between processors
- **Provenance**: Click any processor → View Data Provenance for lineage

### Kafka Metrics

```bash
# Check topic details
docker exec -it nifi-kafka-kafka-1 \
  kafka-topics --describe --topic financial_risk \
  --bootstrap-server localhost:9092

# Consumer group lag (if you have consumer groups)
kafka-consumer-groups --bootstrap-server localhost:9092 \
  --group your-consumer-group --describe
```

---

## 🎓 Learning Outcomes

This project demonstrates:

✅ **Real-time data streaming** with Apache Kafka  
✅ **Event-driven architecture** for decoupled systems  
✅ **Visual data pipeline development** with Apache NiFi  
✅ **SQL-based data transformation** in streaming context  
✅ **Data quality enforcement** at ingestion layer  
✅ **Containerized microservices** with Docker Compose  
✅ **Schema evolution** handling (CSV → JSON transformation)  

---

## 📝 Next Steps

After running the pipeline, consider:

1. **Add Kafka Consumers:**
   - Build Python/Java consumer applications
   - Integrate with analytics dashboards
   - Feed data to ML models

2. **Scale the Pipeline:**
   - Increase Kafka partitions for parallel processing
   - Add NiFi cluster nodes
   - Implement backpressure handling

3. **Enhance Data Quality:**
   - Add more SQL validation rules in QueryRecord
   - Implement schema validation
   - Add data enrichment processors

4. **Production Hardening:**
   - Enable Kafka SSL/TLS encryption
   - Implement NiFi authentication
   - Add monitoring with Prometheus/Grafana
   - Set up alerting for pipeline failures

---

## 🤝 Contributing

Found an issue or want to improve the pipeline? 

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

## 📧 Support

For issues or questions:
- **GitHub Issues**: [Create an issue](https://github.com/crypticwisdom/nifi-kafka-streaming/issues)
- **Email**: crypticwisdom84@gmail.com

---

**Built with ❤️ to demonstrate modern streaming data engineering**

**Tech Stack**: Apache NiFi • Apache Kafka • Docker • SQL