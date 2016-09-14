class Kuroko2::Api::StatsController < Kuroko2::Api::ApplicationController
  skip_before_action :api_authentication

  COUNT_INSTANCES_SQL = <<-SQL
    SELECT COUNT(error_at IS NULL OR NULL)     AS `kuroko2.job_instances.working`,
           COUNT(error_at IS NOT NULL OR NULL) AS `kuroko2.job_instances.error`
    FROM #{Kuroko2::JobInstance.table_name}
    WHERE finished_at IS NULL
      AND canceled_at IS NULL
  SQL

  def instance
    render json: ActiveRecord::Base.connection.select_one(COUNT_INSTANCES_SQL).to_hash
  end

  def waiting_execution
    waiting_executions_count = Kuroko2::Execution.select('queue, COUNT(1) AS `count`').
      where('started_at IS NULL AND created_at < ?', 3.minutes.ago).group(:queue)

    render json: Kuroko2::Worker.pluck(:queue).uniq.inject({}) { |result, queue|
      result.merge(
        "kuroko2.executions.waiting.#{queue}" => waiting_executions_count.find { |count|
          count.queue == queue
        }.try!(:[], "count") || 0
      )
    }
  end
end
