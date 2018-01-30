old_histories = Kuroko2::ExecutionHistory.where('finished_at < ?', 2.weeks.ago)

count = old_histories.count

Kuroko2::ExecutionHistories.transaction do
  old_histories.destroy_all
end

puts "Destroyed #{count} histories"
