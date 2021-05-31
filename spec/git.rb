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

    expect(cfg['url']).to eq('some-git.com/path/to/repo/example.git')
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

    expect(cfg['url']).to eq('some-git.com/path/to/repo/example.git')
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

    expect(cfg['url']).to eq('some-git.com/path/to/repo/example.git')
    expect(cfg['username']).to eq('someuser')
    expect(cfg['password']).to eq('supersecret')
    expect(cfg['scheme']).to eq('https')

    expect(assembled_url).to eq(url)
  end

  it 'clones a repository' do
    tmp_dir = './tmp'
    clone_dir = File.join(tmp_dir, 'spectre-git')

    FileUtils.rm_rf(tmp_dir)

    begin
      Spectre::Git.git 'https://bitbucket.org/cneubaur/spectre-git.git' do
        working_dir tmp_dir
        clone
      end

      expect(Dir.exist? clone_dir).to eq(true)

    ensure
      FileUtils.rm_rf(tmp_dir)
    end
  end
end