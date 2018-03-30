target_date = 3.months.ago
count = 0

Kuroko2::JobInstance
  .where('finished_at < ?', target_date)
  .or(Kuroko2::JobInstance.where('canceled_at < ?', target_date))
  .order(id: :asc)
  .in_batches do |old_instances|
  count += old_instances.size
  old_instances.destroy_all
end

puts "Destroyed #{count} instances"
