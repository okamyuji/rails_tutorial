# frozen_string_literal: true

# ユーザーモデルのテスト
# spec/models/user_spec.rb

require 'rails_helper'

RSpec.describe User, type: :model do
  # 関連付けのテスト
  describe 'associations' do
    it { should have_many(:articles).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
  end

  # バリデーションのテスト
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(50) }
  end

  # ロールのテスト
  describe 'roles' do
    it { should define_enum_for(:role).with_values(member: 0, editor: 1, admin: 2) }

    describe '#admin?' do
      context 'when user is admin' do
        let(:user) { build(:user, :admin) }

        it 'returns true' do
          expect(user.admin?).to be true
        end
      end

      context 'when user is not admin' do
        let(:user) { build(:user) }

        it 'returns false' do
          expect(user.admin?).to be false
        end
      end
    end

    describe '#editor_or_above?' do
      context 'when user is admin' do
        let(:user) { build(:user, :admin) }

        it 'returns true' do
          expect(user.editor_or_above?).to be true
        end
      end

      context 'when user is editor' do
        let(:user) { build(:user, :editor) }

        it 'returns true' do
          expect(user.editor_or_above?).to be true
        end
      end

      context 'when user is member' do
        let(:user) { build(:user) }

        it 'returns false' do
          expect(user.editor_or_above?).to be false
        end
      end
    end
  end

  # スコープのテスト
  describe 'scopes' do
    let!(:admin) { create(:user, :admin) }
    let!(:editor) { create(:user, :editor) }
    let!(:member) { create(:user) }

    describe '.admins' do
      it 'returns only admin users' do
        expect(User.admins).to include(admin)
        expect(User.admins).not_to include(editor, member)
      end
    end

    describe '.editors' do
      it 'returns only editor users' do
        expect(User.editors).to include(editor)
        expect(User.editors).not_to include(admin, member)
      end
    end

    describe '.members' do
      it 'returns only member users' do
        expect(User.members).to include(member)
        expect(User.members).not_to include(admin, editor)
      end
    end
  end

  # インスタンスメソッドのテスト
  describe '#display_name' do
    context 'when name is present' do
      let(:user) { build(:user, name: 'John Doe') }

      it 'returns the name' do
        expect(user.display_name).to eq('John Doe')
      end
    end

    context 'when name is blank' do
      let(:user) { build(:user, name: '', email: 'john@example.com') }

      it 'returns the email username' do
        expect(user.display_name).to eq('john')
      end
    end
  end

  # コールバックのテスト
  describe 'callbacks' do
    describe 'before_save' do
      let(:user) { build(:user, email: 'TEST@EXAMPLE.COM') }

      it 'downcases the email' do
        user.save
        expect(user.email).to eq('test@example.com')
      end
    end

    describe 'after_initialize' do
      let(:user) { User.new }

      it 'sets default role to member' do
        expect(user.role).to eq('member')
      end
    end
  end

  # ファクトリのテスト
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end

    it 'has a valid admin factory' do
      expect(build(:user, :admin)).to be_valid
    end

    it 'has a valid factory with articles' do
      user = create(:user, :with_articles, articles_count: 5)
      expect(user.articles.count).to eq(5)
    end
  end
end

