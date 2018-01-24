json.start @start_at.strftime('%Y-%m-%d %H:%M:%S')
json.end   @end_at.strftime('%Y-%m-%d %H:%M:%S')
json.data do
  json.array! @instances do |instance|
    json.id instance.id
    json.content "<a href='#{job_definition_job_instance_path(instance.job_definition, instance)}'>##{instance.job_definition.id} #{html_escape(instance.job_definition.name)}</a>"
    json.start instance.created_at.strftime('%Y-%m-%d %H:%M:%S')
    json.end (instance.error_at || instance.canceled_at || instance.finished_at || Time.current).try!(:strftime, '%Y-%m-%d %H:%M:%S')
    json.group instance.job_definition.id
  end
end
