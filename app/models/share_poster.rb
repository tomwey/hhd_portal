class SharePoster < ActiveRecord::Base

  validates :title, :image, presence: true
  
  mount_uploader :image, PosterUploader
  mount_uploader :body_image, PosterUploader
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uniq_id = (n.to_s + SecureRandom.random_number.to_s[2..8]).to_i
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  def self.cards
    [['-- 无 --', nil]] + Card.opened.can_send.order('id desc').map { |o| [o.title, o.id] }
  end
  
  def self.qrcode_pos_data
    [
      ['-- 无 --', nil], 
      ['左上', 'NorthWest'], 
      ['中上', 'North'], 
      ['右上', 'NorthEast'],
      ['左中', 'West'], 
      ['正中', 'Center'], 
      ['右中', 'East'],
      ['左下', 'SouthWest'], 
      ['中下', 'South'], 
      ['右下', 'SouthEast'],
    ]
  end
  
  # 带二维码水印的图片
  def share_image(watermark_image, watermark_text)
    
    watermark_text = watermark_text || qrcode_text || '识别二维码关注抢红包'
    
    img_url = poster_image_url
    
    watermark_image_content = watermark_image_content watermark_image
    # puts watermark_image_content
    watermark_text_content  = watermark_text_content watermark_text
    # puts watermark_text_content
    if img_url.include? "?"
      spliter = '&'
    else
      spliter = "?"
    end
    
    "#{img_url}#{spliter}watermark/3#{watermark_image_content}#{watermark_text_content}"
  end
  
  private
  def watermark_image_content(image_url)
    return '' if image_url.blank?
    
    "/image/#{Base64.urlsafe_encode64(image_url)}/gravity/#{self.qrcode_pos}#{self.qrcode_other_configs}"
  end
  
  def watermark_text_content(text)
    return '' if text.blank?
    
    "/text/#{Base64.urlsafe_encode64(text)}/gravity/#{self.text_pos}#{self.text_other_configs}"
  end
  
  def poster_image_url
    if self.body_image.blank?
      self.image.url
    else
      self.body_image.url
    end
  end
  
end
