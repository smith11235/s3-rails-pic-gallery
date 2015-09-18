class HomeController < ApplicationController
  ASSETS_DIR = File.join 'app', 'assets', 'images'

  def index
    # iterate through pictures and map thumbnails to compressed images
    @pics = {}
    Dir.glob(File.join(ASSETS_DIR, 'thumbnails', '*')).each do |pic|
      basename = File.basename pic
      @pics[File.join('thumbnails', basename)] = root_path + basename
    end
  end

  def show
    # TODO: s3 directly: 
    @quality = params[:quality] || "compressed"
    @pic_name = params[:pic_name]
    @format = params[:format]
    @pic = if @quality == "compressed"
             File.join('compressed', "#{@pic_name}.#{@format}")
           else
             s3_url_for("#{@pic_name}.#{@format}")
           end
  end
end
