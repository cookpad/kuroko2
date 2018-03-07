class Kuroko2::ExecutionHistoriesController < Kuroko2::ApplicationController
  def index
    @histories = histories.page(params[:page])
  end

  def timeline
  end

  def dataset
    set_period
    @histories = histories.where('started_at < ?', @end_at).where('finished_at > ?', @start_at)
  end

  private

  def query_params
    params.permit(:queue, :hostname)
  end

  def histories
    histories = Kuroko2::ExecutionHistory.ordered.includes(:job_definition, :job_instance)

    queue = query_params[:queue]
    histories = histories.where(queue: queue) if queue.present?

    hostname = query_params[:hostname]
    histories = histories.where(hostname: hostname) if hostname.present?

    histories
  end

  def period_params
    params.permit(:period, :end_at, :start_at)
  end

  def end_at
    if period_params[:end_at].present?
      begin
        return period_params[:end_at].to_datetime
      rescue ArgumentError
        # do nothing
      end
    end
    Time.current
  end

  def start_at
    if period_params[:start_at].present?
      begin
        return period_params[:start_at].to_datetime
      rescue ArgumentError
        # do nothing
      end
    end
    case period_params[:period]
    when /\A(\d+)m\z/
      $1.to_i.minutes.ago(@end_at)
    when /\A(\d+)h\z/
      $1.to_i.hours.ago(@end_at)
    when /\A(\d+)d\z/
      $1.to_i.days.ago(@end_at)
    when /\A(\d+)w\z/
      $1.to_i.weeks.ago(@end_at)
    else
      1.hour.ago(@end_at)
    end
  end

  def set_period
    @end_at = end_at
    @start_at = start_at
  end
end
