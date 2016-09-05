require 'kuroko2'
require 'serverengine'

if Rails.env.development?
  ActionMailer::Base.logger = Kuroko2.logger
end

options = {
  worker_type: 'process',
  workers:     Kuroko2::Command::Executor.num_workers,
  daemonize:   Rails.env.production?,
  log:         Rails.env.production? ? Rails.root.join("log/command-executor.log").to_s : $stdout,
  log_level:   Rails.env.production? ? :info : :debug,
  pid_path:    Rails.root.join('tmp/pids/command-executor.pid').to_s,
  supervisor:  Rails.env.production?,

  worker_graceful_kill_timeout: -1,
}

server = ServerEngine.create(nil, Kuroko2::Command::Executor, options)
server.run
