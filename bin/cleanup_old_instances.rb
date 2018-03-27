target_date = 3.months.ago
old_instances = Kuroko2::JobInstance
  .where('finished_at < ?', target_date)
  .or(Kuroko2::JobInstance.where('canceled_at < ?', target_date))

count = old_instances.count

Kuroko2::JobInstance.transaction do
  old_instances.destroy_all
end

puts "Destroyed #{count} instances"
