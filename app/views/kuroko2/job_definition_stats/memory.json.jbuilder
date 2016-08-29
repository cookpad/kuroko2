json.start @start_at.try!(:strftime, '%Y-%m-%d %H:%M:%S')
json.end   @end_at.strftime('%Y-%m-%d %H:%M:%S')
json.data do
  json.array! @logs do |log|
    json.x log.job_instance.created_at.strftime('%Y-%m-%d %H:%M:%S')
    json.y log.value
    json.label "##{log.job_instance.id}"
    json.group 'memory'
  end
end
