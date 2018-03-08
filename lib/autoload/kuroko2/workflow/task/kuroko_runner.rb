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
          "bundle exec #{rails} runner -e #{Rails.env} #{kuroko_script}"
        end

        private

        # Try to find target script in mounted project at first.
        # If not exist, fallback to engine
        def kuroko_script
          script_in_project = Rails.root.join("bin/#{option}.rb")
          if File.exist?(script_in_project)
            script_in_project
          else
            Kuroko2::Engine.root.join("bin/#{option}.rb")
          end
        end
      end
    end
  end
end
