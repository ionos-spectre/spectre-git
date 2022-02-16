require 'fileutils'
require 'spectre/git'

RSpec.describe Spectre::Git do
  it 'configures git access with https' do
    url = 'https://some-git.com/path/to/repo/example.git'
    cfg = nil
    assembled_url = ''

    Spectre::Git.git url do
      cfg = @__cfg
      assembled_url = get_url()
    end

    expect(cfg['url_path']).to eq('some-git.com/path/to/repo/example.git')
    expect(cfg['scheme']).to eq('https')

    expect(assembled_url).to eq(url)
  end

  it 'configures git access with http' do
    url = 'http://some-git.com/path/to/repo/example.git'
    cfg = nil
    assembled_url = ''

    Spectre::Git.git url do
      cfg = @__cfg
      assembled_url = get_url()
    end

    expect(cfg['url_path']).to eq('some-git.com/path/to/repo/example.git')
    expect(cfg['scheme']).to eq('http')

    expect(assembled_url).to eq(url)
  end

  it 'configures git access with username and password' do
    url = 'https://someuser:supersecret@some-git.com/path/to/repo/example.git'
    cfg = nil
    assembled_url = ''

    Spectre::Git.git url do
      cfg = @__cfg
      assembled_url = get_url()
    end

    expect(cfg['url_path']).to eq('some-git.com/path/to/repo/example.git')
    expect(cfg['username']).to eq('someuser')
    expect(cfg['password']).to eq('supersecret')
    expect(cfg['scheme']).to eq('https')

    expect(assembled_url).to eq(url)
  end

  it 'configures git access with preconfigured username and password' do
    cfg = nil
    assembled_url = ''

    Spectre.configure({
      'git' => {
        'example' => {
          'url' => 'https://some-git.com/path/to/repo/example.git',
          'username' => 'someuser',
          'password' => 'supersecret',
        }
      }
    })

    Spectre::Git.git 'example' do
      cfg = @__cfg
      assembled_url = get_url()
    end

    expect(cfg['url_path']).to eq('some-git.com/path/to/repo/example.git')
    expect(cfg['username']).to eq('someuser')
    expect(cfg['password']).to eq('supersecret')
    expect(cfg['scheme']).to eq('https')

    expect(assembled_url).to eq('https://someuser:supersecret@some-git.com/path/to/repo/example.git')
  end

  it 'clones a repository' do
    class Spectre::Git::GitAccess
      def run cmd, log: true
      end
    end

    Spectre::Git.git 'https://github.com/ionos-spectre/example.git' do
      branch 'main'

      working_dir 'tmp'

      clone

      add 'dummy.txt'
      commit 'Dummy file updated'
      push
    end
  end
end