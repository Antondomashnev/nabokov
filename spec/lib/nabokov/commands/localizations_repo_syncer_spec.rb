require "nabokov/commands/syncers/repo_syncer"
require "nabokov/git/git_repo"
require "nabokov/helpers/merger"
require "nabokov/helpers/informator"

describe Nabokov::LocalizationsRepoSyncer do
  before(:each) do
    allow(STDOUT).to receive(:puts)
  end

  it "is not an abstract command" do
    expect(Nabokov::LocalizationsRepoSyncer.abstract_command).to be_falsy
  end

  describe "run" do
    context "when the repo is empty" do
      before(:all) do
        @test_git_repo_path = File.expand_path("spec/fixtures/test_repo_syncer")
        @test_git_repo_url = "https://github.com/Antondomashnev/nabokov_example.git"
      end

      before(:each) do
        FileUtils.cp_r("spec/fixtures/test_localizations_repo_syncer/localizations_repo_template", @test_git_repo_path)

        @nabokovfile = Nabokov::Nabokovfile.new("spec/fixtures/nabokovfile_example_without_master_branch.yaml")
        allow(@nabokovfile).to receive(:localizations_repo_local_path).and_return(@test_git_repo_path)
        allow(Nabokov::Nabokovfile).to receive(:new).with(anything).and_return(@nabokovfile)

        underlying_git_repo = object_double(Git::Base)
        @git_repo = Nabokov::GitRepo.new(@test_git_repo_path, @test_git_repo_url, underlying_git_repo)
        allow(Nabokov::GitRepo).to receive(:new).with(anything, anything).and_return(@git_repo)
        allow(@git_repo).to receive(:log).with(1).and_return("1234567890")

        @informator = object_double(Nabokov::Informator)
        @fake_git_repo = object_double(Nabokov::GitRepo)
        @merger = Nabokov::Merger.new(@informator, @fake_git_repo)
        allow(Nabokov::Merger).to receive(:new).with(anything, anything, anything).and_return(@merger)

        allow_any_instance_of(Nabokov::Informator).to receive(:wait_for_return)
      end

      after(:each) do
        FileUtils.rm_rf(Dir.glob("spec/fixtures/test_repo_syncer"))
      end

      context "when files don't have any changes to sync" do
        before do
          allow(@git_repo).to receive(:changes?).and_return(false)
        end

        it "runs the commands in the correct order" do
          expect(@git_repo).to receive(:init).ordered
          expect(@git_repo).to receive(:checkout_branch).with("master").ordered
          expect(@git_repo).to receive(:checkout_branch).with("nabokov/temporary_branch").ordered
          expect(@git_repo).to receive(:add).with("#{@test_git_repo_path}/en.strings").ordered
          expect(@git_repo).to receive(:add).with("#{@test_git_repo_path}/de.strings").ordered
          expect(@git_repo).to receive(:checkout_branch).with("master").ordered
          expect(@git_repo).to receive(:pull).ordered
          expect(@git_repo).to receive(:delete_branch).with("nabokov/temporary_branch").ordered

          Nabokov::LocalizationsRepoSyncer.run(["--nabokovfile=spec/fixtures/nabokovfile_example_without_master_branch.yaml"])
        end
      end

      context "when files have changes to sync" do
        before do
          allow(@git_repo).to receive(:changes?).and_return(true)
        end

        context "when merge doesn't have conflicts" do
          before do
            allow(@merger).to receive(:merge).with("master", "nabokov/temporary_branch").and_return(Nabokov::MergerResult::SUCCEEDED)
          end

          it "runs the commands in the correct order" do
            expect(@git_repo).to receive(:init).ordered
            expect(@git_repo).to receive(:checkout_branch).with("master").ordered
            expect(@git_repo).to receive(:checkout_branch).with("nabokov/temporary_branch").ordered
            expect(@git_repo).to receive(:add).with("#{@test_git_repo_path}/en.strings").ordered
            expect(@git_repo).to receive(:commit).with("Nabokov localization file 'en' update...").ordered
            expect(@git_repo).to receive(:add).with("#{@test_git_repo_path}/de.strings").ordered
            expect(@git_repo).to receive(:commit).with("Nabokov localization file 'de' update...").ordered
            expect(@git_repo).to receive(:checkout_branch).with("master").ordered
            expect(@git_repo).to receive(:pull).ordered
            expect(@git_repo).to receive(:push).ordered
            expect(@git_repo).to receive(:delete_branch).with("nabokov/temporary_branch").ordered

            Nabokov::LocalizationsRepoSyncer.run(["--nabokovfile=spec/fixtures/nabokovfile_example_without_master_branch.yaml"])
          end
        end

        context "when merge has conflicts" do
          context "when merge is aborted" do
            before do
              allow(@merger).to receive(:merge).with("master", "nabokov/temporary_branch").and_return(Nabokov::MergerResult::ABORTED)
            end

            it "runs the commands in the correct order" do
              expect(@git_repo).to receive(:init).ordered
              expect(@git_repo).to receive(:checkout_branch).with("master").ordered
              expect(@git_repo).to receive(:checkout_branch).with("nabokov/temporary_branch").ordered
              expect(@git_repo).to receive(:add).with("#{@test_git_repo_path}/en.strings").ordered
              expect(@git_repo).to receive(:commit).with("Nabokov localization file 'en' update...").ordered
              expect(@git_repo).to receive(:add).with("#{@test_git_repo_path}/de.strings").ordered
              expect(@git_repo).to receive(:commit).with("Nabokov localization file 'de' update...").ordered
              expect(@git_repo).to receive(:checkout_branch).with("master").ordered
              expect(@git_repo).to receive(:pull).ordered
              expect(@git_repo).to receive(:delete_branch).with("nabokov/temporary_branch").ordered

              Nabokov::LocalizationsRepoSyncer.run(["--nabokovfile=spec/fixtures/nabokovfile_example_without_master_branch.yaml"])
            end
          end

          context "when merge is succeeded" do
            before do
              allow(@merger).to receive(:merge).with("master", "nabokov/temporary_branch").and_return(Nabokov::MergerResult::SUCCEEDED)
            end

            it "runs the commands in the correct order" do
              expect(@git_repo).to receive(:init).ordered
              expect(@git_repo).to receive(:checkout_branch).with("master").ordered
              expect(@git_repo).to receive(:checkout_branch).with("nabokov/temporary_branch").ordered
              expect(@git_repo).to receive(:add).with("#{@test_git_repo_path}/en.strings").ordered
              expect(@git_repo).to receive(:commit).with("Nabokov localization file 'en' update...").ordered
              expect(@git_repo).to receive(:add).with("#{@test_git_repo_path}/de.strings").ordered
              expect(@git_repo).to receive(:commit).with("Nabokov localization file 'de' update...").ordered
              expect(@git_repo).to receive(:checkout_branch).with("master").ordered
              expect(@git_repo).to receive(:pull).ordered
              expect(@git_repo).to receive(:push).ordered
              expect(@git_repo).to receive(:delete_branch).with("nabokov/temporary_branch").ordered

              Nabokov::LocalizationsRepoSyncer.run(["--nabokovfile=spec/fixtures/nabokovfile_example_without_master_branch.yaml"])
            end
          end
        end
      end
    end
  end
end
