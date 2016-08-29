json.start @start_at.try!(:strftime, '%Y-%m-%d %H:%M:%S')
json.end @end_at.strftime('%Y-%m-%d %H:%M:%S')
json.data do
  json.array! @logs do |log|
    json.x log.created_at.strftime('%Y-%m-%d %H:%M:%S')
    json.y log.execution_minutes
    json.label do
      json.content log.execution_minutes
      json.className 'vis-graph-label'
    end
    json.group 'execution-time'
  end
end
