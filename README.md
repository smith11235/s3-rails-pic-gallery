# Installation

* Get the code: ```git clone git@github.com:bcwik9/s3-pic-gallery.git```
* install ruby/rails & bundle install
* Rmagick requires some extra libraries: 
  * ```sudo apt-get install imagemagick libmagickwand-dev```
* create s3 bukcet
  * make it a static website
  * add policy
    * ```
       {
         "Version":"2012-10-17",
         "Statement":[{
         "Sid":"PublicReadGetObject",
               "Effect":"Allow",
           "Principal": "*",
             "Action":["s3:GetObject"],
             "Resource":["arn:aws:s3:::example-bucket/*"
             ]
           }
         ]
       }
      ```

* set config/application.yml with 
  * ```
      S3_BUCKET_NAME: bucket-name-with-all-images
      AWS_ACCESS_KEY_ID: lskdjflskjdf
      AWS_SECRET_ACCESS_KEY: lskdjflsdkjflskjdflksjdflsjdlfjs
      AWS_REGION: us-east-1
      TITLE: my vacation gallery
    ```
  
* run ```rake pictures:import``` to download and process them
* run ```rails server```
