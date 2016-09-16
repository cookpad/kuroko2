module Kuroko2
  module Workflow
    module Task
      class KurokoRunner < Execute
        def before_execute
          env = token.context['ENV'] || {}
          env.merge!('BUNDLE_GEMFILE' => Rails.root.join('Gemfile').to_s)

          token.context['ENV'] = env
        end

        def chdir
          Rails.root.to_s
        end

        def shell
          rails = Rails.root.join('bin/rails').to_s

          "bundle exec #{rails} runner -e #{Rails.env} bin/#{option}.rb "
        end
      end
    end
  end
end
