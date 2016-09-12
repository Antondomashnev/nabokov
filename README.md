# Nabokov

[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/Antondomashnev/nabokov/blob/master/LICENSE)
[![codebeat badge](https://codebeat.co/badges/cd388b60-f4e0-4b2d-8278-a7d2764d642d)](https://codebeat.co/projects/github-com-antondomashnev-nabokov)
![travis badge](https://travis-ci.org/Antondomashnev/nabokov.svg?branch=master)
[![Gem](https://img.shields.io/gem/v/nabokov.svg?style=flat)](http://rubygems.org/gems/nabokov)

Move mobile localization process up to the next level .

## Getting Started

Add this line to your application's [Gemfile](https://guides.cocoapods.org/using/a-gemfile.html):

```ruby
gem 'nabokov'
```

Next, use Bundler to install the gem.

```shell
bundle install
```

## Where the idea come from

Nabokov is has been developed in order to improve and simplify the process of the mobile app localization (specifically iOS, but the idea can be applied to Android and probably WP as well). One of the way to manage localizations is to create a separate repo with `strings` files. Then flow can be described in the way like this:
* Developer uploads all strings files into that repo
* Translator updates all untranslated files
* Developer updates project's strings files with the new one from repo
* After a while developer adds new strings that have to be translated
* Goto step 1  
  
Also once it comes to the conflicts - remote repo has updated translation which is not on the project yet, and project has new strings which are not translated yet, the whole thing becomes a pain at least that was what I feel.

## Why nabokov could be useful 

With Nabokov the flow above could be replaced with two commands:
* `bundle exec nabokov sync localizations` - uploads strings files on to remote localizations repo
* `bundle exec nabokov sync project` - apply remote localizations into project  
  
When it comes to the merge conflicts - nabokov allows user to user the preferable merge tool which is smoothify the process.

## Usage

### Nabokovfile

The projects settings for Nabokov are stored in the files `Nabokov.yaml` which has `YAML` format and places in the directory with the `Gemfile`. The structure of the file is explained below:
```
localizations_repo:
  url: 'url to the localizations repo'
  master_branch: 'master branch of the localizations repo'

project_repo:
  localizations:
    :en: 'relative path to the English localization strings file in the project'
    :another: 'relative path to the another localization strings file in the project'
  local_path: 'relative path to the project'
```

### Initial set up

After running `bundle exec nabokov setup` strings files uploading to the remote repo will be done automatically via `pre-commit git hook`. Remember that the project synchronization still has to be done manually by running `bundle exec nabokov sync project`

### Synchronization

If you need to synchronize the strings with the remote repo manually of without `pre-commit git hook`, you can use the `bundle exec nabokov sync localizations` command. When you want to update the project's strings files with the remote one you can run `bundle exec nabokov sync project` command.

## Current status

This project is in the early development stage but is ready for production since even in a case of data corruption the valid state can be rolled back via git. 

## Behind the scene

This is my first ruby project except for small experiments on the local machine before. So please bare it in mind and I would really appreciate any point about code style or better way to implement something.

## Contributing

I’d love to see your ideas for improving this library! The best way to contribute is by submitting a pull request. I’ll do my best to respond to your patch as soon as possible. You can also submit a [new GitHub issue](https://github.com/Antondomashnev/nabokov/issues/new) if you find bugs or have questions.

## License

This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs.
