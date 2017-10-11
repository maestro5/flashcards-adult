require 'rails_helper'

describe Card do
  let(:init_card) { Card.new user_id: 1, block_id: 1 }

  context 'when invalid card' do
    test_values =
      [
        # [original_text, translated_text, expected_error]
        ['',      'house', 'Необходимо заполнить поле.'],
        ['',      '',      'Вводимые значения должны отличаться.'],
        ['house', 'house', 'Вводимые значения должны отличаться.'],
        ['дом',   'дом',   'Вводимые значения должны отличаться.'],
        ['hOuse', 'houSe', 'Вводимые значения должны отличаться.'],
        ['Дом',   'доМ',   'Вводимые значения должны отличаться.']
      ]

    test_values.each do |test_value|
      it "create card with original_text: #{test_value[0]} and translated_text: #{test_value[1]}" do
        init_card.assign_attributes(original_text: test_value[0], translated_text: test_value[1])
        expect(init_card.save).to be false
        expect(init_card.errors[:original_text]).to include(test_value[2])
      end
    end

    it 'create card with empty translated text' do
      init_card.assign_attributes(original_text: 'дом', translated_text: '')
      expect(init_card.save).to be false
      expect(init_card.errors[:translated_text]).to include('Необходимо заполнить поле.')
    end
    
    it 'create card without block_id' do
      init_card.assign_attributes(original_text: 'дом', translated_text: 'house', block_id: nil)
      expect(init_card.save).to be false
      expect(init_card.errors[:block_id]).to include('Выберите колоду из выпадающего списка.')
    end

    it 'create card without user_id' do
      init_card.assign_attributes(original_text: 'дом', translated_text: 'house', user_id: nil)
      expect(init_card.save).to be false
      expect(init_card.errors[:user_id]).to include('Ошибка ассоциации.')
    end
  end # invalid original_text

  context 'when valid card' do
    before do
      init_card.assign_attributes(original_text: 'дом', translated_text: 'house')
      init_card.save
    end

    it 'create card errors OK' do
      expect(init_card.errors.any?).to be false
    end

    it 'create card original_text OK' do
      expect(init_card.original_text).to eq('дом')
    end

    it 'create card translated_text OK' do
      expect(init_card.translated_text).to eq('house')
    end

    it 'set_review_date OK' do
      expect(init_card.review_date.strftime('%Y-%m-%d %H:%M')).to eq(Time.zone.now.strftime('%Y-%m-%d %H:%M'))
    end
  end # when valid card

  context 'the state' do
    test_values = 
      [
        # [original_text, translated_text, check_translation, expected_result]
        ['дом',   'house', 'house', true],
        ['house', 'дом',   'дом',   true],
        ['ДоМ',   'hOuSe', 'HousE', true],
        ['hOuSe', 'ДоМ',   'дОм',   true],
        ['дом',   'hous',  'house', true],
        ['house', 'до',    'дом',   true],
        ['дом',   'house', 'RoR',   false],
        ['house', 'дом',   'RoR',   false],
        ['ДоМ',   'hOuSe', 'RoR',   false],
        ['hOuSe', 'ДоМ',   'RoR',   false],
        ['дом',   'hou',   'RoR',   false],
        ['house', 'д',     'RoR',   false]
      ]

    test_values.each do |test_value|
      it "check translation #{test_value[2]} in card with original_text: #{test_value[0]} and  translated_text: #{test_value[1]}" do
        init_card.assign_attributes(original_text: test_value[0], translated_text: test_value[1])
        check_result = init_card.check_translation test_value[2]
        expect(check_result[:state]).to be test_value[3]
      end
    end
  end # the state

  context 'the distance' do
    test_values =
      [
        # [original_text, translated_text, check_translation, expected_distance]
        ['дом',   'hous', 'house', 1],
        ['house', 'до',   'дом',   1]
      ]

    test_values.each do |test_value|
      it "check the levenshtein distance in card with original_text: #{test_value[0]}, translated_text: #{test_value[1]} and check translation: test_value[2]" do
        init_card.assign_attributes(original_text: test_value[0], translated_text: test_value[1])
        check_result = init_card.check_translation test_value[2]
        expect(check_result[:distance]).to be test_value[3]
      end
    end
  end # the distance
end
