# Massive Data Fundamental: NYC Yellow Taxi Demand Prediction
> To reproduce the full results, please download the monthly `Yellow Taxi Trip Records` from [NYC TLC](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page) for the period August 2024 to January 2025.

View our [project website](https://www.notion.so/Massive-Data-Fundamental-Final-Project-NYC-Yellow-Taxi-Demand-Prediction-1dedc0943b7b80ff890cc49bf38c3476?pvs=4) for full analysis, visualizations, and conclusions.

## Description
A Massive Data Fundamental project that predicts yellow taxi demand across Manhattan using NYC TLC Trip Record Data (Aug 2024–Jan 2025). The model is designed to support **real-time dispatch**, **urban mobility planning**, and **transportation policy** by identifying high-demand zones by location and time of day to optimize driver deployment and improve operational efficiency.


## File Structure
The repository is organized as follows:
```
.
├── README.md                        # Project overview and instructions
├── Code/                            # Code and scripts
│   ├── EDA.ipynb                    # Exploratory Data Analysis notebook
│   ├── ML_Cloud.ipynb               # Machine learning model training and cloud integration
│   └── BigQuery_Preprocessing.sql   # SQL script for preprocessing data in BigQuery
├── Data/                            # Datasets used in the analysis
│   └── taxi_zones/                  # Shapefiles for NYC taxi zone boundaries
│      ├── taxi_zones.shp            # Main shapefile
│      ├── taxi_zones.dbf            # Attribute table
│      └── ...
└── Visualization/                   # Generated figures and result plots
    ├── 01features_target.png
    ├── 02Model_Evaluation.png
    └── ...
```

## Replication Steps

1. **Download Raw Data**
      - Visit the [NYC TLC Trip Record Data page](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page)
      - Download yellow taxi data from **August 2024 to January 2025**

2. **Set Up Cloud Storage**
      - Create a Google Cloud Bucket and upload the raw CSV files
      - Adjust any file paths in `BigQuery_Preprocessing.sql` as needed

3. **Run Preprocessing**
      - Use `BigQuery_Preprocessing.sql` to clean and prepare the data in Google BigQuery

4.	**Run EDA Locally**
      - Use `EDA.ipynb` to explore trends and patterns

5.	**Train and Evaluate Models in the Cloud**
      - Run `ML_Cloud.ipynb` in a cloud-based Jupyter environment (e.g., Vertex AI)
      - This notebook trains and evaluates the machine learning models using cleaned data

6. **Review Visualizations**
      - View final figures in the `Visualization/` folder
      - Key outputs: demand trends, model performance, geospatial zone analysis
---

## Outputs

- `EDA.ipynb`: EDA on temporal and spatial patterns
- `ML_Cloud.ipynb`: Model training using XGBoost, LightGBM, and others
- `Visualization/*.png`: Final figures for presentation and reporting
- `BigQuery_Preprocessing.sql`: SQL script to clean raw TLC data in BigQuery
