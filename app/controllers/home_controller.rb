class HomeController < ApplicationController
  DATE_REGX = /(?<year>\d+)\/(?<month>\d+)\/(?<date>\d+)/

  def index
  end

  def start
    date = params[:date]&.match(DATE_REGX)
    water_charge = "#{Rails.root}/tmp/#{params[:name]}-water-charge.png"
    water_affidavit = "#{Rails.root}/tmp/#{params[:name]}-water-affidavit-letter.png"
    electric = "#{Rails.root}/tmp/#{params[:name]}-electric.png"

    `ffmpeg -y \
      -i #{Rails.root}/app/assets/images/water-charge.png \
      -vf "#{draw_text(params[:name], 107, 139)},\
        #{draw_text(params[:watervol], 192, 252)},\
        #{draw_text(date[:year], 626, 185)},\
        #{draw_text(date[:month], 685, 185)},\
        #{draw_text(date[:date], 740, 185)}" #{water_charge}`

    `ffmpeg -y \
      -i #{Rails.root}/app/assets/images/water-affidavit-letter.jpg \
      -vf "#{draw_text(params[:owner], 280, 230, size: 30)},\
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
    Zip::File.open("tmp/#{params[:name]}.zip", Zip::File::CREATE) do |zip|
      zip.add(File.basename(water_charge), water_charge)
      zip.add(File.basename(water_affidavit), water_affidavit)
      zip.add(File.basename(electric), electric)
    end

    @name = params[:name]
  end

  def download
    name = CGI.unescape(params[:name])
    send_file("tmp/#{name}.zip")
  end

  private

  def font_file
    # "fontfile=#{Rails.root}/app/assets/fonts/NotoSansMonoCJKtc-Regular.otf"
    "fontfile=#{Rails.root}/app/assets/fonts/Cubic_11.ttf"
  end

  def draw_text(text, x, y, color: 'black', size: 22)
    "drawtext=#{font_file}:text='#{text}':fontcolor=#{color}:fontsize=#{size}:x=#{x}:y=#{y}"
  end
end
