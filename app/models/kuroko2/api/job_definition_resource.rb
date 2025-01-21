class Kuroko2::Api::JobDefinitionResource < Kuroko2::Api::ApplicationResource
  SIMPLE_PROPERTIES = [
    :id,
    :name,
    :description,
    :script,
    :tags,
    :cron,
    :notify_cancellation,
    :suspended,
    :prevent_multi,
    :slack_channel,
  ]
  SIMPLE_PROPERTIES.each do |name|
    property name
  end
  delegate *SIMPLE_PROPERTIES, :destroy, to: :model

  property def tags
    model.tags.map(&:name)
  end

  property def cron
    model.job_schedules.map(&:cron)
  end

  property def user_id
    model.admins.map(&:id)
  end
end
