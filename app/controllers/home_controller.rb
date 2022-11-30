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
      -vf "drawtext=text='#{params[:name]}':fontcolor=black:fontsize=22:x=107:y=139,\
        drawtext=text='#{params[:watervol]}':fontcolor=black:fontsize=22:x=192:y=252,\
        drawtext=text='#{date[:year]}':fontcolor=black:fontsize=22:x=626:y=185,\
        drawtext=text='#{date[:month]}':fontcolor=black:fontsize=22:x=685:y=185,\
        drawtext=text='#{date[:date]}':fontcolor=black:fontsize=22:x=740:y=185" #{water_charge}`

    `ffmpeg -y \
      -i #{Rails.root}/app/assets/images/water-affidavit-letter.jpg \
      -vf "drawtext=text='#{params[:owner]}':fontcolor=black:fontsize=30:x=280:y=230,\
          drawtext=text='#{params[:waternum]}':fontcolor=black:fontsize=30:x=630:y=250,\
          drawtext=text='#{params[:name]}':fontcolor=black:fontsize=30:x=980:y=220,\
          drawtext=text='#{params[:phone]}':fontcolor=black:fontsize=30:x=1220:y=220,\
          drawtext=text='#{params[:date]}':fontcolor=black:fontsize=30:x=1450:y=220,\
          drawtext=text='#{params[:watervol]}':fontcolor=black:fontsize=30:x=60:y=460,\
          drawtext=text='#{params[:address]}':fontcolor=black:fontsize=30:x=620:y=400" #{water_affidavit}`

    `ffmpeg -y \
      -i #{Rails.root}/app/assets/images/electric.png \
      -vf "drawtext=text='#{params[:address]}':fontcolor=black:fontsize=30:x=200:y=228,\
            drawtext=text='#{params[:name]}':fontcolor=black:fontsize=30:x=300:y=800,\
            drawtext=text='#{params[:idcard]}':fontcolor=black:fontsize=30:x=390:y=840,\
            drawtext=text='#{params[:phone]}':fontcolor=black:fontsize=30:x=290:y=880" #{electric}`

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
end
