if Rails.env.local?
  SolidQueue.on_start { Rails.logger.level = Logger::Severity::INFO }
else
  SolidQueue.on_start { Rails.logger.level = Logger::Severity::WARN }
end
