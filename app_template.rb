# rails new your_kuroko2_application --database=mysql --skip-turbolinks --skip-javascript -m https://raw.githubusercontent.com/cookpad/kuroko2/master/app_template.rb

gsub_file 'Gemfile', /^gem 'turbolinks'.+/, ""
gsub_file 'Gemfile', /^gem 'jbuilder'.+/, ""
gsub_file 'Gemfile', /^gem 'jquery-rails'.+/, ""
gsub_file 'config/database.yml', "encoding: utf8", "encoding: utf8mb4"

gem 'kuroko2'

gem_group :development do
  gem 'foreman'
end

route 'mount Kuroko2::Engine => "/"'

create_file "config/kuroko2.yml", <<-EOF
default: &default
  url: 'http://localhost:3000'
  action_mailer:
    delivery_method: 'test'
  execution_logger:
    type: 'Void'
  custom_tasks:
#    custom_task1: 'CustomTask1'
  notifiers:
    mail:
      mail_from: 'Kuroko2 <no-reply@example.com>'
      mail_to: "kuroko@example.com"
    slack:
      webhook_url: 'https://localhost/test/slack'
    hipchat:
      api_token: 'token'
      options:
#        api_version: 'v2'
#        server_url: 'https://api.example.com'
    webhook:
      secret_token: '<%= ENV["WEBHOOK_SECRET_TOKEN"] %>'
  api_basic_authentication_applications:
    test_client_name: 'secret_key'
  app_authentication:
    google_oauth2:
      client_id: '<%= ENV["GOOGLE_CLIENT_ID"] %>'
      client_secret: '<%= ENV["GOOGLE_CLIENT_SECRET"] %>'
      options:
        hd: '<%= ENV["GOOGLE_HOSTED_DOMAIN"] %>'
  extensions:
#    controller:
#      - DummyExtension
development:
  <<: *default

test:
  <<: *default

production:
  <<: *default
  url: 'https://kuroko2.example.com'
#  action_mailer:
#    delivery_method: 'smtp'
#    smtp_settings:
#      address: ''
#      port:    25
#      domain:  ''
#  execution_logger:
#    type: 'CloudWatchLogs'
#    option:
#      group_name: 'kuroko2'
EOF


create_file "Procfile", <<-EOF
rails: ./bin/rails s -p 3000
executor: ./bin/rails runner Kuroko2::Servers::CommandExecutor.new.run
scheduler: ./bin/rails runner Kuroko2::Servers::JobScheduler.new.run
processor: ./bin/rails runner Kuroko2::Servers::WorkflowProcessor.new.run
EOF

inject_into_file "app/assets/config/manifest.js", after: "//= link_directory ../stylesheets .css\n" do
  "//= link kuroko2_manifest.js"
end

run 'bundle install'
rake 'kuroko2:install:migrations'
rake 'db:create'
rake 'db:migrate'

say <<-SAY
============================================================================
  Kuroko2 application is now installed and mounts at '/'
============================================================================
SAY
