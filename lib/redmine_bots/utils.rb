module RedmineBots
  module Utils
    def self.daemonize(name, logger: Logger.new(STDOUT))
      tries ||= 0
      tries += 1

      Process.daemon(true, true) if Rails.env.production?
      if ENV['PID_DIR']
        pid_dir = ENV['PID_DIR']
        PidFile.new(piddir: pid_dir, pidfile: "#{name}.pid")
      else
        PidFile.new(piddir: Rails.root.join('tmp', 'pids'), pidfile: "#{name}.pid")
      end

      Signal.trap('TERM') do
        at_exit { logger.error 'Aborted with TERM signal' }
        abort
      end

      Signal.trap('HUP') do
        at_exit { logger.error 'Aborted with HUP signal' }
        abort
      end

      yield

    rescue PidFile::DuplicateProcessError => e
      logger.error "#{e.class}: #{e.message}"
      pid = e.message.match(/Process \(.+ - (\d+)\) is already running./)[1].to_i

      logger.info "Kill process with pid: #{pid}"

      Process.kill('HUP', pid)
      if tries < 4
        logger.info 'Waiting for 5 seconds...'
        sleep 5
        logger.info 'Retry...'
        retry
      end
    end
  end
end
