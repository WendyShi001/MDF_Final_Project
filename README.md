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
      - Download six monthly yellow taxi data from **August 2024 to January 2025**

2. **Set Up Cloud Storage**
      - Create a Google Cloud Bucket and upload the six raw files
      - Connect the Cloud Storage with BigQuery

3. **Run Preprocessing**
      - Use `BigQuery_Preprocessing.sql` to clean and prepare the data in Google BigQuery
      - The preprocessing includes:
        - Created hourly panel for Manhattan zones
        - Generated hourly timestamps for the target date range
        - Performed Cartesian join to create full zone-time grid
        - Aggregated trip counts by hour and location
        - Added holiday indicators
        - Extracted time-based features (hour, weekday, weekend)
        - Merged trip data with the complete hourly grid
        - Created lag features (1h, 24h, 168h)
        - Computed rolling 3-hour average
        - Generated zone-level dummy variables
        - Created final feature table for modeling
      - Saved the processed data locally as `Processed.csv` to create data visualization and geospatial analysis
        - This data is not included in this git repo due to file size

4.	**Run EDA Locally**
      - Use `EDA.ipynb` to explore trends and patterns

5.	**Train and Evaluate Models in the Cloud** 
      - Enable **Vertex AI** API and create an instance with default settings in the workbench.
      - Open **Jupyter Lab** and upload `ML_Cloud.ipynb` to run machine learning code
        - The notebook trains and evaluates the machine learning models using cleaned data

7. **Review Visualizations**
      - View final figures in the `Visualization/` folder
      - Key outputs: demand trends, model performance, geospatial zone analysis
---

## Outputs

- `EDA.ipynb`: EDA on temporal and spatial patterns
- `ML_Cloud.ipynb`: Model training using XGBoost, LightGBM, and others
- `Visualization/*.png`: Final figures for presentation and reporting
- `BigQuery_Preprocessing.sql`: SQL script to clean raw TLC data in BigQuery

## Reference
Gangrade, A., Pratyush, P., & Hajela, G. (2022). Taxi-demand forecasting using dynamic spatiotemporal analysis. ETRI Journal, 44(4), 624–640. https://doi.org/10.4218/etrij.2021-0123​ 

New York City Taxi & Limousine Commission. (n.d.). TLC trip record data. NYC.gov. Retrieved May 8, 2025, from https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page
