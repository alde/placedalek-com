require "sinatra"
require "fastimage"

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
    width, height = width.to_i, height.to_i
    get_exact_match([width, height]).sample
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
end

set :public_folder, PlaceDalek::Media

dalek = PlaceDalek.new

get "/" do
  "Placedalek.com - Place a dalek anywhere"
end

get '/:width/:height' do
  image = dalek.find_picture(params[:width], params[:height])
  return "<img src='/#{image[0]}'/>" unless image.nil?
  return "I am sorry. There is no matching dalek."
end
