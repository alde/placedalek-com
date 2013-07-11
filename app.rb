require "sinatra/base"
require "fastimage"
require "mini_magick"
require "./placedalek"
require "slim"

class Site < Sinatra::Base
  set :public_folder, PlaceDalek::Media
  set :views, File.dirname(__FILE__) + '/templates'
  set :slim, :pretty => true

  get "/" do
    slim :index
  end

  get '/:width/:height' do
    dalek = PlaceDalek.new

    width, height = params[:width].to_i, params[:height].to_i
    image, type = dalek.find_picture(width, height)
    dim = "#{width}x#{height}"
    response_image = MiniMagick::Image.open(image)

    unless type == :exact then
      response_image.combine_options do |c|
        c.filter 'box'
        if type == :crop then
          c.resize dim + "^^"
          c.gravity "Center"
          c.extent dim
        else
          c.resize dim
        end
      end
    end

    send_file(
      response_image.path,
      {
        filename: "dalek_#{dim}",
        type: "image/#{FastImage.type("./media/#{image}")}"
      }
    )
  end
end

Site.run!
