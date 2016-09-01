require "nabokov/models/strings_file"

describe Nabokov::StringsFile do
  it "has a .strings extension" do
    expect(Nabokov::StringsFile.extension).to eql("strings")
  end
end
