require 'rails_helper'

RSpec.describe Experience::RatingCalculator do
  subject { Experience::RatingCalculator.call(target_experience) }

  let(:target_experience) { experience }

  let!(:experience) { create(:experience) }

  let!(:exp_feedback_1) { create(:feedback, experience: experience, rating: 5) }
  let!(:exp_feedback_2) { create(:feedback, experience: experience, rating: 2) }
  let!(:exp_feedback_3) { create(:feedback, experience: experience, rating: 1) }

  let!(:another_experience) { create(:experience) }

  let!(:another_feedback_1) { create(:feedback, experience: another_experience, rating: 2) }

  context 'success' do
    it 'calculates average rating for provided experience' do
      expect(subject).to eq(2.7)
    end
  end

  context 'when provided experience is blank' do
    let(:target_experience) { nil }

    it 'returns nil' do
      expect(subject).to eq(nil)
    end
  end

  context 'when provided experience has no feedback' do
    let(:target_experience) { create(:experience) }

    it 'returns nil' do
      expect(subject).to eq(nil)
    end
  end
end
