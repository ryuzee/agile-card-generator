require 'prawn'
require 'yaml'
require 'net/http'
require 'uri'
require "digest/md5"

class Card
  WIDTH = 258
  HEIGHT = 156
  TEXT_BOX_HEIGHT = 40
  FONT = './fonts/japanese_font.ttf'

  def initialize()
    @page_count = 0
    @pdf = Prawn::Document.new(
      :page_size => [HEIGHT, WIDTH],
      :page_layout => :landscape,
      :top_margin => 0,
      :bottom_margin => 0,
      :left_margin => 0,
      :right_margin => 0)
  end

  def save_image(url)
    filename = self.image_path(url)
    open(filename, 'wb') do |file|
      file.puts Net::HTTP.get_response(URI.parse(url)).body
    end
  end

  def image_path(url)
    return "./images/" + Digest::MD5.hexdigest(url) + ".jpg"
  end

  def write(v)
    @pdf.start_new_page unless @page_count == 0
    @page_count += 1

    self.save_image(v["image"]) unless File.exist?(self.image_path(v["image"]))
    @pdf.image self.image_path(v["image"]), :width => WIDTH, :height => HEIGHT

    @pdf.font_size 12
    @pdf.fill_color 'cccccc'
    @pdf.transparent(0.5) do
      @pdf.fill_rectangle [0 ,(HEIGHT + TEXT_BOX_HEIGHT)/2], WIDTH, TEXT_BOX_HEIGHT
    end
    @pdf.fill_color "000000"
    @pdf.font FONT, :style => :bold do
      @pdf.text_box v["title"], :at => [0, (HEIGHT + TEXT_BOX_HEIGHT) / 2 ], :width => WIDTH, :height => TEXT_BOX_HEIGHT, :align => :center, :valign => :center
    end

    @pdf.font_size 6
    @pdf.text_box v["url"], :at => [4, 24], :width => WIDTH, :height => TEXT_BOX_HEIGHT, :align => :left, :valign => :center
  end

  def save()
    @pdf.render_file "./build/card.pdf"
  end
end

card = Card.new()
data = YAML.load_file('./data/data.yml')
data.each do |v|
  p v["title"]
  card.write(v)
end
card.save

