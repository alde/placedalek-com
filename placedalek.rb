class PlaceDalek

  Media = File.dirname(__FILE__) + '/media/'
  Pictures = "#{Media}pictures/"

  attr_accessor :daleks

  ##
  # Initialize the PlaceDalek class
  def initialize
    @daleks = {}

    Dir.foreach(Pictures) do |item|
      next if ignore? item
      size = FastImage.size("#{Pictures}#{item}")

      @daleks[size] = [] unless (@daleks.has_key? size)
      @daleks[size] << item
    end
  end

  ##
  # Find a picture.
  def find_picture width, height
    picture, type = get_exact_match [width, height]

    if picture.empty? then
      picture, type = get_scaled_match [width, height], (width.to_f/height.to_f)
    end

    if picture.empty? then
      picture, type = get_cropped_match [width, height]
    end

    [ "#{Pictures}#{picture.sample.first}", type ]
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
      matches = @daleks.reject { |k,v| k != dim }.values
      [ matches, :exact ]
    end

    ##
    # Get a scaled match
    def get_scaled_match dim, scale
      matches = @daleks.reject { |k, v| k != dim and (k[0].to_f / k[1].to_f) != scale }.values
      [ matches, :scale ]
    end

    def get_cropped_match dim
      matches = @daleks.reject { |k,v| k[0] < dim[0] and k[1] < dim[1] }.values
      [ matches, :crop ]
    end
end
