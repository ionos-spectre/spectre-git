# Spectre Git

This is a [spectre](https://bitbucket.org/cneubaur/spectre-core) module which provides some basic git commands for use with spectre.

## Install

```bash
gem install spectre-git
```

## Configure

Add the module to you `spectre.yml`

```yml
include:
 - spectre/git
```

Configure some predefined Git access options in you environment file

```yml
git:
  example:
    url: https://some-git.com/path/to/repo/example.git
    username: dummy
    password: '*****'
```

## Usage

Use the `git` helper method to access a git repository by providing a valid Git URL as a parameter.

```ruby
git 'https://some-git.com/path/to/repo/example.git' do
  username 'dummy'
  password '*****'

  clone

  # Do some file editing

  add 'path/to/file'
  # add_all # Same as git add --all
  commit 'some changes made'
  push
end

# When already connected to a repository, you can ommit the parameter to use the last Git access configuration
git do
  add 'path/to/other_file'
  commit 'another change'
  push
end
```

With a preconfigured Git access use the given name as a parameter

```ruby
git 'example' do
  clone

  # Do some file editing

  add 'path/to/file'
  commit 'some changes made'
  push
end
```