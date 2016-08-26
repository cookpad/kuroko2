module ExecutionLogger
  class NotFound < StandardError
  end

  def self.get_logger(option = {})
    config = Kuroko2.config.execution_logger
    if config.present? && config.type.present?
      logger_class = const_get(config.type, false)
      if config.option.present?
        logger_class.new(config.option.to_h.merge(option).symbolize_keys)
      else
        logger_class.new(option)
      end
    else
      Void.new(option)
    end
  end
end
