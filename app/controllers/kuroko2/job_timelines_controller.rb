class Kuroko2::JobTimelinesController < Kuroko2::ApplicationController
  def index
    find_user
  end

  def dataset
    find_user
    set_period

    definition_ids = []
    definition_ids << my_difinitions.pluck(:id)
    definition_ids << assigned_definitions.pluck(:id)

    @instances = JobInstance.includes(:job_definition).
      where(job_definition_id: definition_ids.flatten.uniq, created_at: @start_at..@end_at).
      order(:created_at)
  end

  private

  def my_difinitions
    rel = @user.job_definitions
    rel = rel.tagged_by(params[:tag]) if params[:tag].present?
    rel
  end

  def assigned_definitions
    rel = @user.assigned_job_definitions
    rel = rel.tagged_by(params[:tag]) if params[:tag].present?
    rel
  end

  def find_user
    if params[:user_id]
      @user = User.find(params[:user_id])
    else
      @user = current_user
    end
  end

  def set_period
    @end_at   = Time.now

    @start_at =
      case params[:period]
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
end
