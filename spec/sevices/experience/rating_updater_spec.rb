require 'rails_helper'

RSpec.describe Experience::RatingUpdater do
  subject { Experience::RatingUpdater.call(target_experience) }

  let(:target_experience) { experience }

  let(:experience) { create(:experience, avg_rating: current_rating) }
  let(:current_rating) { 4.0 }
  let(:new_rating) { 4.1 }

  before do
    allow(Experience::RatingCalculator).to receive(:call).with(experience).and_return(new_rating)
  end

  context 'success' do
    it 'updates experience rating' do
      expect { subject }.to change { experience.avg_rating }.from(current_rating).to(new_rating)
    end

    it 'returns true' do
      expect(subject).to be_truthy
    end
  end

  context 'when provided experience is blank' do
    let(:target_experience) { nil }

    it 'returns nil' do
      expect(subject).to eq(nil)
    end
  end
end
