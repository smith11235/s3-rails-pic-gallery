namespace :pictures do
  require 'fileutils'
  require 'rubygems'
  require 'zip'

  desc 'Zip up compressed images'
  task :zip => :environment do
    generate_zip Rails.root.join('app','assets','images', 'compressed'), Rails.root.join('test.zip')
  end

  def asset_dir
    File.join 'app', 'assets', 'images'
  end

  def thumb_dir
    File.join asset_dir, 'thumbnails'
  end

  def compress_dir
    File.join asset_dir, 'compressed'
  end

  def s3_bucket
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket S3_BUCKET_NAME
  end

  desc "Test code"
  task test: :environment do
    s3 = s3_bucket
    s3.objects.each do |o|
      puts url_for(o.key)
    end
  end

  desc 'Download pictures from a S3 bucket to assets'
  task :import => :environment do
    # important directories
    mkdir_p thumb_dir
    mkdir_p compress_dir

    start_time = Time.now
    # iterate through objects in the bucket and create thumbnails and compress images
    remove_old_files

    pull_new_files

    # generate zip file
    generate_zip compress_dir, Rails.root.join('public', 'all-images.zip')

    # done!
    puts "All done!"
    puts "Total time taken was #{Time.now - start_time} seconds"
  end

  def remove_old_files
    bucket = s3_bucket
    objects = bucket.objects
    num_objects = objects.to_a.size
    puts "Processing #{num_objects} objects from #{S3_BUCKET_NAME}"
    list = objects.collect {|o| o.key}

    [compress_dir, thumb_dir].each do |root_dir|
      Dir.glob(File.join(root_dir, "*")).each do |file|
        name = File.basename(file) 
        unless list.include? name
          puts "Removing: #{file} locally, does not exist in s3"
          FileUtils.rm file
        end
      end
    end
  end

  def pull_new_files
    bucket = s3_bucket

    objects = bucket.objects
    num_objects = objects.to_a.size
    puts "Processing #{num_objects} objects from #{S3_BUCKET_NAME}"
    objects.each_with_index do |o,i|
      # get image filename
      img_name = o.object.key
      next if File.extname(img_name).empty? # skip folder objects (non images)

      # skip files we've already processed        
      if File.exists? File.join(thumb_dir, img_name)
        puts "Skipping #{img_name} since it already exists"
        next
      end

      puts "Processing #{img_name} #{i}/#{num_objects} (#{i.to_f/num_objects*100}%)"

      # create RMagick image in memory
      img = Magick::Image.from_blob(o.object.get.data.body.read).first

      # generate thumbnail and compressed image
      generate_thumbnail File.join(thumb_dir, img_name), img
      generate_compressed File.join(compress_dir, img_name), img
      # TODO: generate compressed and upload back to s3 for speed?
    end
  end

  # download thumbnail to assets
  def generate_thumbnail path, img
    img = img.resize_to_fit 200,200
    img.write path
  end

  # download compressed image to assets
  def generate_compressed path, img
    img.write(path) { self.quality = 70 }
  end

  # zip files up so they can be downloaded all at once
  def generate_zip folder, zip_path
    FileUtils.rm zip_path if File.file? zip_path

    scan_path = File.join(folder, '*')
    puts "Zipping up: #{scan_path}"
    input_files = Dir.glob(scan_path)

    Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
      input_files.each do |file|
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(File.basename(file), file)
      end
    end
  end

end
