# Spectre Git

[![Build Status](https://www.travis-ci.com/cneubaur/spectre-git.svg?branch=master)](https://www.travis-ci.com/cneubaur/spectre-git)

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

# Functions

The following functions are available within the `git` block.

| Method | Arguments | Multiple | Description |
| -------| ----------| -------- | ----------- |
| `username` | `string` | no | The username for Git authentication |
| `password` | `string` | no | The password for Git authentication |
| `branch` | `string` | no | The git branch to operatate on. If ommitted `master` will be used. |
| `clone` | _none_ | no | Clones the configured repository |
| `add` | `string` | yes | Adds a file to the stage. `git add <file_path>` |
| `add_all` | _none_ | no | Adds all files to the stage. `git add --all` |
| `commit` | `string` | yes | Creates a new commit with the given message. `git commit -m '<message>'` |
| `push` | _none_ | no | Adds a file to the stage. `git push` |
| `read_file` | `string` | yes | Reads the content of a file within the local Git repository. Given path is relative to checkout directory. Returns the file content. |
| `write_file` | `string`, `string` | yes | Writes the given content to a file within the local Git repository. Given path is relative to checkout directory. |
