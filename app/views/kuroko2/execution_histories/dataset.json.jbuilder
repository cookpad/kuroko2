json.start @start_at.strftime('%Y-%m-%d %H:%M:%S')
json.end   @end_at.strftime('%Y-%m-%d %H:%M:%S')
json.data do
  json.array! @histories do |history|
    json.id history.id
    json.content "<a href='#{job_definition_job_instance_path(history.job_definition, history.job_instance)}'>##{history.job_definition.id} #{h(history.job_definition.name)}</a>"
    json.start history.started_at.strftime('%Y-%m-%d %H:%M:%S')
    json.end history.finished_at.strftime('%Y-%m-%d %H:%M:%S')
  end
end
