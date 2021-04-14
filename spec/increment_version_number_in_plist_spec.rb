require 'spec_helper'

describe Fastlane::Actions::IncrementVersionNumberInPlistAction do
  describe "Increment Version Number in Info.plist Integration" do
    let (:test_path) { "/tmp/fastlane/tests/fastlane" }
    let (:plist_file) { File.join("plist/", "Info-Release.plist") }

    # Action parameters
    let (:info_plist_file) { File.join(test_path, plist_file) }

    before do
      copy_xcodeproj_fixtures
      copy_info_plist_fixtures
      fake_api_responses
    end

    def current_version
      Fastlane::FastFile.new.parse("lane :test do
        get_info_plist_value(path: '#{info_plist_file}', key: 'CFBundleShortVersionString')
      end").runner.execute(:test)
    end

    it "should set explicitly provided version number to Info.plist" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_plist(version_number: '1.9.4')
      end").runner.execute(:test)

      expect(current_version).to eq("1.9.4")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.9.4")
    end

    it "should bump patch version by default and set it to Info.plist" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_plist
      end").runner.execute(:test)

      expect(current_version).to eq("0.9.15")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.9.15")
    end

    it "should bump patch version and set it to Info.plist" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_plist(bump_type: 'patch')
      end").runner.execute(:test)

      expect(current_version).to eq("0.9.15")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.9.15")
    end

    it "should bump minor version and set it to Info.plist" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_plist(bump_type: 'minor')
      end").runner.execute(:test)

      expect(current_version).to eq("0.10.0")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.10.0")
    end

    it "should omit zero in patch version if omit_zero_patch_version is true" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_plist(bump_type: 'minor', omit_zero_patch_version: true)
      end").runner.execute(:test)

      expect(current_version).to eq("0.10")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.10")
    end

    it "should bump major version and set it to Info.plist" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_plist(bump_type: 'major')
      end").runner.execute(:test)

      expect(current_version).to eq("1.0.0")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.0.0")
    end

    it "should bump version using App Store version as a source" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_plist(bump_type: 'major', version_source: 'appstore')
      end").runner.execute(:test)

      expect(current_version).to eq("3.0.0")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("3.0.0")
    end

    after do
      cleanup_fixtures
    end
  end
end
