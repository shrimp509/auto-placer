class LeaseController < ApplicationController
  def index
  end

  def start
    filename = params[:house_number]&.strip
    lease_page_1 = "#{Rails.root}/tmp/#{filename}-租約-第1頁.jpg"
    lease_page_2 = "#{Rails.root}/tmp/#{filename}-租約-第2頁.jpg"
    lease_page_7 = "#{Rails.root}/tmp/#{filename}-租約-第7頁.jpg"

    `ffmpeg -y \
      -i #{Rails.root}/app/assets/images/lease-1.jpg \
      -vf "#{draw_text(params[:year], 830, 190, size: 30)},\
          #{draw_text(params[:month], 1000, 190, size: 30)},\
          #{draw_text(params[:date], 1150, 190, size: 30)},\
          #{draw_text(params[:building_number], 425, 640, size: 30)},\
          #{draw_text(params[:house_number], 425, 585, size: 30)},\
          #{draw_text(option_car_position, 460, 705, size: 30)},\
          #{draw_text(option_bike_position, 460, 765, size: 30)},\
          #{draw_text(params[:car_capacity], 455, 705, size: 30)},\
          #{draw_text(params[:bike_capacity], 455, 765, size: 30)},\
          #{draw_text(params[:main_building], 520, 825, size: 30)},\
          #{draw_text(params[:affiliated_building], 555, 895, size: 30)},\
          #{draw_text(params[:shared_building_number], 565, 960, size: 30)},\
          #{draw_text(params[:parking_car_floor], 605, 1270, size: 30)},\
          #{draw_text(params[:parking_car_number], 450, 1310, size: 30)},\
          #{draw_text('V', x_option_parking_type, 1270, size: 30)},\
          #{draw_text(params[:parking_bike_floor], 805, 1345, size: 30)},\
          #{draw_text(params[:parking_bike_number], 1000, 1345, size: 30)},\
          #{draw_text('V', x_option_parking_period, 1465, size: 30)},\
          #{draw_text(params[:other], 807, 1460, size: 30)},\
          #{draw_text(params[:lease_period_from_year], 615, 1625, size: 30)},\
          #{draw_text(params[:lease_period_from_month], 780, 1625, size: 30)},\
          #{draw_text(params[:lease_period_from_day], 930, 1625, size: 30)},\
          #{draw_text(params[:lease_period_to_year], 390, 1665, size: 30)},\
          #{draw_text(params[:lease_period_to_month], 550, 1665, size: 30)},\
          #{draw_text(params[:lease_period_to_day], 715, 1665, size: 30)},\
          #{draw_text(params[:lease_price], 870, 1750, size: 30)},\
          #{draw_text(params[:option_lease_unit_month_day], 820, 1785, size: 30)}" #{lease_page_1}`

    `ffmpeg -y \
      -i #{Rails.root}/app/assets/images/lease-2.jpg \
      -vf "#{draw_text(params[:bank_name], 1110, 185, size: 30)},\
            #{draw_text(params[:bank_user_name], 490, 225, size: 30)},\
            #{draw_text(params[:bank_user_account], 790, 230, size: 24)}" #{lease_page_2}`

    `ffmpeg -y \
      -i #{Rails.root}/app/assets/images/lease-7.jpg \
      -vf "#{draw_text(params[:leaseholder], 420, 239, size: 30)},\
            #{draw_text(params[:leaseholder_id_number], 680, 290, size: 30)},\
            #{draw_text(params[:leaseholder_address], 610, 335, size: 30)},\
            #{draw_text(params[:leaseholder_comm_address], 385, 385, size: 30)},\
            #{draw_text(params[:leaseholder_phone], 385, 430, size: 30)},\
            #{draw_text(params[:leasee], 420, 530, size: 30)},\
            #{draw_text(params[:leasee_id_number], 680, 580, size: 30)},\
            #{draw_text(params[:leasee_address], 610, 625, size: 30)},\
            #{draw_text(params[:leasee_comm_address], 385, 675, size: 30)},\
            #{draw_text(params[:leasee_phone], 385, 725, size: 30)}" #{lease_page_7}`

    check_files_existence([lease_page_1, lease_page_2, lease_page_7])

    require 'zip'
    zip_name = "#{filename}.zip"
    Zip::File.open("tmp/#{zip_name}", create: true) do |zip|
      zip.add("#{filename}-租約-第0頁.jpg", "#{Rails.root}/app/assets/images/lease-0.jpg")
      zip.add(File.basename(lease_page_1), lease_page_1)
      zip.add(File.basename(lease_page_2), lease_page_2)
      zip.add("#{filename}-租約-第3頁.jpg", "#{Rails.root}/app/assets/images/lease-3.jpg")
      zip.add("#{filename}-租約-第4頁.jpg", "#{Rails.root}/app/assets/images/lease-4.jpg")
      zip.add("#{filename}-租約-第5頁.jpg", "#{Rails.root}/app/assets/images/lease-5.jpg")
      zip.add("#{filename}-租約-第6頁.jpg", "#{Rails.root}/app/assets/images/lease-6.jpg")
      zip.add(File.basename(lease_page_7), lease_page_7)
      zip.add("#{filename}-租約-第8頁.jpg", "#{Rails.root}/app/assets/images/lease-8.jpg")
      zip.add("#{filename}-租約-第9頁.jpg", "#{Rails.root}/app/assets/images/lease-9.jpg")
      # zip.add("#{filename}-租約-第10頁.jpg", "#{Rails.root}/app/assets/images/lease-10.jpg")
    end

    @name = zip_name
  ensure
    [lease_page_1, lease_page_2, lease_page_7].each do |file|
      delete_file_if_exist(file)
    end
  end

  def download
    name = CGI.unescape(params[:name])
    file = "tmp/#{name}"
    send_file(file) if File.exist?(file)
  ensure
    other_zips = Dir.glob("tmp/*.zip") - [file]
    other_zips.each do |file|
      delete_file_if_exist(file)
    end
  end

  private

  def font_file
    "fontfile=#{Rails.root}/app/assets/fonts/TaipeiSansTCBeta-Regular.ttf"
  end

  def draw_text(text, x, y, color: 'black', size: 22)
    "drawtext=#{font_file}:text='#{text&.strip}':fontcolor=#{color}:fontsize=#{size}:x=#{x}:y=#{y}"
  end

  def option_car_position
    case params[:option_car_position]
    when '有'
      '有'
    when '無'
      '無'
    when '洽管委會'
      '洽管委會'
    else
      ''
    end
  end

  def option_bike_position
    case params[:option_bike_position]
    when '有'
      '有'
    when '無'
      '無'
    when '洽管委會'
      '洽管委會'
    else
      ''
    end
  end

  def x_option_parking_period
    case params[:option_parking_period]
    when '全日'
      407
    when '日間'
      507
    when '夜間'
      607
    when '其他'
      707
    else
      707
    end
  end

  def x_option_parking_type
    case params[:option_parking_type]
    when '平面車位'
      700
    when '機械車位'
      930
    else
      700
    end
  end

  def check_files_existence(files, max_retries = 5, retry_interval = 1)
    retries = 0
  
    loop do
      missing_files = files.select { |file| !File.exist?(file) }
  
      if missing_files.empty?
        # 所有檔案都存在
        break
      elsif retries < max_retries
        # 還有檔案不存在，進行等待並重試
        retries += 1
        sleep retry_interval
      else
        # 超過最大重試次數，拋出錯誤
        raise "無法找到以下檔案: #{missing_files.join(', ')}"
      end
    end
  end

  def delete_file_if_exist(file)
    if File.exist?(file)
      File.delete(file)
      Rails.logger.info("#{file} deleted at #{Time.current.in_time_zone('Asia/Taipei')}")
    else
      Rails.logger.info("#{file} not found at #{Time.current.in_time_zone('Asia/Taipei')}")
    end
  end
end
