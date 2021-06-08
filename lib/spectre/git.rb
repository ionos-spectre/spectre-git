require 'fileutils'
require 'git'
require 'logger'
require 'spectre'


module Spectre
  module Git
    class GitAccess < Spectre::DslClass
      def initialize cfg, logger
        @__logger = logger
        @__cfg = cfg
        @__repo = nil

        url(@__cfg['url'])
        @__cfg['branch'] = 'master' unless @__cfg['branch']
      end

      def url git_url
        url_match = git_url.match /^(?<scheme>http(?:s)?):\/\/(?:(?<user>[^\/:]*):(?<pass>.*)@)?(?<url>.*\/(?<name>[^\/]*)\.git)$/

        raise "invalid git url: '#{git_url}'" unless url_match

        @__cfg['url'] = url_match[:url]
        @__cfg['scheme'] = url_match[:scheme]
        @__cfg['username'] = url_match[:user]
        @__cfg['password'] = url_match[:pass]
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

      def branch name
        @__cfg['branch'] = name
      end

      def clone
        @__cfg['working_dir'] = path = File.join(@__cfg['working_dir'], @__cfg['name'])
        FileUtils.rm_rf(path)
        @__repo = ::Git.clone(get_url, path, branch: @__cfg['branch'], log: @__logger)
      end

      def add path
        @__repo.add(path)
      end

      def add_all
        @__repo.add(all: true)
      end

      def add_tag name, annotate: false, message: nil
        @__repo.add_tag(name, annotate: annotate, message: message)
      end

      def commit message
        @__repo.commit(message)
      end

      def push
        @__repo.push('origin', @__cfg['branch'])
      end

      def pull
        @__repo.pull('origin', @__cfg['branch'])
      end

      def write_file path, content
        full_path = File.join(@__cfg['working_dir'], path)

        file = File.open(full_path, 'w')
        file.write(content)
        file.close

        full_path
      end

      def read_file path
        full_path = File.join(@__cfg['working_dir'], path)
        File.read(full_path)
      end

      def cleanup
        FileUtils.rm_rf(@__cfg['working_dir'])
      end

      private

      def get_url
        cred = @__cfg['username'] ? "#{@__cfg['username']}:#{@__cfg['password']}@" : ''
        "#{@__cfg['scheme']}://#{cred}#{@__cfg['url']}"
      end
    end

    class << self
      @@cfg = {}
      @@logger = ::Logger.new(STDOUT)
      @@last_access = nil

      def git name = nil, &block
        cfg = @@cfg[name] || {}

        cfg['url'] = name if not cfg['url']

        @@last_access = GitAccess.new(cfg, @@logger) if name
        @@last_access.instance_eval &block
      end
    end

    Spectre.register do |config|
      @@logger = ::Logger.new config['log_file'], progname: 'spectre/git'

      if config.key? 'git'
        config['git'].each do |name, cfg|
          @@cfg[name] = cfg
        end
      end
    end

    Spectre.delegate :git, to: self
  end
end