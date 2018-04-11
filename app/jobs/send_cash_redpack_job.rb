class SendCashRedpackJob < ActiveJob::Base
  queue_as :scheduled_jobs

  def perform(log_id)
    
    cash_hb_log = RedpackSendLog.find_by(id: log_id)
    # puts cash_hb_log
    return if cash_hb_log.blank?
    
    redpack = cash_hb_log.redpack
    
    # puts redbag
    return if redpack.blank?
    # return if !redbag.is_cash_hb
    
    config = redpack.redpack_send_config
    if config
      wishing = config.wishing
      send_name = config.send_name
    else
      wishing = '恭喜发财，大吉大利！'
      send_name = redpack.merchant.try(:name) || '惠互动'
    end
    
    # return if config.blank?
    
    to_user = cash_hb_log.user.wechat_profile.try(:openid)
    
    # puts to_user
    # 调用微信发红包接口
    
    result = Wechat::Pay.send_redbag(cash_hb_log.uniq_id, 
                                     send_name, 
                                     to_user, 
                                     cash_hb_log.money / 100.0, 
                                     wishing, 
                                     '无', 
                                     '无', 
                                     'PRODUCT_1')
    if result
      if result['return_code'] == 'SUCCESS' && result['result_code'] == 'SUCCESS'
        cash_hb_log.sent_at = Time.zone.now
        cash_hb_log.sent_error = nil
      else
        cash_hb_log.sent_at = nil
        cash_hb_log.sent_error = "return_msg:#{result['return_msg']};
          err_code:#{result['err_code']};err_code_desc:#{result['err_code_des']}"
      end
      cash_hb_log.save
    end
    
  end
  
end
