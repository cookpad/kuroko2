module Workflow
  module Notifier
    class Hipchat
      attr_reader :hipchat, :message_builder

      USER_NAME = 'kuroko2'

      def initialize(instance)
        @instance   = instance
        @definition = instance.job_definition
        @hipchat    = Kuroko2.config.notifiers.hipchat.api_token
        @message_builder = Workflow::Notifier::Concerns::ChatMessageBuilder.new(instance)
      end

      def notify_working
        # do nothing
      end

      def notify_cancellation
        if @definition.notify_cancellation
          message = build_message(level: 'WARNING', text: message_builder.failure_text)
          message << "<br>"
          message << @instance.logs.last(2).first.message

          send_to_hipchat(message, color: 'yellow')
        end
      end

      def notify_failure
        message = build_message(level: 'FAILURE', text: message_builder.failure_text)
        message << "<br>"
        message << @instance.logs.last(2).first.message

        send_to_hipchat(message, color: 'red', notify: true)
        send_additional_text_to_hipchat
      end

      def notify_critical
        message = build_message(level: 'CRITICAL', text: message_builder.failure_text)
        message << "<br>"
        message << @instance.logs.last(2).first.message

        send_to_hipchat(message, color: 'red', notify: true)
        send_additional_text_to_hipchat
      end

      def notify_finished
        if @definition.hipchat_notify_finished?
          message = build_message(level: 'SUCCESS', text: message_builder.finished_text)
          send_to_hipchat(message)
        end
      end

      def notify_long_elapsed_time
        message = build_message(level: 'WARNING', text: message_builder.long_elapsed_time_text)
        send_to_hipchat(message, color: 'red')
      end

      private

      def send_to_hipchat(message, color: 'green', notify: false, format: 'html')
        if notify_hipchat?

          hipchat[@definition.hipchat_room].send(USER_NAME, message, color: color, notify: notify, message_format: format)
        end
      end

      def build_message(level: , text:)
        message = "<b>[#{level}]</b> "
        message << text
        message << "(<a href='#{message_builder.job_instance_path}'>Open</a>)"
      end

      def send_additional_text_to_hipchat
        if @definition.hipchat_additional_text.present?
          message = message_builder.additional_text
          send_to_hipchat(message, color: 'red', notify: true, format: 'text')
        end
      end

      def notify_hipchat?
        @definition.hipchat_room.present?
      end
    end
  end
end
