# iamfu-api-sample
S3に保存した画像をランダムに取得するAPI

コンソール or CLIを使って、s3でterraformのstateを管理する用のバケットを作成する

- なにもかもデフォルト設定でOK
- このバケットだけはterraform自体の管理からは外す

main.tfのbackendの項目にて、bucketの値に先ほど作成したバケットの名前を設定する

- リージョンは東京を使用

```python
terraform {
  backend "s3" {
		# ここを変更
    bucket = "your-bucket-name"
    key    = "terraform.statetf"
    region = "ap-northeast-1"
  }
...
```

variable.sampleをコピーしてvariable.tfを作成し、適切な値を設定する

- aws_access_key：AWSアカウントのアクセスキー
- aws_secret_key：AWSアカウントのシークレットキー
- aws_region：AWSリージョン（デフォルト：東京）
- image_bucket_name：取得する画像の保存場所
- lambda_bucket_name：lambdaソースコードの保存場所

get-image/get_image.pyのBUCKET_NAMEをimage_bucket_nameへ設定した値に変更

```python
import boto3
import random
import base64

# ここを変更
BUCKET_NAME = 'your_image_bucket_name'

def get_all_objects_low(s3, bucket_name):
...
```

システムをデプロイする

- 必要に応じて、terraform fmt、terraform validate、terraform plan等でチェックする
- apply完了後にoutputされるbase_urlを控えておく

```bash
terraform apply
```

作成された画像保存用のバケットに画像をアップロードする

- image_bucket_nameで設定した名前のバケットが作成されているため、そこに保存する
- 画像のフォーマットはpng形式を用いる

デプロイ時に控えておいたbase_urlに「/who」を追加したURLにアクセスすると画像が取得できる
