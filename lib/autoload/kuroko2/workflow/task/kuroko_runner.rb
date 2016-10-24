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
          kuroko_script = Kuroko2::Engine.root.join("bin/#{option}.rb")
          "bundle exec #{rails} runner -e #{Rails.env} #{kuroko_script}"
        end
      end
    end
  end
end
