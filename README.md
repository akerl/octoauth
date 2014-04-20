octoauth
=========

[![Gem Version](https://img.shields.io/gem/v/octoauth.svg)](https://rubygems.org/gems/octoauth)
[![Dependency Status](https://img.shields.io/gemnasium/akerl/octoauth.svg)](https://gemnasium.com/akerl/octoauth)
[![Code Climate](https://img.shields.io/codeclimate/github/akerl/octoauth.svg)](https://codeclimate.com/github/akerl/octoauth)
[![Coverage Status](https://img.shields.io/coveralls/akerl/octoauth.svg)](https://coveralls.io/r/akerl/octoauth)
[![Build Status](https://img.shields.io/travis/akerl/octoauth.svg)](https://travis-ci.org/akerl/octoauth)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

Authentication wrapper for GitHub's API

## Usage

Get your authentication token quickly and simply:

```
require 'octoauth'

auth = Octoauth.new note: 'my_cool_app'
puts "My token is #{auth.token}"
```

This will prompt the user for a username/password and potentially 2FA token using [userinput](https://github.com/akerl/userinput). A note is required, and is what the token will appear as in the user's GitHub tokens list.

If you want to store this token and reuse it, just drop it into a file. The default file is ~/.octoauth.yml. Subsequent runs with the same file and note will load the same token without prompting the user:

```
auth = Octoauth.new note: 'my_cooler_app', file: :default
puts "My token is #{auth.token}"
auth.save

other_auth = Octoauth.new note: 'other_nice_app', file: '~/.other_app_config.yml'
puts "The other token is #{other_auth.token}"
other_auth.save
```

The above examples get us the basic scope, which means some read-only public access. For other scopes, specify them when creating the token:

```
auth = Octoauth.new note: 'my_app', scopes: ['gist', 'delete_repo']
```

## Installation

    gem install octoauth

## License

octoauth is released under the MIT License. See the bundled LICENSE file for details.

