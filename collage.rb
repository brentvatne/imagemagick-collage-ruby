require 'mini_magick'
require_relative './util'

output_width  = 1140
output_height = 500
tile = "x1"
files = Dir[Dir.pwd + "/src/*.jpg"]

# Determine the collage layout to use
if files.length == 1
  width = output_width
  height = output_height
elsif files.length == 2
  width = output_width / 2
  height = output_height
elsif files.length == 3
  width = output_width / 3
  height = output_height
elsif files.length == 4
  width = output_width / 2
  height = output_height / 2
  tile = "2x2"
elsif files.length >= 5
  files.pop if files.length.odd?
  width = output_width / (files.length / 2)
  height = output_height / 2
  tile = "#{files.length/2}x2"
end

# Resize all of the images to make them uniform
files.each do |f|
  image = MiniMagick::Image.open(f)
  resize_to_fill(width, height, image)
  image.format "jpg"
  image.write "tmp/#{f.split('/').last}"
end

# Build up the montage
montage = MiniMagick::Tool::Montage.new
Dir[Dir.pwd + "/tmp/*.jpg"].each { |image| montage << image }
montage << '-mode'
montage << 'Concatenate'
montage << '-background'
montage << 'none'
montage << '-geometry'
montage << "#{width}x#{height}+0+0"
montage << '-tile'
montage << tile
montage << Dir.pwd + "/out/test.jpg"
montage.call
