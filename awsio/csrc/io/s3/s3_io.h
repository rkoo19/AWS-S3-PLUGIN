//   Original Copyright 2015 The TensorFlow Authors. Licensed under the Apache License, Version 2.0
//   Modifications Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
  
//   Licensed under the Apache License, Version 2.0 (the "License").
//   You may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
  
//       http://www.apache.org/licenses/LICENSE-2.0
  
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

#ifndef AWSIO_S3_IO_H
#define AWSIO_S3_IO_H

#include <aws/core/utils/StringUtils.h>
#include <aws/core/utils/threading/Executor.h>
#include <aws/s3/S3Client.h>
#include <aws/transfer/TransferManager.h>

#include <mutex>

namespace awsio {
// In memory stream implementation
class S3UnderlyingStream : public Aws::IOStream {
   public:
    using Base = Aws::IOStream;

    // provide a customer controlled streambuf, so as to put all transferred
    // data into this in memory buffer.
    S3UnderlyingStream(std::streambuf *buf) : Base(buf) {}

    virtual ~S3UnderlyingStream() = default;
};

class S3Init {
   private:
    std::shared_ptr<Aws::S3::S3Client> s3_client_;
    std::shared_ptr<Aws::Utils::Threading::PooledThreadExecutor> executor_;
    std::shared_ptr<Aws::Transfer::TransferManager> transfer_manager_;
    size_t buffer_size_;
    bool multi_part_download_;

    size_t get_file_size(const std::string &bucket, const std::string &object);

   public:
    S3Init();

    ~S3Init();

    std::mutex initialization_lock_;

    std::shared_ptr<Aws::S3::S3Client> initializeS3Client();
    std::shared_ptr<Aws::Utils::Threading::PooledThreadExecutor>
    initializeExecutor();
    std::shared_ptr<Aws::Transfer::TransferManager> initializeTransferManager();

    void s3_read(const std::string &file_url, std::string *result);
    size_t get_file_size(const std::string &file_url);
    bool file_exists(const std::string &file_url);
    void list_files(const std::string &file_url,
                    std::vector<std::string> *filenames);
};
}  // namespace awsio

#endif  // AWSIO_S3_IO_H
