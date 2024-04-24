require 'fileutils'
require 'stringio'

module Spectre
  CONFIG = {
    'git' => {
      'example' => {
        'url' => 'https://github.com/ionos-spectre/example.git',
      }
    }
  }
end

require_relative '../lib/spectre/git'

RSpec.describe Spectre::Git do
  before do
    stdin = double
    stdout = double
    stderr = double
    wait_thr_value = double
    wait_thr = double

    allow(stdout).to receive(:gets).and_return('')
    allow(stdout).to receive(:close)
    allow(stderr).to receive(:gets).and_return(nil)
    allow(stderr).to receive(:close)
    allow(wait_thr_value).to receive(:exitstatus).and_return(0)
    allow(wait_thr).to receive(:value).and_return(wait_thr_value)

    allow(Open3).to receive(:popen3).and_return([stdin, stdout, stderr, wait_thr])

    working_dir = File.expand_path File.join(File.dirname(__FILE__), '../tmp/example')
    opts = { chdir: working_dir }
    
    expect(Open3).to receive(:popen3).with("git clone --branch main https://github.com/ionos-spectre/example.git #{working_dir}", opts)
    expect(Open3).to receive(:popen3).with('git add "dummy.txt"', opts)
    expect(Open3).to receive(:popen3).with('git commit -m "Dummy file updated"', opts)
    expect(Open3).to receive(:popen3).with('git push', opts)
  end

  it 'operate on git repo' do
    Spectre::Git.git 'https://github.com/ionos-spectre/example.git' do
      branch 'main'

      working_dir 'tmp'

      clone

      add 'dummy.txt'
      commit 'Dummy file updated'
      push
    end
  end

  it 'operate on git repo with preconfig' do
    Spectre::Git.git 'example' do
      branch 'main'

      working_dir 'tmp'

      clone

      add 'dummy.txt'
      commit 'Dummy file updated'
      push
    end
  end
end
