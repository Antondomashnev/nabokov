require 'nabokov/core/nabokovfile_content_validator'
require 'nabokov/core/nabokovfile_keys'

describe Nabokov::NabokovfileContentValidator do
  before do
    @valid_hash = {
        Nabokov::NabokovfileKeyes.localizations_repo_url => 'https://github.com/nabokov/nabokov',
        Nabokov::NabokovfileKeyes.localization_file_paths => {"en" => "spec/fixtures/en.strings",
                                                              "de" => "spec/fixtures/de.strings"}
    }
  end

  it "raises an exception if the git repo URL is not in valid URL format" do
    @valid_hash[Nabokov::NabokovfileKeyes.localizations_repo_url] = 'bla_bla_bla'
    validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
    expect { validator.validate }.to raise_error("'bla_bla_bla' is not a valid URL")
  end

  it "raises an exception if the git repo URL valid but scheme is not https" do
    @valid_hash[Nabokov::NabokovfileKeyes.localizations_repo_url] = 'http://github.com/nabokov/nabokov'
    validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
    expect { validator.validate }.to raise_error("Please use 'https://...' instead of 'http://github.com/nabokov/nabokov' only supports encrypted requests")
  end

  it "raises an exception if the localizations is not a type of Hash" do
    @valid_hash[Nabokov::NabokovfileKeyes.localization_file_paths] = 'param:pam'
    validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
    expect { validator.validate }.to raise_error("Localizations must be a type of Hash")

    @valid_hash[Nabokov::NabokovfileKeyes.localization_file_paths] = [ "key", "value" ]
    validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
    expect { validator.validate }.to raise_error("Localizations must be a type of Hash")

    @valid_hash[Nabokov::NabokovfileKeyes.localization_file_paths] = 10
    validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
    expect { validator.validate }.to raise_error("Localizations must be a type of Hash")
  end

  it "raises an exception if the localizations array contains file that does not exist" do
    @valid_hash[Nabokov::NabokovfileKeyes.localization_file_paths] = {"en" => "spec/fixtures/en.strings",
                                                                      "de" => "spec/fixtures/fr.strings"}
    validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
    expect { validator.validate }.to raise_error("Couldn't find strings file at 'spec/fixtures/fr.strings'")
  end

  it "validates the valid hash" do
    validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
    validator.validate
  end
end
