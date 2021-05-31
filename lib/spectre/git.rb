require 'git'
require 'logger'
require 'spectre'


module Spectre
  module Git
    module Version
      MAJOR = 1
      MINOR = 0
      TINY  = 0
    end

    VERSION = [Version::MAJOR, Version::MINOR, Version::TINY].compact * '.'

    class GitAccess
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
      end

      def username user
        @__cfg['username'] = user
      end

      def password pass
        @__cfg['password'] = pass
      end

      def working_dir path
        @__cfg['working_dir'] = path
      end

      def branch name
        @__cfg['branch'] = name
      end

      def clone
        @__repo = Git.clone(@__cfg['url'], @__cfg['name'], branch: @__cfg['branch'], log: @__logger)
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

      private

      def get_url
        cred = @__cfg['username'] ? "#{@__cfg['username']}:#{@__cfg['password']}@" : ''
        "#{@__cfg['scheme']}://#{cred}#{@__cfg['url']}"
      end
    end

    class << self
      @@cfg = {}
      @@logger = Logger.new(STDOUT)
      @@last_access = nil

      def git name, &block
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