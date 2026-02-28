import uuid
import boto3
from django.conf import settings


def get_s3_client():
    return boto3.client(
        's3',
        aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
        aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
        region_name=settings.AWS_S3_REGION_NAME,
    )


def generate_presigned_upload_url(s3_key: str, content_type: str) -> str:
    """Generate a presigned PUT URL for direct upload to S3."""
    client = get_s3_client()
    url = client.generate_presigned_url(
        'put_object',
        Params={
            'Bucket': settings.AWS_STORAGE_BUCKET_NAME,
            'Key': s3_key,
            'ContentType': content_type,
        },
        ExpiresIn=settings.AWS_S3_PRESIGNED_URL_EXPIRY,
    )
    return url


def generate_presigned_download_url(s3_key: str, expiry: int = 3600) -> str:
    """Generate a presigned GET URL for downloading from S3."""
    client = get_s3_client()
    url = client.generate_presigned_url(
        'get_object',
        Params={
            'Bucket': settings.AWS_STORAGE_BUCKET_NAME,
            'Key': s3_key,
        },
        ExpiresIn=expiry,
    )
    return url


def build_wardrobe_s3_key(user_id: str, item_id: str, filename: str) -> str:
    """Build S3 key for wardrobe item image."""
    ext = filename.rsplit('.', 1)[-1] if '.' in filename else 'jpg'
    return f'users/{user_id}/wardrobe/{item_id}/original.{ext}'


def build_profile_s3_key(user_id: str, photo_type: str, filename: str) -> str:
    """Build S3 key for profile photos."""
    ext = filename.rsplit('.', 1)[-1] if '.' in filename else 'jpg'
    return f'users/{user_id}/profile/{photo_type}.{ext}'


def build_tryon_person_s3_key(user_id: str, filename: str) -> str:
    """Build S3 key for try-on person image."""
    ext = filename.rsplit('.', 1)[-1] if '.' in filename else 'jpg'
    unique = uuid.uuid4().hex[:8]
    return f'users/{user_id}/profile/body_{unique}.{ext}'


def build_tryon_result_s3_key(user_id: str, tryon_id: str) -> str:
    """Build S3 key for try-on result image."""
    return f'users/{user_id}/tryon_results/{tryon_id}.jpg'


def download_from_s3(s3_key: str) -> bytes:
    """Download file from S3 and return bytes."""
    client = get_s3_client()
    response = client.get_object(
        Bucket=settings.AWS_STORAGE_BUCKET_NAME,
        Key=s3_key,
    )
    return response['Body'].read()


def upload_to_s3(s3_key: str, data: bytes, content_type: str = 'image/jpeg'):
    """Upload bytes to S3."""
    client = get_s3_client()
    client.put_object(
        Bucket=settings.AWS_STORAGE_BUCKET_NAME,
        Key=s3_key,
        Body=data,
        ContentType=content_type,
    )
