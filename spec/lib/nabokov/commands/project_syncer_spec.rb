require 'nabokov/commands/syncers/project_syncer'
require 'fileutils'

describe Nabokov::ProjectSyncer do
  before(:each) do
    allow(STDOUT).to receive(:puts)
  end

  it 'is not an abstract command' do
    expect(Nabokov::ProjectSyncer.abstract_command).to be_falsy
  end

  describe "run" do
    context "when localiztions repo containes all localization files from the project repo" do
      before(:all) do
        @test_localizations_repo_path = "spec/fixtures/test_project_syncer/localizations_repo"
        @test_project_repo_path = "spec/fixtures/test_project_syncer/project_repo"
      end

      before(:each) do
        prepare_repo = proc do |repo_path, fixtures_path|
          FileUtils.mkdir(repo_path)
          repo = Git.init(repo_path)
          repo.config('user.name', 'nabokov')
          repo.config('user.email', 'nabokov@nabokov.com')
          FileUtils.cp_r(fixtures_path, repo_path)
          repo.add()
          repo.commit("initial commit")
        end

        prepare_repo.call(@test_localizations_repo_path, "spec/fixtures/test_project_syncer/localizations_repo_fixtures/.")
        prepare_repo.call(@test_project_repo_path, "spec/fixtures/test_project_syncer/project_repo_fixtures/.")

        @mock_nabokovfile = Nabokov::Nabokovfile.new("spec/fixtures/test_project_syncer/project_repo/nabokovfile.yaml")
        allow(@mock_nabokovfile).to receive(:localizations_repo_local_path).and_return(@test_localizations_repo_path)

        @mock_localizations_repo = Nabokov::GitRepo.new(@mock_nabokovfile.localizations_repo_local_path, @mock_nabokovfile.localizations_repo_url)
        allow(@mock_localizations_repo).to receive(:pull)

        @mock_project_repo = Nabokov::GitRepo.new(@mock_nabokovfile.project_local_path)

        allow(Nabokov::Nabokovfile).to receive(:new).with("spec/fixtures/test_project_syncer/project_repo/nabokovfile.yaml").and_return(@mock_nabokovfile)
        allow(Nabokov::GitRepo).to receive(:new).with(@mock_nabokovfile.localizations_repo_local_path, @mock_nabokovfile.localizations_repo_url).and_return(@mock_localizations_repo)
        allow(Nabokov::GitRepo).to receive(:new).with(@mock_nabokovfile.project_local_path).and_return(@mock_project_repo)
      end

      after do
        FileUtils.rm_rf(Dir.glob(@test_localizations_repo_path))
        FileUtils.rm_rf(Dir.glob(@test_project_repo_path))
      end

      it "should merge remote localizations with project's localization" do
        Nabokov::ProjectSyncer.run(['--nabokovfile=spec/fixtures/test_project_syncer/project_repo/nabokovfile.yaml'])

        expected_en_localization_strings = ["\"hello\" = \"Hello\";\n", "\"bye\" = \"Bye\";\n"]
        actual_en_localization_strings = []
        File.readlines("#{@test_project_repo_path}/en.strings").each do |line|
          actual_en_localization_strings << line
        end
        expect(actual_en_localization_strings).to eql(expected_en_localization_strings)

        expected_de_localization_strings = ["\"hello\" = \"Hallo\";\n", "\"bye\" = \"Tschuss\";\n"]
        actual_de_localization_strings = []
        File.readlines("#{@test_project_repo_path}/de.strings").each do |line|
          actual_de_localization_strings << line
        end
        expect(actual_de_localization_strings).to eql(expected_de_localization_strings)
      end
    end
  end
end
