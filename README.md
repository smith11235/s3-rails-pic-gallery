# Installation

* Get the code: ```git clone git@github.com:bcwik9/s3-pic-gallery.git```
* install ruby/rails & bundle install
* Rmagick requires some extra libraries: 
  * ```sudo apt-get install imagemagick libmagickwand-dev```
* set config/application.yml with 
  * ```S3_BUCKET_NAME: bucket-name-with-all-images```
* set up AWS CLI, and credentials
* run ```rake pictures:import``` to download and process them
* run ```rails server```
