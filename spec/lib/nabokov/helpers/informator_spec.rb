require 'nabokov/helpers/informator'

describe Nabokov::Informator do
  let(:ui) { object_double(Cork::Board.new(silent: true, verbose: true)) }

  describe "show_prompt" do
    it "prints bold greed symbol" do
      expect(ui).to receive(:print).with("> ".bold.green)
      Nabokov::Informator.new(ui).show_prompt
    end
  end

  describe "say" do
    it "prints plain message" do
      expect(ui).to receive(:puts).with("Hey!")
      Nabokov::Informator.new(ui).say("Hey!")
    end
  end

  describe "inform" do
    it "prints green message" do
      expect(ui).to receive(:puts).with("Nabokov is working".green)
      Nabokov::Informator.new(ui).inform("Nabokov is working")
    end
  end

  describe "error" do
    it "prints red message" do
      expect(ui).to receive(:puts).with("Something went wrong".red)
      Nabokov::Informator.new(ui).error("Something went wrong")
    end
  end

  describe "warn" do
    it "prints yellow message" do
      expect(ui).to receive(:puts).with("Something went wrong".yellow)
      Nabokov::Informator.new(ui).warn("Something went wrong")
    end
  end
end
