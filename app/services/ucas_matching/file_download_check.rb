module UCASMatching
  class FileDownloadCheck < OkComputer::Check
    LAST_SUCCESSFUL_SYNC = 'last-successful-ucas-matching-file-download'.freeze

    def self.set_last_sync(date)
      Redis.current.set(LAST_SUCCESSFUL_SYNC, date)
    end

    def self.clear_last_sync
      Redis.current.del(LAST_SUCCESSFUL_SYNC)
    end

    def self.last_sync
      Redis.current.get(LAST_SUCCESSFUL_SYNC)
    end

    def check
      last_date = self.class.last_sync

      if last_date.nil?
        mark_failure
        mark_message 'Cannot find the time when the last UCAS file download took place'
      elsif Time.zone.now > Time.zone.parse(last_date).next_weekday
        mark_failure
        mark_message 'There was no UCAS file download taking place yesterday'
      else
        mark_message 'There was a succesful UCAS file download that has taken place since the last weekday'
      end
    end
  end
end
