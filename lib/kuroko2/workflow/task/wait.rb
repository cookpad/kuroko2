module Kuroko2
  module Workflow
    module Task
      class Wait < Base
        PERIODS = %w(hourly daily weekly monthly)

        def execute
          if token.context['WAIT'].present?
            if token.waiting?
              process_waiting_job
            else
              Kuroko2.logger.info { "(token #{token.uuid}) Skip since current status marked as '#{token.status_name}'." }
              token.mark_as_waiting

              :pass
            end
          else
            token.context['WAIT'] = parse_option(option, start_at: token.job_instance.created_at)

            Kuroko2.logger.info { "(token #{token.uuid}) waiting jobs: #{token.context['WAIT']["jobs"]}" }

            token.mark_as_waiting
            message = "(token #{token.uuid}) Marked as 'waiting' #{node.option}."
            token.job_instance.logs.info(message)
            Kuroko2.logger.info(message)
            token.save!

            :pass
          end
        end

        def process_waiting_job
          receive_waiting_job_completion!

          wait_option = token.context['WAIT']
          if wait_option["jobs"].all? { |wait_job| wait_job["received"] }
            token.mark_as_working
            token.context.delete('WAIT')
            token.save!

            message = "(token #{token.uuid}) All waiting jobs are finished."
            Kuroko2.logger.info(message)
            token.job_instance.logs.info(message)

            :next
          elsif wait_option["timeout"].minutes.since(token.created_at).past?
            message = "(token #{token.uuid}) waiting jobs `#{node.option}` timeout."
            Kuroko2.logger.error(message)
            token.job_instance.logs.error(message)

            :failure
          else
            :pass
          end
        end

        def validate
          parse_option(option)
        end

        private

        # ex. wait: 100/daily 200/daily
        def parse_option(option, start_at: Time.current)
          raise_assertion_error unless option

          wait_option = { "jobs" => [], "timeout" => 60.minutes.to_i / 1.minute }
          scanner = StringScanner.new(option)
          until scanner.eos?
            if scanner.scan(%r!(\d+)\s*/\s*(#{PERIODS.join('|')})!)
              start_from, start_to = period_to_time(scanner[2], at: start_at)
              wait_option["jobs"] << {
                "job_definition_id" => parse_definition_id(scanner[1]),
                "period"            => scanner[2],
                "start_from"        => start_from.to_s,
                "start_to"          => start_to.to_s,
                "received"          => false,
              }
            elsif scanner.scan(/timeout=(\d+)h/)
              wait_option["timeout"] = scanner[1].to_i.hours / 60
            elsif scanner.scan(/timeout=(\d+)m/) || scanner.scan(/timeout=(\d+)/)
              wait_option["timeout"] = scanner[1].to_i
            elsif scanner.scan(/\s+|,/)
              # do nothing
            else
              raise_assertion_error
            end
          end

          wait_option
        end

        def receive_waiting_job_completion!
          token.context['WAIT']["jobs"].each do |wait_job|
            next if wait_job["received"] == true

            start_from = Time.zone.parse(wait_job["start_from"])
            start_to   = Time.zone.parse(wait_job["start_to"])

            received_instance = JobInstance.finished.where(
              job_definition_id: wait_job["job_definition_id"].to_i,
              created_at: start_from .. start_to
            ).first

            if received_instance.present?
              wait_job["received"] = true
              token.save!

              message = "(token #{token.uuid}) A waiting job instance##{received_instance.job_definition_id}/#{received_instance.id} is finished."
              Kuroko2.logger.info(message)
              token.job_instance.logs.info(message)
            end
          end
        end

        def period_to_time(period, at: Time.current)
          case period
          when "hourly"
            [at.beginning_of_hour, at.end_of_hour]
          when "daily"
            [at.beginning_of_day, at.end_of_day]
          when "weekly"
            [at.beginning_of_week, at.end_of_week]
          when "monthly"
            [at.beginning_of_month, at.end_of_month]
          else
            raise_assertion_error
          end
        end

        def parse_definition_id(id)
          JobDefinition.find(id.to_i).id
        rescue ActiveRecord::RecordNotFound
          raise Workflow::AssertionError, "Given Job Definition ID not found: #{id}"
        end

        def raise_assertion_error
          raise Workflow::AssertionError, "Syntax error option value of wait: #{option}"
        end
      end
    end
  end
end
