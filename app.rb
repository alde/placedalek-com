require "sinatra"
require "fastimage"
require "mini_magick"

class PlaceDalek

  Media = File.dirname(__FILE__) + '/media/'

  attr_accessor :daleks

  ##
  # Initialize the PlaceDalek class
  def initialize
    @daleks = {}
    Dir.foreach(Media) do |item|
      next if ignore? item
      size = FastImage.size("#{Media}#{item}")

      @daleks[size] = [] unless (@daleks.has_key? size)
      @daleks[size] << item
    end
  end

  ##
  # Find a picture.
  def find_picture width, height
    picture = get_exact_match([width, height])

    if picture.empty? then
      picture = get_scaled_match [width, height], (width.to_f/height.to_f)
    end

    "./media/#{picture.sample.first}"
  end

  private
    ##
    # Should a file be ignored?
    def ignore? item
      ['.', '..'].include? item
    end

    ##
    # Get an exact match
    def get_exact_match dim
      @daleks.reject {|k,v| k != dim}.values
    end

    ##
    # Get a scaled match
    def get_scaled_match dim, scale
      @daleks.reject do |k, v|
        k != dim and (k[0].to_f/k[1].to_f) != scale
      end.values
    end
end

set :public_folder, PlaceDalek::Media

dalek = PlaceDalek.new

get "/" do
  "Placedalek.com - Place a dalek anywhere"
end

get '/:width/:height' do
  width, height = params[:width].to_i, params[:height].to_i

  image = dalek.find_picture(width, height)

  resized = MiniMagick::Image.open(image)
  resized.combine_options do |c|
    c.filter 'box'
    c.resize "#{width}x#{height}"
  end
  send_file(
    resized.path,
    {
      filename: "dalek_#{width}_#{height}",
      type: "image/#{FastImage.type("./media/#{image}")}"
    }
  )
end
