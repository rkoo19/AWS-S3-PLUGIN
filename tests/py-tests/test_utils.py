import os
import pytest
from awsio.python.lib.io.s3.s3dataset import (list_files, file_exists,
                                              get_file_size)
import boto3


def test_wrong_filenames():
    filenames = ['', 'shor', 'not_start_s3', 's3://', 's3:///no_bucket']
    functions = [list_files, file_exists, get_file_size]
    exception = False
    for function in functions:
        for filename in filenames:
            try:
                function(filename)
            except ValueError:
                exception = True
            assert exception
            exception = False


def test_list_files_prefix():
    # default region is us-west-2
    s3_dataset_path = 's3://ydaiming-test-data2/test_0/test'
    result1 = list_files(s3_dataset_path)
    s3 = boto3.resource('s3')
    test_bucket = s3.Bucket('ydaiming-test-data2')
    result2 = []
    for url in test_bucket.objects.filter(Prefix='test_0/test'):
        result2.append('s3://' + url.bucket_name + '/' + url.key)
    assert isinstance(result1, list)
    assert isinstance(result2, list)
    assert len(result1) == len(result2)
    assert result1 == result2


def test_list_files_bucket():
    os.environ['AWS_REGION'] = 'us-west-2'
    # default region is us-west-2
    s3_dataset_path = 's3://ydaiming-test-data2'
    result1 = list_files(s3_dataset_path)
    s3 = boto3.resource('s3')
    test_bucket = s3.Bucket('ydaiming-test-data2')
    result2 = []
    for url in test_bucket.objects.all():
        if url.key[-1] == '/':
            continue
        result2.append('s3://' + url.bucket_name + '/' + url.key)
    assert isinstance(result1, list)
    assert isinstance(result2, list)
    assert result1 == result2
    del os.environ['AWS_REGION']


def test_file_exists():
    """
    There are four kinds of inputs for file_exists:
    1. object_name refers to a file (True)
    2. object_name refers to a folder (False)
    3. bucket_name does not refer to an existing bucket (False)
    4. object_name does not refer to an existing object (False)
    """
    s3_bucket = 's3://ydaiming-test-data2'

    # case 1
    assert file_exists(os.path.join(s3_bucket, 'test_0.JPEG'))

    # case 2
    assert not file_exists(os.path.join(s3_bucket, 'folder_1'))

    # case 3
    assert not file_exists(os.path.join(s3_bucket, 'non_existent_folder'))

    # case 4
    assert not file_exists(os.path.join(s3_bucket, 'test_new_file.JPEG'))


def test_get_file_size():
    bucket_name = 'ydaiming-test-data2'
    object_name = 'test_0.JPEG'

    result1 = get_file_size('s3://' + bucket_name + '/' + object_name)

    s3 = boto3.resource('s3')
    bucket = s3.Bucket(bucket_name)
    result2 = bucket.Object(object_name).content_length

    assert result1 == result2