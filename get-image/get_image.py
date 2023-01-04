import boto3
import random
import base64

BUCKET_NAME = 'your_image_bucket_name'

def get_all_objects_low(s3, bucket_name):
    continuation_token = None
    while True:
        if continuation_token is None:
            res = s3.list_objects_v2(
                Bucket=bucket_name,
            )
        else:
            res = s3.list_objects_v2(
                    Bucket=bucket_name,
                    ContinuationToken=continuation_token
                )

        if res['KeyCount'] == 0:
            break

        for content in res['Contents']:
            yield content

        continuation_token = res.get('NextContinuationToken')
        if continuation_token is None:
            break

def get_img_from_s3():
    s3 = boto3.client('s3')
    bucket_name = BUCKET_NAME

    objs = get_all_objects_low(s3, bucket_name)
    objs_list = list(objs)

    file_path = random.choice(objs_list)['Key']
    responce = s3.get_object(Bucket=bucket_name, Key=file_path)
    body = responce['Body'].read()
    body = base64.b64encode(body)
    return body


def lambda_handler(event, context):
    img = get_img_from_s3()
    return {
        'isBase64Encoded': True,
        'statusCode': 200,
        'headers': {"Content-Type": "image/png"},
        'body': img
    }
