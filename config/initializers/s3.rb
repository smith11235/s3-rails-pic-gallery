S3_BUCKET_NAME = ENV['S3_BUCKET_NAME'] || raise('please set environment var S3_BUCKET_NAME')

def s3_url_for(img)
  File.join("//#{S3_BUCKET_NAME}.s3-website-us-east-1.amazonaws.com", img)
end

