require 'rails_helper'

feature "zgloszenia" do

  context "po zalogowaniu" do
    include_context "admin login"

    scenario "sprawdzenie czy jest odnosnik prowadzacy do zgloszen w menu" do
      visit '/issues/'
      click_on('Zgłoszone artykuły')

      expect(page).to have_css(".btn", text: "Nowe zgłoszenie")
    end
	
    scenario "sprawdzenie czy przenosi do strony submission/new" do
      visit '/submissions/'
      click_on('Nowe zgłoszenie')
      
      expect(page).to have_css(".form-group")
    end

    context "redaktor w bazie danych" do
      before do
        Person.create!(name: "Andrzej", surname: "Kapusta",
                       discipline: "filozofia",
                       email: "a.kapusa@gmail.com", roles: ['redaktor'])
      end

      scenario "tworzenie nowego zgloszenia" do
        visit '/submissions/new/'
        within("#new_submission") do
          fill_in "Tytuł", with: "Testowy tytuł zgłoszenia"
          fill_in "Streszczenie", with: "Testowe streszczenie"
          fill_in "Słowa kluczowe", with: "kluczowe kluczeowe slowa"
          fill_in "Title", with: "English title"
          fill_in "Abstract", with: "absbabsba"
          fill_in "Key words", with: "englsh key words"
          select "Andrzej Kapusta", from: "Redaktor"
          select "nadesłany", from: "Status"
        end
        click_button("Utwórz")
    
        expect(page).not_to have_css(".has-error")
        expect(page).to have_content("Testowy tytuł zgłoszenia")
      end

      context "2 zgłoszenia w bazie danych" do
        before do
          Submission.create!(person_id: Person.first, status: "odrzucony", polish_title: "Alicja w krainie czarów", english_title: "Alice 
            in Wonderland", polish_abstract: "Słów parę o tej bajce", english_abstract: "Little about that story", polish_keywords: "alicja",
            received: "19-01-2016", language: "polski")
          Submission.create!(person_id: Person.first, status: "do poprawy", polish_title: "W pustyni i w puszczy", english_title: "Desert 
            and something", polish_abstract: "Porywająca lektura", english_abstract: "Super lecture", polish_keywords: "pustynia",
            received: "19-01-2016", language: "polski")	
        end
      
        scenario "filtrowanie zgłoszeń po statusie" do
          visit "/submissions"
        
          select "odrzucony", from: "Status"
          click_on("Filtruj")

          expect(page).to have_content("Alicja w krainie czarów")
          expect(page).not_to have_content("W pustyni i w puszczy")
        end
      end
    end
  end
end
