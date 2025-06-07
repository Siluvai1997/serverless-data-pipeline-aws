import json
import boto3
import pandas as pd
import io
import os

s3 = boto3.client('s3')

def lambda_handler(event, context):
    print("Event:", json.dumps(event))
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    
    response = s3.get_object(Bucket=bucket, Key=key)
    content = response['Body'].read()
    
    df = pd.read_csv(io.BytesIO(content))
    df_clean = df.dropna()
    
    output_key = f"processed/{os.path.basename(key)}"
    buffer = io.StringIO()
    df_clean.to_csv(buffer, index=False)
    
    s3.put_object(Bucket=bucket, Key=output_key, Body=buffer.getvalue())
    
    return {
        'statusCode': 200,
        'body': json.dumps(f'File processed and saved to s3://{bucket}/{output_key}')
    }
    }
