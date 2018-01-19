module Kuroko2
  module Workflow
    module Notifier
      class Slack
        attr_reader :message_builder, :webhook_url

        module LevelToColor
          WARNING  = 'warning'
          FAILURE  = 'danger'
          CRITICAL = 'danger'
          SUCCESS  = 'good'
          INFO     = '#439FE0'
        end

        def initialize(instance)
          @instance   = instance
          @definition = instance.job_definition
          @message_builder = Workflow::Notifier::Concerns::ChatMessageBuilder.new(instance)
          @webhook_url = Kuroko2.config.notifiers.slack.webhook_url
        end

        def notify_launch
          if @definition.hipchat_notify_finished?
            send_attachment_message_to_slack(
              level: 'INFO',
              text: message_builder.launched_text,
              body: @instance.logs.reverse.detect{ |log| log.level == 'INFO' }.try!(:message),
            )
          end
        end

        def notify_retrying
          if @definition.hipchat_notify_finished?
            send_attachment_message_to_slack(
              level: 'INFO',
              text: message_builder.retrying_text,
              body: @instance.logs.last(2).first.message,
            )
          end
        end

        def notify_skipping
          if @definition.hipchat_notify_finished?
            send_attachment_message_to_slack(
              level: 'INFO',
              text: message_builder.skipping_text,
              body: @instance.logs.last(2).first.message,
            )
          end
        end

        def notify_cancellation
          if @definition.notify_cancellation || @definition.hipchat_notify_finished?
            send_attachment_message_to_slack(
              level: 'WARNING',
              text: message_builder.failure_text,
              body: @instance.logs.reverse.detect{ |log| log.level == 'WARN' }.try!(:message),
            )
          end
        end

        def notify_failure
          send_attachment_message_to_slack(
            level: 'FAILURE',
            text: message_builder.failure_text,
            body: @instance.logs.last(2).first.message,
          )

          send_additional_text_to_slack
        end

        def notify_critical
          send_attachment_message_to_slack(
            level: 'CRITICAL',
            text: message_builder.failure_text,
            body: @instance.logs.last(2).first.message,
          )

          send_additional_text_to_slack
        end

        def notify_finished
          if @definition.hipchat_notify_finished?
            send_attachment_message_to_slack(
              level: 'SUCCESS',
              text: message_builder.finished_text,
            )
          end
        end

        def notify_back_to_normal
          if @definition.notify_back_to_normal?
            send_attachment_message_to_slack(
              level: 'SUCCESS',
              text: message_builder.back_to_normal_text,
            )
          end
        end

        def notify_long_elapsed_time
          send_attachment_message_to_slack(
            level: 'WARNING',
            text: message_builder.long_elapsed_time_text,
          )
        end

        private

        def send_attachment_message_to_slack(level: , text: , body: nil)
          return false unless @definition.slack_channel.present?

          send_to_slack(
            channel: @definition.slack_channel,
            link_names: 1,
            attachments: [
              {
                title: "[#{level}] #{text}",
                title_link: message_builder.job_instance_path,
                text: body,
                fallback: "[#{level}] #{text} #{message_builder.job_instance_path}",
                color: LevelToColor.const_get(level),
              }
            ]
          )
        end

        def send_to_slack(payload)
          url = URI.parse(webhook_url)
          conn = Faraday.new(:url => "#{url.scheme}://#{url.host}") do |faraday|
            faraday.adapter Faraday.default_adapter
          end

          response = conn.post do |req|
            req.url url.path
            req.headers['Content-Type'] = 'application/json'
            req.body = payload.to_json
          end

          unless response.success?
            Kuroko2.logger.fatal("Failure sending message to Slack: status=#{response.status} body=#{response.body}")
          end
        end

        def send_additional_text_to_slack
          if @definition.slack_channel.present? && @definition.hipchat_additional_text.present?
            send_to_slack(
              channel: @definition.slack_channel,
              text: message_builder.additional_text,
              link_names: 1
            )
          end
        end
      end
    end
  end
end
