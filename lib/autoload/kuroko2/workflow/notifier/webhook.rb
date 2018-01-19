module Kuroko2
  module Workflow
    module Notifier
      class Webhook
        attr_reader :message_builder

        HASH_ALGORITHM = 'sha256'
        HMAC_DIGEST    = OpenSSL::Digest.new(HASH_ALGORITHM)

        def initialize(instance)
          @instance   = instance
          @definition = instance.job_definition
          @message_builder = Workflow::Notifier::Concerns::ChatMessageBuilder.new(instance)
          @secret_token = Kuroko2.config.notifiers.webhook.try!(:secret_token)
        end

        def notify_launch
          if @definition.hipchat_notify_finished?
            request(
              build_payload(
                action: 'notify_launch',
                level: 'INFO',
                subject: message_builder.launched_text,
                message: @instance.logs.reverse.detect{ |log| log.level == 'INFO' }.try!(:message),
              )
            )
          end
        end

        def notify_retrying
          if @definition.hipchat_notify_finished?
            request(
              build_payload(
                action: 'notify_retrying',
                level: 'INFO',
                subject: message_builder.retrying_text,
                message: @instance.logs.last(2).first.message,
              )
            )
          end
        end

        def notify_skipping
          if @definition.hipchat_notify_finished?
            request(
              build_payload(
                action: 'notify_skipping',
                level: 'INFO',
                subject: message_builder.skipping_text,
                message: @instance.logs.last(2).first.message,
              )
            )
          end
        end

        def notify_cancellation
          if @definition.notify_cancellation || @definition.hipchat_notify_finished?
            request(
              build_payload(
                action: 'notify_cancellation',
                level: 'WARNING',
                subject: message_builder.failure_text,
                message: @instance.logs.reverse.detect{ |log| log.level == 'WARN' }.try!(:message),
              )
            )
          end
        end

        def notify_failure
          request(
            build_payload(
              action: 'notify_failure',
              level: 'FAILURE',
              subject: message_builder.failure_text,
              message: @instance.logs.last(2).first.message,
            )
          )
        end

        def notify_critical
          request(
            build_payload(
              action: 'notify_critical',
              level: 'CRITICAL',
              subject: message_builder.failure_text,
              message: @instance.logs.last(2).first.message,
            )
          )
        end

        def notify_finished
          if @definition.hipchat_notify_finished? || @instance.notify_back_to_normal?
            request(
              build_payload(
                action: 'notify_finished',
                level: 'SUCCESS',
                subject: message_builder.finished_text,
              )
            )
          end
        end

        def notify_long_elapsed_time
          request(
            build_payload(
              action: 'notify_long_elapsed_time',
              level: 'WARNING',
              subject: message_builder.long_elapsed_time_text,
            )
          )
        end

        private

        def request(body)
          return unless @definition.webhook_url.present?

          url = URI.parse(@definition.webhook_url)
          conn = Faraday.new(url: "#{url.scheme}://#{url.host}") do |faraday|
            faraday.port = url.port
            faraday.adapter Faraday.default_adapter
          end

          json = body.to_json
          response = conn.post do |req|
            req.url(url.path)

            req.headers['X-Kuroko2-Id'] = SecureRandom.uuid
            if @secret_token.present?
              req.headers['X-Kuroko2-Signature'] = "#{HASH_ALGORITHM}=#{OpenSSL::HMAC.hexdigest(HMAC_DIGEST, @secret_token, json)}"
            end

            req.headers['User-Agent']   = 'Kuroko2-Webhook'
            req.headers['Content-Type'] = 'application/json'
            req.body = json
          end

          unless response.success?
            Kuroko2.logger.fatal("Failure sending webhook: status=#{response.status} body=#{response.body}")
          end
        end

        def build_payload(action:, level:, subject:, message: nil)
          {
            action: action,
            level: level,
            subject: subject,
            message: message,
            job_instance: {
              url: message_builder.job_instance_path,
              id: @instance.id,
              script: @instance.script,
              finished_at: @instance.finished_at.try!(:iso8601),
              canceled_at: @instance.canceled_at.try!(:iso8601),
              error_at: @instance.error_at.try!(:iso8601),
              created_at: @instance.created_at.try!(:iso8601),
            },
            job_definition: {
              url: Kuroko2::Engine.routes.url_helpers.job_definition_url(
                @definition,
                host: Kuroko2.config.url_host,
                protocol: Kuroko2.config.url_scheme,
              ),
              id: @definition.id,
              name: @definition.name,
              description: @definition.description,
            }
          }
        end
      end
    end
  end
end
