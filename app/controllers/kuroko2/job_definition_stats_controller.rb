class Kuroko2::JobDefinitionStatsController < Kuroko2::ApplicationController
  def index
    set_definition
  end

  def execution_time
    set_definition
    set_period

    @logs = JobInstance.where(job_definition_id: params[:job_definition_id]).
      order(created_at: :desc)
    if @start_at
      @logs = @logs.where(created_at: @start_at..@end_at)
    else
      @logs = @logs.limit(10)
    end
  end

  def memory
    set_definition
    set_period

    target_instance = JobInstance.where(job_definition_id: params[:job_definition_id])
    if @start_at
      target_instance = target_instance.where(created_at: @start_at..@end_at)
    end

    @logs = MemoryConsumptionLog.joins(:job_instance).
      merge(target_instance).order(created_at: :desc)
    @logs = @logs.limit(10) unless @start_at
  end

  private

  def set_period
    @end_at   = Time.now

    @start_at =
      case params[:period]
      when /\A(\d+)d\z/
        $1.to_i.days.ago(@end_at)
      when /\A(\d+)w\z/
        $1.to_i.weeks.ago(@end_at)
      when /\A(\d+)m\z/
        $1.to_i.month.ago(@end_at)
      else
        nil
      end
  end

  def set_definition
    @definition = JobDefinition.find(params[:job_definition_id])
  end
end
