require 'nabokov/core/nabokovfile_content_validator'
require 'nabokov/core/nabokovfile_keys'

describe Nabokov::NabokovfileContentValidator do
  before do
    @valid_hash = {
        Nabokov::NabokovfileKeyes.localizations_repo => {Nabokov::NabokovfileKeyes.localizations_repo_url => "https://github.com/nabokov/nabokov", Nabokov::NabokovfileKeyes.localizations_repo_master_branch => "nabokov_master"},
        Nabokov::NabokovfileKeyes.localization_file_paths => {"en" => "spec/fixtures/en.strings", "de" => "spec/fixtures/de.strings"}
    }
  end

  context "when the git repo URL is not in valid URL format" do
    it "raises an error" do
      @valid_hash[Nabokov::NabokovfileKeyes.localizations_repo][Nabokov::NabokovfileKeyes.localizations_repo_url] = 'bla_bla_bla'
      validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
      expect { validator.validate }.to raise_error("'bla_bla_bla' is not a valid URL")
    end
  end

  context "when the git repo URL valid but scheme is not https" do
    it "raises an exception" do
      @valid_hash[Nabokov::NabokovfileKeyes.localizations_repo][Nabokov::NabokovfileKeyes.localizations_repo_url] = 'http://github.com/nabokov/nabokov'
      validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
      expect { validator.validate }.to raise_error("Please use 'https://...' instead of 'http://github.com/nabokov/nabokov' only supports encrypted requests")
    end
  end

  context "when the localizations_repo is not a type of Hash" do
    context "when string" do
      it "raises an error" do
        @valid_hash[Nabokov::NabokovfileKeyes.localizations_repo] = 'param:pam'
        validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
        expect { validator.validate }.to raise_error("Localizations repo must be a type of Hash")
      end
    end

    context "when array" do
      it "raises an error" do
        @valid_hash[Nabokov::NabokovfileKeyes.localizations_repo] = [ "key", "value" ]
        validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
        expect { validator.validate }.to raise_error("Localizations repo must be a type of Hash")
      end
    end

    context "when number" do
      it "raises an error" do
        @valid_hash[Nabokov::NabokovfileKeyes.localizations_repo] = 10
        validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
        expect { validator.validate }.to raise_error("Localizations repo must be a type of Hash")
      end
    end
  end

  context "when the localizations is not a type of Hash" do
    context "when string" do
      it "raises an error" do
        @valid_hash[Nabokov::NabokovfileKeyes.localization_file_paths] = 'param:pam'
        validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
        expect { validator.validate }.to raise_error("Localizations must be a type of Hash")
      end
    end

    context "when array" do
      it "raises an error" do
        @valid_hash[Nabokov::NabokovfileKeyes.localization_file_paths] = [ "key", "value" ]
        validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
        expect { validator.validate }.to raise_error("Localizations must be a type of Hash")
      end
    end

    context "when number" do
      it "raises an error" do
        @valid_hash[Nabokov::NabokovfileKeyes.localization_file_paths] = 10
        validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
        expect { validator.validate }.to raise_error("Localizations must be a type of Hash")
      end
    end
  end

  context "when the localizations array contains file that does not exist" do
    it "raises an error" do
      @valid_hash[Nabokov::NabokovfileKeyes.localization_file_paths] = {"en" => "spec/fixtures/en.strings",
                                                                        "de" => "spec/fixtures/fr.strings"}
      validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
      expect { validator.validate }.to raise_error("Couldn't find strings file at 'spec/fixtures/fr.strings'")
    end
  end

  context "when the hash is valid" do
    it "doesn't raise anything" do
      validator = Nabokov::NabokovfileContentValidator.new(@valid_hash)
      validator.validate
    end
  end
end
