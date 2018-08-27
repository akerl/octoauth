octoauth
=========

[![Gem Version](https://img.shields.io/gem/v/octoauth.svg)](https://rubygems.org/gems/octoauth)
[![Build Status](https://img.shields.io/circleci/project/akerl/octoauth/master.svg)](https://circleci.com/gh/akerl/octoauth)
[![Coverage Status](https://img.shields.io/codecov/c/github/akerl/octoauth.svg)](https://codecov.io/github/akerl/octoauth)
[![Code Quality](https://img.shields.io/codacy/648fd8ebe3374dd4acc5449b8922f2e0.svg)](https://www.codacy.com/app/akerl/octoauth)
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

Multiple files can be specified, and it will try them in order looking for a valid token. If this fails, it will use the first file listed for any future saving of tokens:

```
auth = Octoauth.new note: 'my_app', files: ['./.octoauth.yml', '/etc/octoauth', :default]
```

The above examples get us the basic scope, which means some read-only public access. For other scopes, specify them when creating the token:

```
auth = Octoauth.new note: 'my_app', scopes: ['gist', 'delete_repo']
```

If you're trying to use this with a GitHub Enterprise deployment, you can specify an alternate API endpoint:

```
auth = Octoauth.new note: 'enterprise_app', api_endpoint: 'https://sekrit.codez.com/api/v3/'
```

If an alternate endpoint is provided, that string is included as part of the saved config, so you can generate a token for GitHub and multiple alternate endpoints with the same note in the same config file.

## Installation

    gem install octoauth

## License

octoauth is released under the MIT License. See the bundled LICENSE file for details.

