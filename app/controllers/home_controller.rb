class HomeController < ApplicationController
  def index
  end

  def start
    water_affidavit = "#{Rails.root}/tmp/#{params[:owner]}-台水中間結帳切結書.png"
    electric = "#{Rails.root}/tmp/#{params[:owner]}-台電變更用電單.png"

    `ffmpeg -y \
      -i #{Rails.root}/app/assets/images/water-affidavit-letter.jpg \
      -vf "#{draw_text(params[:date], 55, 230, size: 30)},\
          #{draw_text(params[:owner], 280, 230, size: 30)},\
          #{draw_text(params[:waternum], 630, 250, size: 30)},\
          #{draw_text(params[:name], 980, 220, size: 30)},\
          #{draw_text(params[:phone], 1220, 220, size: 30)},\
          #{draw_text(params[:date], 1450, 220, size: 30)},\
          #{draw_text(params[:watervol], 60, 460, size: 30)},\
          #{draw_text(params[:address], 620, 400, size: 30)}" #{water_affidavit}`

    `ffmpeg -y \
      -i #{Rails.root}/app/assets/images/electric.png \
      -vf "#{draw_text(params[:address], 200, 228, size: 30)},\
            #{draw_text(params[:name], 300, 800, size: 30)},\
            #{draw_text(params[:idcard], 390, 840, size: 30)},\
            #{draw_text(params[:phone], 290, 880, size: 30)}" #{electric}`

    require 'zip'
    zip_name = "#{params[:address]}.zip"
    Zip::File.open("tmp/#{zip_name}", Zip::File::CREATE) do |zip|
      zip.add(File.basename(water_affidavit), water_affidavit)
      zip.add(File.basename(electric), electric)
    end

    @name = zip_name
  ensure
    [water_affidavit, electric].each { |file| File.delete(file) }
  end

  def download
    name = CGI.unescape(params[:name])
    file = "tmp/#{name}"
    send_file(file) if File.exist?(file)
  ensure
    other_zips = Dir.glob("tmp/*.zip") - [file]
    other_zips.each { |file| File.delete(file) }
  end

  private

  def font_file
    "fontfile=#{Rails.root}/app/assets/fonts/TaipeiSansTCBeta-Regular.ttf"
  end

  def draw_text(text, x, y, color: 'black', size: 22)
    "drawtext=#{font_file}:text='#{text}':fontcolor=#{color}:fontsize=#{size}:x=#{x}:y=#{y}"
  end
end
