import pandas as pd
from sqlalchemy import create_engine

file = r"S:\Projects\GITHUB\Data Analytics\Projects\Supply_Chain_Management and Logistic_Analysis\Dataset\Supply_Chain_Procurement_Cleaned.xlsx"

engine = create_engine(
    "mysql+pymysql://root:root@localhost/Supply_chain"
)

sheets = pd.ExcelFile(file).sheet_names

for sheet in sheets:
    df = pd.read_excel(file, sheet_name=sheet)

    table_name = sheet.lower()

    df.to_sql(
        table_name,
        engine,
        if_exists="replace",
        index=False
    )

    print(f"Imported: {sheet} -> {table_name}")