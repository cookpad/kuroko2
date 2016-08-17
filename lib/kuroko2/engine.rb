module Kuroko2
  class Engine < ::Rails::Engine
    isolate_namespace Kuroko2

    config.before_configuration do
      require 'kaminari'
      require 'chrono'
    end

    config.autoload_paths << root.join('lib')
  end
end
