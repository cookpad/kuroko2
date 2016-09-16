old_instances = Kuroko2::JobInstance.where('finished_at < ?', 3.months.ago)

count = old_instances.count

Kuroko2::JobInstance.transaction do
  old_instances.destroy_all
end

puts "Destroyed #{count} instances"
