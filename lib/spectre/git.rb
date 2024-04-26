require 'open3'
require 'fileutils'
require 'logger'

module Spectre
  module Git
    class GitAccess
      def initialize cfg, logger
        @__logger = logger
        @__cfg = cfg
        @__repo_path = nil

        url(@__cfg['url'])
        @__cfg['branch'] = 'master' unless @__cfg['branch']
      end

      def url git_url
        url_match = git_url
          .match(%r{^(?<scheme>http(?:s)?)://(?:(?<user>[^/:]*):(?<pass>.*)@)?(?<url>.*/(?<name>[^/]*)\.git)$})

        raise "invalid git url: '#{git_url}'" unless url_match

        @__cfg['url_path'] = url_match[:url]
        @__cfg['scheme'] = url_match[:scheme]
        @__cfg['username'] = url_match[:user] unless @__cfg['username']
        @__cfg['password'] = url_match[:pass] unless @__cfg['password']
        @__cfg['name'] = url_match[:name] unless @__cfg['name']
        @__cfg['working_dir'] = './tmp' unless @__cfg['working_dir']
      end

      def username user
        @__cfg['username'] = user
      end

      def password pass
        @__cfg['password'] = pass
      end

      def working_dir path
        @__cfg['working_dir'] = path if path
        @__cfg['working_dir']
      end

      def cert file_path
        @__cfg['cert'] = file_path
      end

      def branch name
        @__cfg['branch'] = name
      end

      def clone
        @__repo_path = File.absolute_path File.join(@__cfg['working_dir'], @__cfg['name'])

        if File.exist? @__repo_path
          FileUtils.rm_rf(@__repo_path)
          @__logger.debug("repo path '#{@__repo_path}' removed")
        end

        FileUtils.mkpath(@__repo_path)
        @__logger.debug("repo path '#{@__repo_path}' created")

        clone_cmd = ['git', 'clone']
        clone_cmd << '--branch'
        clone_cmd << @__cfg['branch']

        if @__cfg['cert']
          clone_cmd << '--config'
          clone_cmd << "http.sslCAInfo=#{@__cfg['cert']}"
        end

        clone_cmd << build_url
        clone_cmd << @__repo_path

        clone_cmd = clone_cmd.join(' ')

        @__logger.info(clone_cmd.gsub(%r{:([^\:\@/]*)@}, ':*****@').to_s)

        run(clone_cmd, log: false)
      end

      def add path
        run("git add \"#{path}\"")
      end

      def add_all
        run('git add --all')
      end

      def tag name, message: nil
        run("git tag -a -m \"#{message}\" \"#{name}\"")
      end

      def commit message
        run("git commit -m \"#{message}\"")
      end

      def push
        run('git push')
      end

      def pull
        run('git pull')
      end

      def write_file path, content
        full_path = File.join(@__repo_path, path)

        file = File.open(full_path, 'w')
        file.write(content)
        file.close

        full_path
      end

      def read_file path
        full_path = File.join(@__repo_path, path)
        File.read(full_path)
      end

      def cleanup
        FileUtils.rm_rf(@__repo_path)
      end

      def run cmd, log: true
        _stdin, stdout, stderr, wait_thr = Open3.popen3(cmd, chdir: @__repo_path)

        @__logger.info(cmd) if log

        _output = stdout.gets(nil)
        stdout.close

        error = stderr.gets(nil)
        stderr.close

        raise error unless wait_thr.value.exitstatus.zero?
      end

      private

      def build_url
        cred = @__cfg['username'] ? "#{@__cfg['username']}:#{@__cfg['password']}@" : ''
        "#{@__cfg['scheme']}://#{cred}#{@__cfg['url_path']}"
      end
    end

    class << self
      @@config = defined?(Spectre::CONFIG) ? Spectre::CONFIG['git'] || {} : {}

      def logger
        @@logger ||= defined?(Spectre.logger) ? Spectre.logger : Logger.new($stdout)
      end

      @@last_access = nil

      def git(name = nil, &)
        config = @@config[name] || {}

        config['url'] = name unless config['url']

        @@last_access = GitAccess.new(config, logger) if name
        @@last_access.instance_eval(&)
      end
    end
  end
end
