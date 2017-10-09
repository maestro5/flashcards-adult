require 'rails_helper'
require 'support/helpers/trainer_helper.rb'
include TrainerHelper

describe Dashboard::TrainerController do
  describe 'review_card' do
    let!(:user) { create(:user) }
    let!(:block) { create(:block, user: user) }
    let(:init_card) { create(:card, user: user, block: block) }
    before { @controller.send(:auto_login, user) }

    describe 'correct translation' do
      context 'repeat=1' do
        before do
          init_card.update_attributes(interval: 1, repeat: 1, efactor: 2.5, quality: 5)
        end

        it 'repeat=1 quality=5' do
          card = check_review_card(init_card, 'house', 1)
          expect(card.review_date.strftime('%Y-%m-%d %H:%M'))
            .to eq((Time.zone.now + 1.days).strftime('%Y-%m-%d %H:%M'))
          expect(card.interval).to eq(6)
          expect(card.repeat).to eq(2)
          expect(card.attempt).to eq(1)
        end

        it 'repeat=1 quality=5' do
          card = check_review_card(init_card, 'house', 1)
          expect(card.efactor).to eq(2.6)
          expect(card.quality).to eq(5)
        end

        it 'repeat=1 quality=4' do
          card = check_review_card(init_card, 'RoR', 1)
          card = check_review_card(card, 'house', 1)
          expect(card.efactor).to eq(2.18)
          expect(card.quality).to eq(4)
        end

        it 'repeat=1 quality=3' do
          card = check_review_card(init_card, 'RoR', 2)
          card = check_review_card(card, 'house', 1)
          expect(card.efactor).to eq(1.5)
          expect(card.quality).to eq(3)
        end

        it 'repeat=1 quality=3' do
          card = check_review_card(init_card, 'RoR', 3)
          card = check_review_card(card, 'house', 1)
          expect(card.efactor).to eq(1.3)
          expect(card.quality).to eq(3)
        end

        it 'repeat=1-3 quality=5' do
          card = check_review_card(init_card, 'house', 1)
          card.update(review_date: Time.zone.now)
          card = check_review_card(card, 'house', 1)
          card.update(review_date: Time.zone.now)
          card = check_review_card(card, 'house', 1)
          expect(card.review_date.strftime('%Y-%m-%d %H:%M'))
            .to eq((Time.zone.now + 16.days).strftime('%Y-%m-%d %H:%M'))
          expect(card.interval).to eq(45)
          expect(card.repeat).to eq(4)
          expect(card.attempt).to eq(1)
          expect(card.efactor).to eq(2.8)
          expect(card.quality).to eq(5)
        end
      end # repeat=1

      context 'repeat=2' do
        before do
          init_card.update_attributes(interval: 6, repeat: 2, efactor: 2.6, quality: 5)
        end

        it 'repeat=2 quality=5' do
          card = check_review_card(init_card, 'house', 1)
          expect(card.review_date.strftime('%Y-%m-%d %H:%M')).
              to eq((Time.zone.now + 6.days).strftime('%Y-%m-%d %H:%M'))
          expect(card.interval).to eq(16)
          expect(card.repeat).to eq(3)
          expect(card.attempt).to eq(1)
        end

        it 'repeat=2 quality=5' do
          card = check_review_card(init_card, 'house', 1)
          expect(card.efactor).to eq(2.7)
          expect(card.quality).to eq(5)
        end

        it 'repeat=2 quality=4' do
          card = check_review_card(init_card, 'RoR', 1)
          card = check_review_card(card, 'house', 1)
          expect(card.efactor).to eq(2.28)
          expect(card.quality).to eq(4)
        end

        it 'repeat=2 quality=3' do
          card = check_review_card(init_card, 'RoR', 2)
          card = check_review_card(card, 'house', 1)
          expect(card.efactor).to eq(1.6)
          expect(card.quality).to eq(3)
        end

        it 'repeat=2 quality=3' do
          card = check_review_card(init_card, 'RoR', 3)
          card = check_review_card(card, 'house', 1)
          expect(card.efactor).to eq(1.3)
          expect(card.quality).to eq(3)
        end
      end # repeat=2

      context 'repeat=3' do
        before do
          init_card.update_attributes(interval: 16, repeat: 3, efactor: 2.7, quality: 5)
        end
    
        it 'repeat=3 quality=5' do
          card = check_review_card(init_card, 'house', 1)
          expect(card.review_date.strftime('%Y-%m-%d %H:%M')).
              to eq((Time.zone.now + 16.days).strftime('%Y-%m-%d %H:%M'))
          expect(card.interval).to eq(45)
          expect(card.repeat).to eq(4)
          expect(card.attempt).to eq(1)
        end

        it 'repeat=3 quality=5' do
          card = check_review_card(init_card, 'house', 1)
          expect(card.efactor).to eq(2.8)
          expect(card.quality).to eq(5)
        end

        it 'repeat=3 quality=4' do
          card = check_review_card(init_card, 'RoR', 1)
          card = check_review_card(card, 'house', 1)
          expect(card.efactor).to eq(2.38)
          expect(card.quality).to eq(4)
        end

        it 'repeat=3 quality=3' do
          card = check_review_card(init_card, 'RoR', 2)
          card = check_review_card(card, 'house', 1)
          expect(card.efactor).to eq(1.7)
          expect(card.quality).to eq(3)
        end

        it 'repeat=3 quality=3' do
          card = check_review_card(init_card, 'RoR', 3)
          card = check_review_card(card, 'house', 1)
          expect(card.efactor).to eq(1.3)
          expect(card.quality).to eq(3)
        end
      end # repeat=3
    end # correct translation

    describe 'incorrect translation' do
      before do
        init_card.update_attributes(interval: 1, repeat: 1, efactor: 2.5, quality: 4)
      end

      it 'repeat=1 attempt=1' do
        card = check_review_card(init_card, 'RoR', 1)
        expect(card.interval).to eq(1)
        expect(card.repeat).to eq(1)
        expect(card.attempt).to eq(2)
        expect(card.efactor).to eq(2.18)
        expect(card.quality).to eq(2)
      end

      it 'repeat=1 attempt=2' do
        card = check_review_card(init_card, 'RoR', 2)
        expect(card.interval).to eq(1)
        expect(card.repeat).to eq(1)
        expect(card.attempt).to eq(3)
        expect(card.efactor).to eq(1.64)
        expect(card.quality).to eq(1)
      end

      it 'repeat=1 attempt=3' do
        card = check_review_card(init_card, 'RoR', 3)
        expect(card.interval).to eq(1)
        expect(card.repeat).to eq(1)
        expect(card.attempt).to eq(4)
        expect(card.efactor).to eq(1.3)
        expect(card.quality).to eq(0)
      end
    end # incorrect translation

    describe 'correct and incorrect translation' do
      before do
        init_card.update_attributes(interval: 1, repeat: 1, efactor: 2.5, quality: 4)
      end

      it 'repeat=1-3 quality=4' do
        card = check_review_card(init_card, 'house', 1)
        card.update(review_date: Time.zone.now)
        card = check_review_card(card, 'house', 1)
        card.update(review_date: Time.zone.now)
        card = check_review_card(card, 'RoR', 1)
        card = check_review_card(card, 'house', 1)
        expect(card.review_date.strftime('%Y-%m-%d %H:%M'))
          .to eq((Time.zone.now + 1.days).strftime('%Y-%m-%d %H:%M'))
        expect(card.interval).to eq(6)
        expect(card.repeat).to eq(2)
        expect(card.attempt).to eq(1)
        expect(card.efactor).to eq(2.38)
        expect(card.quality).to eq(4)
      end

      it 'repeat=1-3 quality=5' do
        card = check_review_card(init_card, 'house', 1)
        card.update(review_date: Time.zone.now)
        card = check_review_card(card, 'RoR', 1)
        card = check_review_card(card, 'house', 1)
        card.update(review_date: Time.zone.now)
        card = check_review_card(card, 'house', 1)
        expect(card.review_date.strftime('%Y-%m-%d %H:%M'))
          .to eq((Time.zone.now + 6.days).strftime('%Y-%m-%d %H:%M'))
        expect(card.interval).to eq(14)
        expect(card.repeat).to eq(3)
        expect(card.attempt).to eq(1)
        expect(card.efactor).to eq(2.38)
        expect(card.quality).to eq(5)
      end

      it 'repeat=3 attempt=4' do
        init_card.update_attributes(interval: 16, repeat: 3, efactor: 2.7, quality: 5)
        card = check_review_card(init_card, 'RoR', 3)
        card = check_review_card(card, 'house', 1)
        expect(card.review_date.strftime('%Y-%m-%d %H:%M'))
          .to eq((Time.zone.now + 1.days).strftime('%Y-%m-%d %H:%M'))
        expect(card.interval).to eq(6)
        expect(card.repeat).to eq(2)
        expect(card.attempt).to eq(1)
        expect(card.efactor).to eq(1.3)
        expect(card.quality).to eq(3)
      end
    end # correct and incorrect translation
  end # review_card
end
