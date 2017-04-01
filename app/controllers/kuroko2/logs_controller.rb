class Kuroko2::LogsController < Kuroko2::ApplicationController
  def index
    definition = Kuroko2::JobDefinition.find(logs_params[:job_definition_id])
    instance   = Kuroko2::JobInstance.find(logs_params[:job_instance_id])
    logs       = instance.logs.order(:id)

    render json: {
      reload: instance.working? && !instance.error?,
      logs: logs.map { |log|
        {
          id: log.id,
          level: log.level,
          class_for_label: class_for_label(log.level),
          created_at: log.created_at,
          message_html: Rinku.auto_link(ERB::Util.h(log.message), :urls),
        }
      },
    }
  end

  private

  def logs_params
    params.permit(:job_definition_id, :job_instance_id)
  end

  def class_for_label(level)
    modifier = case level
               when 'INFO'
                 'info'
               when 'ERROR'
                 'danger'
               when 'WARN'
                 'warning'
               else
                 'default'
               end
    "label-#{modifier}"
  end
end
