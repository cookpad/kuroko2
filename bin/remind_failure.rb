Kuroko2::JobInstance.working.where('error_at < ?', 1.days.ago).each do |instance|
  Kuroko2::Notifications.remind_failure(instance).deliver_now

  puts "Sent reminder mail to #{instance.job_definition.admins.map(&:name).join(' and ')}."
end
