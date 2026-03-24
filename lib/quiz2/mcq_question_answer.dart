import 'dart:math';

// Class to represent a single MCQ question
class MCQQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;

  MCQQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });
}

// Class to manage the questions for all sections
class QuizQuestionBank {
  // Maps to store questions by section
  static final Map<String, List<MCQQuestion>> _questions = {
    'General Knowledge': _generalKnowledgeQuestions,
    'World History': _worldHistoryQuestions,
    'Science & Technology': _scienceTechnologyQuestions,
    'Current Affairs': _currentAffairsQuestions,
  };

  // Method to get random questions for a section
  static List<MCQQuestion> getRandomQuestionsForSection(
      String sectionId, int count) {
    final sectionName = _getSectionNameById(sectionId);
    final allQuestions = _questions[sectionName] ?? [];

    if (allQuestions.isEmpty) {
      return [];
    }

    // Create a copy of the questions list to avoid modifying the original
    final questionsCopy = List<MCQQuestion>.from(allQuestions);

    // Shuffle the questions
    questionsCopy.shuffle(Random());

    // Return the requested number of questions or all if less than requested
    return questionsCopy.take(count).toList();
  }

  // Helper method to map section ID to section name
  static String _getSectionNameById(String id) {
    switch (id) {
      case '1':
        return 'General Knowledge';
      case '2':
        return 'World History';
      case '3':
        return 'Science & Technology';
      case '4':
        return 'Current Affairs';
      default:
        return '';
    }
  }

  // General Knowledge Questions (50 questions)
  static final List<MCQQuestion> _generalKnowledgeQuestions = [
    MCQQuestion(
      id: 'gk1',
      question: 'Which planet is known as the Red Planet?',
      options: ['Venus', 'Mars', 'Jupiter', 'Mercury'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk2',
      question: 'What is the largest ocean on Earth?',
      options: [
        'Atlantic Ocean',
        'Indian Ocean',
        'Arctic Ocean',
        'Pacific Ocean'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'gk3',
      question: 'How many elements are in the periodic table?',
      options: ['92', '118', '108', '120'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk4',
      question: 'What is the smallest country in the world?',
      options: ['Monaco', 'Vatican City', 'Liechtenstein', 'San Marino'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk5',
      question: 'Which is the largest internal organ in the human body?',
      options: ['Brain', 'Liver', 'Heart', 'Lungs'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk6',
      question: 'Which of these is not a primary color?',
      options: ['Red', 'Blue', 'Green', 'Yellow'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'gk7',
      question: 'Who wrote "Romeo and Juliet"?',
      options: [
        'Charles Dickens',
        'William Shakespeare',
        'Jane Austen',
        'Mark Twain'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk8',
      question: 'Which is the longest river in the world?',
      options: ['Amazon', 'Nile', 'Mississippi', 'Yangtze'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk9',
      question: 'How many sides does a heptagon have?',
      options: ['5', '6', '7', '8'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk10',
      question: 'What is the capital of Australia?',
      options: ['Sydney', 'Melbourne', 'Canberra', 'Perth'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk11',
      question: 'Which famous scientist developed the theory of relativity?',
      options: [
        'Isaac Newton',
        'Albert Einstein',
        'Nikola Tesla',
        'Stephen Hawking'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk12',
      question: 'What is the chemical symbol for gold?',
      options: ['Go', 'Gd', 'Au', 'Ag'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk13',
      question: 'What is the tallest mountain in the world?',
      options: ['K2', 'Mount Everest', 'Kangchenjunga', 'Makalu'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk14',
      question: 'Which of these is not a mammal?',
      options: ['Dolphin', 'Platypus', 'Penguin', 'Bat'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk15',
      question: 'Who painted the Mona Lisa?',
      options: [
        'Vincent van Gogh',
        'Pablo Picasso',
        'Leonardo da Vinci',
        'Michelangelo'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk16',
      question: 'What is the largest desert in the world?',
      options: [
        'Gobi Desert',
        'Sahara Desert',
        'Antarctic Desert',
        'Arabian Desert'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk17',
      question: 'Which country is home to the kangaroo?',
      options: ['New Zealand', 'South Africa', 'Australia', 'Brazil'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk18',
      question: 'What is the currency of Japan?',
      options: ['Yuan', 'Won', 'Yen', 'Ringgit'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk19',
      question: 'Which planet has the most moons?',
      options: ['Jupiter', 'Saturn', 'Uranus', 'Neptune'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk20',
      question: 'What is the smallest bone in the human body?',
      options: ['Stapes', 'Phalanges', 'Femur', 'Radius'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'gk21',
      question: 'Which of these is not a noble gas?',
      options: ['Helium', 'Neon', 'Nitrogen', 'Argon'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk22',
      question: 'Who is the author of "To Kill a Mockingbird"?',
      options: [
        'Harper Lee',
        'J.K. Rowling',
        'Ernest Hemingway',
        'Virginia Woolf'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'gk23',
      question: 'What is the largest species of shark?',
      options: [
        'Great White Shark',
        'Whale Shark',
        'Tiger Shark',
        'Hammerhead Shark'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk24',
      question: 'Which is the hottest planet in our solar system?',
      options: ['Mercury', 'Venus', 'Mars', 'Jupiter'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk25',
      question: 'What is the capital of Canada?',
      options: ['Toronto', 'Vancouver', 'Montreal', 'Ottawa'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'gk26',
      question: 'Which of these instruments is not part of a string quartet?',
      options: ['Violin', 'Viola', 'Cello', 'Clarinet'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'gk27',
      question: 'What is the largest species of big cat?',
      options: ['Lion', 'Tiger', 'Jaguar', 'Leopard'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk28',
      question: 'What is the only food that never spoils?',
      options: ['Peanut butter', 'Dark chocolate', 'Honey', 'Rice'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk29',
      question: 'In which country would you find the Great Barrier Reef?',
      options: ['Brazil', 'Mexico', 'Australia', 'Thailand'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk30',
      question: 'Which blood type is known as the universal donor?',
      options: ['A+', 'B-', 'AB+', 'O-'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'gk31',
      question: 'What is the chemical symbol for silver?',
      options: ['Si', 'Sr', 'Ag', 'Sv'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk32',
      question: 'Who wrote "Pride and Prejudice"?',
      options: [
        'Charlotte Brontë',
        'Jane Austen',
        'Emily Dickinson',
        'Virginia Woolf'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk33',
      question: 'Which is not a dwarf planet?',
      options: ['Pluto', 'Eris', 'Ceres', 'Europa'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'gk34',
      question: 'What is the hardest natural substance on Earth?',
      options: ['Diamond', 'Titanium', 'Platinum', 'Graphene'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'gk35',
      question: 'What does DNA stand for?',
      options: [
        'Deoxyribonucleic Acid',
        'Diribonuclear Acid',
        'Deoxyribose Nucleic Acid',
        'Digital Nucleic Arrangement'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'gk36',
      question: 'Which of these countries is not in Africa?',
      options: ['Chad', 'Somalia', 'Suriname', 'Namibia'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk37',
      question: 'What is the largest bird in the world?',
      options: ['Albatross', 'Ostrich', 'Eagle', 'Condor'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk38',
      question: 'Which element has the chemical symbol "K"?',
      options: ['Krypton', 'Potassium', 'Kelium', 'Ketium'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk39',
      question: 'Who painted "Starry Night"?',
      options: [
        'Claude Monet',
        'Salvador Dali',
        'Vincent van Gogh',
        'Pablo Picasso'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk40',
      question: 'What is the capital of Brazil?',
      options: ['Rio de Janeiro', 'São Paulo', 'Brasília', 'Salvador'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk41',
      question: 'Which of these is not a type of cloud?',
      options: ['Cumulus', 'Stratus', 'Nimbus', 'Celsius'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'gk42',
      question: 'What is the study of fungi called?',
      options: ['Botany', 'Mycology', 'Entomology', 'Zoology'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk43',
      question: 'Which planet is closest to the sun?',
      options: ['Venus', 'Earth', 'Mars', 'Mercury'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'gk44',
      question: 'What is the largest organ in the human body?',
      options: ['Brain', 'Liver', 'Heart', 'Skin'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'gk45',
      question: 'Which animal is known as the "Ship of the Desert"?',
      options: ['Horse', 'Camel', 'Donkey', 'Elephant'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk46',
      question: 'What is the national flower of Japan?',
      options: ['Rose', 'Lotus', 'Cherry Blossom', 'Tulip'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk47',
      question: 'What is the oldest known living tree species on Earth?',
      options: ['Sequoia', 'Ginkgo Biloba', 'Bristlecone Pine', 'Baobab'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk48',
      question: 'Which is the largest moon in our solar system?',
      options: ['Titan', 'Europa', 'Ganymede', 'Luna'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk49',
      question: 'What is the chemical symbol for sodium?',
      options: ['So', 'Sd', 'Na', 'Sm'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk50',
      question: 'Which of these languages does not use the Latin alphabet?',
      options: ['Spanish', 'German', 'Greek', 'Portuguese'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk51',
      question: 'Which country has the longest coastline in the world?',
      options: ['Russia', 'Canada', 'Australia', 'United States'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk52',
      question: 'What is the capital of Argentina?',
      options: ['Santiago', 'Lima', 'Buenos Aires', 'Montevideo'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk53',
      question:
          'What is the name of the biggest technology company in South Korea?',
      options: ['Sony', 'Huawei', 'Samsung', 'LG'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk54',
      question: 'Which is the largest bird of prey?',
      options: [
        'Golden Eagle',
        'California Condor',
        'Andean Condor',
        'Philippine Eagle'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk55',
      question:
          'What is the main ingredient in traditional Japanese miso soup?',
      options: ['Seaweed', 'Fermented soybean paste', 'Fish stock', 'Rice'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk56',
      question: 'Which instrument has 47 strings and 7 pedals?',
      options: ['Piano', 'Harp', 'Cello', 'Harpsichord'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk57',
      question:
          'What is the world\'s most widely spoken language by number of native speakers?',
      options: ['English', 'Spanish', 'Mandarin Chinese', 'Hindi'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk58',
      question:
          'Which famous physicist was born on the death anniversary of Galileo?',
      options: [
        'Isaac Newton',
        'Albert Einstein',
        'Stephen Hawking',
        'Niels Bohr'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk59',
      question: 'What is the official language of Brazil?',
      options: ['Spanish', 'Portuguese', 'English', 'French'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk60',
      question: 'Which gemstone is the hardest mineral on Earth?',
      options: ['Ruby', 'Emerald', 'Diamond', 'Sapphire'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk61',
      question: 'Which country consumes the most coffee per capita?',
      options: ['Italy', 'United States', 'Finland', 'Colombia'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk62',
      question: 'What is the largest living structure on Earth?',
      options: [
        'The Amazon Rainforest',
        'The Great Barrier Reef',
        'The Giant Sequoia',
        'The California Redwood Forest'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk63',
      question:
          'Which of these countries is not a permanent member of the UN Security Council?',
      options: ['France', 'Russia', 'Germany', 'China'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk64',
      question: 'What is the main ingredient in guacamole?',
      options: ['Avocado', 'Tomato', 'Lime', 'Cilantro'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'gk65',
      question: 'Which city is known as the "Eternal City"?',
      options: ['Athens', 'Jerusalem', 'Rome', 'Cairo'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk66',
      question: 'What is the name of the longest river in Europe?',
      options: ['Danube', 'Volga', 'Thames', 'Rhine'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk67',
      question: 'What is the smallest independent country in the world?',
      options: ['Monaco', 'San Marino', 'Vatican City', 'Liechtenstein'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk68',
      question: 'Which of these creatures has the longest lifespan?',
      options: [
        'Giant tortoise',
        'Elephant',
        'Bowhead whale',
        'Greenland shark'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'gk69',
      question: 'What is the largest organ of the human body?',
      options: ['Liver', 'Brain', 'Skin', 'Lungs'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk70',
      question: 'What is the only continent with no active volcanoes?',
      options: ['North America', 'Africa', 'Australia', 'Europe'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk71',
      question: 'What is the most widely practiced religion in the world?',
      options: ['Christianity', 'Islam', 'Hinduism', 'Buddhism'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'gk72',
      question: 'Which mountain range separates Europe from Asia?',
      options: ['Alps', 'Andes', 'Urals', 'Himalayas'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk73',
      question: 'What is the largest island in the world?',
      options: ['Greenland', 'New Guinea', 'Borneo', 'Madagascar'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'gk74',
      question: 'What is the main substance used to make glass?',
      options: ['Sand', 'Stone', 'Clay', 'Petroleum'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'gk75',
      question: 'Which of these animals does not hibernate?',
      options: ['Bears', 'Bats', 'Squirrels', 'Penguins'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'gk76',
      question: 'Who is known as the father of modern physics?',
      options: [
        'Isaac Newton',
        'Albert Einstein',
        'Nikola Tesla',
        'Galileo Galilei'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk77',
      question: 'What is the common name for sodium chloride?',
      options: ['Sugar', 'Baking soda', 'Salt', 'Chalk'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk78',
      question: 'What is the unit of electric current?',
      options: ['Watt', 'Volt', 'Ampere', 'Ohm'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk79',
      question: 'Which of these fruits is not a berry?',
      options: ['Blueberry', 'Banana', 'Strawberry', 'Grape'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk80',
      question: 'What is the largest type of big cat in the world?',
      options: ['Lion', 'Jaguar', 'Tiger', 'Leopard'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk81',
      question: 'What is the capital of New Zealand?',
      options: ['Auckland', 'Wellington', 'Christchurch', 'Queenstown'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk82',
      question:
          'Which of these instruments is not part of a standard orchestra?',
      options: ['Harp', 'Piano', 'Saxophone', 'Violin'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk83',
      question: 'What is the world\'s most expensive spice by weight?',
      options: ['Vanilla', 'Saffron', 'Cardamom', 'Cinnamon'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk84',
      question: 'Which country produces the most coffee in the world?',
      options: ['Colombia', 'Vietnam', 'Brazil', 'Ethiopia'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk85',
      question: 'What is the study of mushrooms called?',
      options: ['Mycology', 'Phycology', 'Dendrology', 'Entomology'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'gk86',
      question: 'Which element has the chemical symbol Au?',
      options: ['Silver', 'Gold', 'Aluminum', 'Argon'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk87',
      question:
          'What is the name of the thin layer of gases that surrounds Earth?',
      options: ['Stratosphere', 'Ionosphere', 'Atmosphere', 'Ozone layer'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk88',
      question: 'Which is the highest waterfall in the world?',
      options: [
        'Niagara Falls',
        'Victoria Falls',
        'Angel Falls',
        'Iguazu Falls'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk89',
      question: 'What is the capital of Canada?',
      options: ['Toronto', 'Montreal', 'Vancouver', 'Ottawa'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'gk90',
      question: 'Which planet has the Great Red Spot?',
      options: ['Mars', 'Venus', 'Jupiter', 'Saturn'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk91',
      question: 'Who painted the Mona Lisa?',
      options: [
        'Vincent van Gogh',
        'Pablo Picasso',
        'Leonardo da Vinci',
        'Michelangelo'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk92',
      question: 'What is the hardest natural substance on Earth?',
      options: ['Diamond', 'Titanium', 'Platinum', 'Tungsten'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'gk93',
      question: 'Which country is home to the Great Barrier Reef?',
      options: ['Brazil', 'Australia', 'Thailand', 'Mexico'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk94',
      question: 'What is the largest desert in the world?',
      options: [
        'Sahara Desert',
        'Arabian Desert',
        'Gobi Desert',
        'Antarctic Desert'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'gk95',
      question: 'Which blood type is considered the universal donor?',
      options: ['A+', 'AB-', 'O-', 'B+'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk96',
      question: 'What is the official language of Brazil?',
      options: ['Spanish', 'English', 'Portuguese', 'French'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk97',
      question: 'Which chess piece can only move diagonally?',
      options: ['Rook', 'Knight', 'Bishop', 'Pawn'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk98',
      question: 'What is the largest species of shark?',
      options: [
        'Great White Shark',
        'Whale Shark',
        'Hammerhead Shark',
        'Tiger Shark'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'gk99',
      question: 'What is the smallest prime number?',
      options: ['0', '1', '2', '3'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'gk100',
      question:
          'Which famous scientist developed the theory of general relativity?',
      options: [
        'Isaac Newton',
        'Albert Einstein',
        'Stephen Hawking',
        'Niels Bohr'
      ],
      correctOptionIndex: 1,
    ),
  ];

  // World History Questions (50 questions)
  static final List<MCQQuestion> _worldHistoryQuestions = [
    MCQQuestion(
      id: 'wh1',
      question: 'Which empire was ruled by Genghis Khan?',
      options: [
        'Roman Empire',
        'Mongol Empire',
        'Ottoman Empire',
        'Byzantine Empire'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh2',
      question: 'In which year did World War I begin?',
      options: ['1914', '1917', '1910', '1919'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh3',
      question: 'Who was the first Emperor of China?',
      options: ['Kublai Khan', 'Qin Shi Huang', 'Sun Yat-sen', 'Mao Zedong'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh4',
      question: 'Which ancient civilization built the Machu Picchu?',
      options: ['Maya', 'Aztec', 'Inca', 'Olmec'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh5',
      question: 'Who was the first woman to win a Nobel Prize?',
      options: [
        'Marie Curie',
        'Mother Teresa',
        'Rosa Parks',
        'Florence Nightingale'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh6',
      question: 'The French Revolution began in which year?',
      options: ['1789', '1799', '1769', '1804'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh7',
      question: 'Which country was formerly known as Persia?',
      options: ['Iraq', 'Egypt', 'Iran', 'Turkey'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh8',
      question: 'Who was the first President of the United States?',
      options: [
        'Thomas Jefferson',
        'John Adams',
        'George Washington',
        'Abraham Lincoln'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh9',
      question: 'The ancient city of Rome was founded in which year?',
      options: ['753 BC', '500 BC', '1000 BC', '250 BC'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh10',
      question: "Which pharaoh's tomb was discovered nearly intact in 1922?",
      options: ['Ramses II', 'Cleopatra', 'Tutankhamun', 'Akhenaten'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh11',
      question:
          'In which year did Christopher Columbus first reach the Americas?',
      options: ['1492', '1498', '1512', '1476'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh12',
      question:
          'The Cold War was primarily a conflict between which two countries?',
      options: [
        'UK and Germany',
        'China and Japan',
        'USA and USSR',
        'France and Italy'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh13',
      question: 'Which city hosted the first modern Olympic Games in 1896?',
      options: ['Paris', 'London', 'Athens', 'Rome'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh14',
      question:
          'Who was the first female Prime Minister of the United Kingdom?',
      options: [
        'Theresa May',
        'Margaret Thatcher',
        'Angela Merkel',
        'Indira Gandhi'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh15',
      question: 'The Renaissance period began in which country?',
      options: ['France', 'Germany', 'England', 'Italy'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'wh16',
      question: 'Which treaty ended World War I?',
      options: [
        'Treaty of Versailles',
        'Treaty of Paris',
        'Treaty of London',
        'Treaty of Rome'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh17',
      question:
          'The Great Wall of China was built primarily during which dynasty?',
      options: ['Han Dynasty', 'Ming Dynasty', 'Qin Dynasty', 'Tang Dynasty'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh18',
      question:
          'Who was the leader of the Soviet Union during most of World War II?',
      options: [
        'Vladimir Lenin',
        'Joseph Stalin',
        'Leon Trotsky',
        'Nikita Khrushchev'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh19',
      question: 'In which year did the Berlin Wall fall?',
      options: ['1985', '1989', '1991', '1993'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh20',
      question:
          'The ancient city of Carthage was located in what is now which country?',
      options: ['Italy', 'Greece', 'Tunisia', 'Egypt'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh21',
      question:
          'Which historical figure is known for the theory of evolution by natural selection?',
      options: [
        'Albert Einstein',
        'Isaac Newton',
        'Charles Darwin',
        'Galileo Galilei'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh22',
      question: 'The Battle of Hastings took place in which year?',
      options: ['1066', '1215', '1415', '1588'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh23',
      question: 'Which European country had the largest colonial empire?',
      options: ['Spain', 'France', 'Britain', 'Portugal'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh24',
      question: 'Who was the first emperor of the Roman Empire?',
      options: ['Julius Caesar', 'Augustus', 'Nero', 'Constantine'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh25',
      question: 'The Magna Carta was signed in which year?',
      options: ['1215', '1315', '1415', '1515'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh26',
      question:
          'Which civilization developed the first known system of writing?',
      options: ['Sumerian', 'Egyptian', 'Greek', 'Chinese'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh27',
      question:
          'Who was the Russian mystic who influenced the Romanov royal family?',
      options: ['Nostradamus', 'Rasputin', 'Tolstoy', 'Lenin'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh28',
      question: 'The Industrial Revolution began in which country?',
      options: ['United States', 'France', 'Great Britain', 'Germany'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh29',
      question:
          'Which country was NOT part of the Allied Powers during World War II?',
      options: ['United States', 'Soviet Union', 'Italy', 'Great Britain'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh30',
      question: 'Who was the first person to circumnavigate the globe?',
      options: [
        'Christopher Columbus',
        'Ferdinand Magellan',
        'Vasco da Gama',
        'Francis Drake'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh31',
      question:
          'What was the name of the first atomic bomb dropped on Hiroshima?',
      options: ['Fat Man', 'Little Boy', 'Trinity', 'Enola Gay'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh32',
      question: 'Who wrote "The Communist Manifesto"?',
      options: [
        'Vladimir Lenin',
        'Joseph Stalin',
        'Karl Marx and Friedrich Engels',
        'Mao Zedong'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh33',
      question: 'Which event triggered the start of World War I?',
      options: [
        'The invasion of Poland',
        'The sinking of the Lusitania',
        'The assassination of Archduke Franz Ferdinand',
        'The bombing of Pearl Harbor'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh34',
      question:
          'The ancient Olympic Games were held in honor of which Greek god?',
      options: ['Apollo', 'Hermes', 'Zeus', 'Poseidon'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh35',
      question:
          'Who was the first African American president of the United States?',
      options: ['Barack Obama', 'Joe Biden', 'Bill Clinton', 'George W. Bush'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh36',
      question:
          'Which of these was NOT one of the Seven Wonders of the Ancient World?',
      options: [
        'Great Pyramid of Giza',
        'Colosseum of Rome',
        'Hanging Gardens of Babylon',
        'Lighthouse of Alexandria'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh37',
      question:
          'What was the name of the plague that devastated Europe in the 14th century?',
      options: [
        'The White Death',
        'The Great Plague',
        'The Black Death',
        'The Red Plague'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh38',
      question: 'Who was the last emperor of Russia?',
      options: [
        'Nicholas II',
        'Alexander III',
        'Peter the Great',
        'Ivan the Terrible'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh39',
      question:
          'The Khmer Rouge regime was responsible for the genocide in which country?',
      options: ['Vietnam', 'Cambodia', 'Laos', 'Thailand'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh40',
      question: 'Which was the first country to grant women the right to vote?',
      options: ['United States', 'United Kingdom', 'New Zealand', 'France'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh41',
      question: 'The Boxer Rebellion took place in which country?',
      options: ['Japan', 'Korea', 'China', 'Vietnam'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh42',
      question: 'Who discovered penicillin?',
      options: [
        'Louis Pasteur',
        'Alexander Fleming',
        'Marie Curie',
        'Joseph Lister'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh43',
      question: "Which battle marked the end of Napoleon's rule?",
      options: [
        'Battle of Waterloo',
        'Battle of Trafalgar',
        'Battle of Leipzig',
        'Battle of Austerlitz'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh44',
      question:
          'The Mayflower transported pilgrims to America from which country?',
      options: ['Spain', 'France', 'England', 'Netherlands'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh45',
      question: 'Who was the first human to journey into space?',
      options: ['Neil Armstrong', 'Yuri Gagarin', 'John Glenn', 'Alan Shepard'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh46',
      question: 'Which civilization built the ancient city of Teotihuacan?',
      options: ['Maya', 'Inca', 'Aztec', 'Unknown'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'wh47',
      question:
          'The Treaty of Tordesillas divided newly discovered lands between which two countries?',
      options: [
        'England and France',
        'Spain and Portugal',
        'Netherlands and Spain',
        'Portugal and France'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh48',
      question: 'Which dynasty ruled China for the longest period?',
      options: ['Ming', 'Han', 'Tang', 'Zhou'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'wh49',
      question: 'Who was known as the "Iron Lady"?',
      options: [
        'Queen Victoria',
        'Margaret Thatcher',
        'Indira Gandhi',
        'Golda Meir'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh50',
      question: 'In which year did the Chernobyl nuclear disaster occur?',
      options: ['1979', '1986', '1991', '1996'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh51',
      question: 'Which ancient civilization built the city of Machu Picchu?',
      options: ['Maya', 'Aztec', 'Inca', 'Olmec'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh52',
      question: 'Who was the first woman to win a Nobel Prize?',
      options: [
        'Marie Curie',
        'Rosalind Franklin',
        'Ada Lovelace',
        'Dorothy Hodgkin'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh53',
      question: 'The Cultural Revolution occurred in which country?',
      options: ['Japan', 'Soviet Union', 'China', 'Vietnam'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh54',
      question:
          'Which civilization is credited with inventing the concept of zero?',
      options: ['Chinese', 'Egyptian', 'Mayan', 'Indian'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'wh55',
      question: 'Who was the last Tsar of Russia?',
      options: [
        'Nicholas II',
        'Alexander III',
        'Peter the Great',
        'Ivan the Terrible'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh56',
      question:
          'The Peloponnesian War was fought between which ancient Greek city-states?',
      options: [
        'Athens and Sparta',
        'Athens and Corinth',
        'Sparta and Thebes',
        'Athens and Thebes'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh57',
      question: 'What event triggered the start of World War I?',
      options: [
        'Treaty of Versailles',
        'Assassination of Archduke Franz Ferdinand',
        'The invasion of Poland',
        'The sinking of the Lusitania'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh58',
      question: 'Which empire was ruled by Genghis Khan?',
      options: [
        'Ottoman Empire',
        'Persian Empire',
        'Mongol Empire',
        'Roman Empire'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh59',
      question: 'Who wrote "The Communist Manifesto"?',
      options: [
        'Vladimir Lenin',
        'Joseph Stalin',
        'Karl Marx and Friedrich Engels',
        'Leon Trotsky'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh60',
      question: 'Which civilization built the Terracotta Army?',
      options: ['Han Dynasty', 'Qin Dynasty', 'Ming Dynasty', 'Tang Dynasty'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh61',
      question:
          'What was the name of the project that developed the first nuclear weapons during World War II?',
      options: [
        'Operation Overlord',
        'The Philadelphia Experiment',
        'The Manhattan Project',
        'Operation Barbarossa'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh62',
      question: 'Who was the first emperor of the Roman Empire?',
      options: ['Julius Caesar', 'Augustus', 'Nero', 'Constantine'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh63',
      question: 'In which year did the Berlin Wall fall?',
      options: ['1987', '1989', '1991', '1993'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh64',
      question: 'The Magna Carta was signed in which year?',
      options: ['1215', '1315', '1415', '1515'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh65',
      question:
          'Who led the Salt March in India as an act of civil disobedience against British rule?',
      options: [
        'Jawaharlal Nehru',
        'Mahatma Gandhi',
        'Subhas Chandra Bose',
        'Bhagat Singh'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh66',
      question:
          'Which Mongol leader conquered the largest land empire in history?',
      options: ['Kublai Khan', 'Attila the Hun', 'Genghis Khan', 'Timur'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh67',
      question:
          'Who was the leader of the Soviet Union during the Cuban Missile Crisis?',
      options: [
        'Joseph Stalin',
        'Vladimir Lenin',
        'Nikita Khrushchev',
        'Leonid Brezhnev'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh68',
      question: 'Which civilization built the ancient city of Petra?',
      options: ['Romans', 'Greeks', 'Nabataeans', 'Egyptians'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh69',
      question: 'What was the name of the first satellite launched into space?',
      options: ['Explorer 1', 'Vanguard 1', 'Sputnik 1', 'Telstar 1'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh70',
      question:
          'Which battle ended Napoleon Bonaparte\'s rule as Emperor of France?',
      options: [
        'Battle of Trafalgar',
        'Battle of Waterloo',
        'Battle of Leipzig',
        'Battle of Borodino'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh71',
      question: 'Who was the first President of the United States?',
      options: [
        'Thomas Jefferson',
        'John Adams',
        'George Washington',
        'Abraham Lincoln'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh72',
      question:
          'The Age of Enlightenment primarily took place during which century?',
      options: ['16th century', '17th century', '18th century', '19th century'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh73',
      question: 'Who wrote the "I Have a Dream" speech?',
      options: [
        'Malcolm X',
        'Martin Luther King Jr.',
        'Nelson Mandela',
        'Barack Obama'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh74',
      question:
          'The Great Depression began with the stock market crash in which year?',
      options: ['1919', '1929', '1939', '1949'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh75',
      question:
          'Which ancient civilization developed an early form of writing called cuneiform?',
      options: ['Egyptian', 'Sumerian', 'Greek', 'Chinese'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh76',
      question: 'What was the original name of New York City?',
      options: ['New Amsterdam', 'New London', 'York City', 'Manhattan'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh77',
      question:
          'Which European country had the largest colonial empire by land area?',
      options: ['United Kingdom', 'Spain', 'France', 'Portugal'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh78',
      question:
          'The Reign of Terror was a period of violence that occurred after which revolution?',
      options: [
        'Russian Revolution',
        'American Revolution',
        'French Revolution',
        'Industrial Revolution'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh79',
      question: 'Who was the first female Prime Minister of India?',
      options: [
        'Benazir Bhutto',
        'Indira Gandhi',
        'Sirimavo Bandaranaike',
        'Golda Meir'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh80',
      question:
          'Which of these countries was not part of the Allied Powers during World War II?',
      options: ['United States', 'Soviet Union', 'Italy', 'United Kingdom'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh81',
      question: 'Who was known as the "Iron Chancellor" of Germany?',
      options: [
        'Adolf Hitler',
        'Kaiser Wilhelm II',
        'Otto von Bismarck',
        'Frederick the Great'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh82',
      question:
          'Which dynasty ruled China during the construction of the Great Wall?',
      options: ['Ming', 'Tang', 'Song', 'Qin'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh83',
      question:
          'What was the significance of the Emancipation Proclamation in the United States?',
      options: [
        'It ended World War I',
        'It declared independence from Britain',
        'It freed slaves in Confederate states',
        'It granted women the right to vote'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh84',
      question:
          'Which civilization is known for building pyramid-like structures called ziggurats?',
      options: ['Egyptian', 'Mayan', 'Mesopotamian', 'Greek'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh85',
      question: 'Who was the last emperor of China?',
      options: ['Hongwu', 'Puyi', 'Qianlong', 'Sun Yat-sen'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh86',
      question: 'In which year did World War I begin?',
      options: ['1910', '1914', '1918', '1922'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh87',
      question: 'Who was the first woman to win a Nobel Prize?',
      options: [
        'Marie Curie',
        'Rosalind Franklin',
        'Jane Goodall',
        'Ada Lovelace'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh88',
      question: 'Which ancient civilization built the Machu Picchu complex?',
      options: ['Maya', 'Aztec', 'Inca', 'Olmec'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh89',
      question: 'When did the Berlin Wall fall?',
      options: ['1985', '1987', '1989', '1991'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh90',
      question: 'Who was the first Emperor of Rome?',
      options: ['Julius Caesar', 'Augustus', 'Nero', 'Constantine'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh91',
      question: 'Which war is also known as "The Great War"?',
      options: [
        'American Civil War',
        'World War I',
        'World War II',
        'Napoleonic Wars'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh92',
      question: 'Who wrote the Communist Manifesto?',
      options: [
        'Vladimir Lenin',
        'Joseph Stalin',
        'Karl Marx and Friedrich Engels',
        'Leon Trotsky'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh93',
      question: 'Which country was formerly known as Siam?',
      options: ['Vietnam', 'Cambodia', 'Myanmar', 'Thailand'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'wh94',
      question: 'What event marked the beginning of World War II in Europe?',
      options: [
        'Bombing of Pearl Harbor',
        'Invasion of Poland',
        'Battle of Britain',
        'Fall of France'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh95',
      question:
          'Who led the scientific expedition to South America and developed the theory of evolution?',
      options: [
        'Isaac Newton',
        'Charles Darwin',
        'Alexander von Humboldt',
        'Louis Pasteur'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh96',
      question:
          'The Hundred Years\' War was fought between which two countries?',
      options: [
        'England and France',
        'Spain and Portugal',
        'Russia and Sweden',
        'Austria and Prussia'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'wh97',
      question:
          'Which empire was ruled by Mansa Musa, one of the wealthiest individuals in history?',
      options: [
        'Ottoman Empire',
        'Mughal Empire',
        'Mali Empire',
        'Persian Empire'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'wh98',
      question:
          'In which year did Christopher Columbus first reach the Americas?',
      options: ['1453', '1492', '1520', '1588'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh99',
      question:
          'Who was the leader of India\'s independence movement against British rule?',
      options: [
        'Jawaharlal Nehru',
        'Mahatma Gandhi',
        'Subhas Chandra Bose',
        'Muhammad Ali Jinnah'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'wh100',
      question:
          'Which civilization created the first known written legal code, the Code of Hammurabi?',
      options: ['Egyptian', 'Babylonian', 'Persian', 'Greek'],
      correctOptionIndex: 1,
    ),
  ];

  // Science & Technology Questions (50 questions)
  static final List<MCQQuestion> _scienceTechnologyQuestions = [
    MCQQuestion(
      id: 'st1',
      question: 'What is the chemical symbol for water?',
      options: ['W', 'H₂O', 'WA', 'AQ'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st2',
      question: 'Which particle has a positive charge?',
      options: ['Electron', 'Neutron', 'Proton', 'Photon'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st3',
      question: 'Who founded Microsoft?',
      options: ['Steve Jobs', 'Bill Gates', 'Jeff Bezos', 'Mark Zuckerberg'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st4',
      question: 'What does CPU stand for?',
      options: [
        'Central Processing Unit',
        'Computer Personal Unit',
        'Central Program Utility',
        'Central Processor Utility'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'st5',
      question: 'Which of these is not a programming language?',
      options: ['Python', 'Java', 'Cobra', 'Rhino'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'st6',
      question: 'What is the closest star to Earth?',
      options: ['Proxima Centauri', 'Alpha Centauri', 'The Sun', 'Sirius'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st7',
      question:
          'Which technology is used for storing information in a blockchain?',
      options: [
        'Cloud computing',
        'Distributed ledger',
        'Virtual reality',
        'Quantum computing'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st8',
      question: 'What is the powerhouse of the cell?',
      options: [
        'Nucleus',
        'Mitochondria',
        'Endoplasmic Reticulum',
        'Golgi Apparatus'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st9',
      question: 'Who developed the theory of general relativity?',
      options: [
        'Isaac Newton',
        'Stephen Hawking',
        'Albert Einstein',
        'Niels Bohr'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st10',
      question: 'What type of waves does WiFi use?',
      options: [
        'Radio waves',
        'Microwaves',
        'Infrared waves',
        'Ultraviolet waves'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'st11',
      question: 'Which of these is not a type of renewable energy?',
      options: ['Solar', 'Wind', 'Natural gas', 'Hydroelectric'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st12',
      question: 'What is the unit of electrical resistance?',
      options: ['Volt', 'Watt', 'Ohm', 'Ampere'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st13',
      question: 'Which of these is not one of the states of matter?',
      options: ['Solid', 'Liquid', 'Gas', 'Mineral'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'st14',
      question: "What is the most abundant gas in Earth's atmosphere?",
      options: ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Hydrogen'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st15',
      question: 'Which company developed the iPhone?',
      options: ['Google', 'Samsung', 'Apple', 'Microsoft'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st16',
      question: 'What is the smallest unit of data in a computer?',
      options: ['Byte', 'Bit', 'Nibble', 'Pixel'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st17',
      question:
          'Which essential vitamin is produced when skin is exposed to sunlight?',
      options: ['Vitamin A', 'Vitamin B', 'Vitamin C', 'Vitamin D'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'st18',
      question: 'What does HTML stand for?',
      options: [
        'Hyper Text Markup Language',
        'High Tech Machine Learning',
        'Hyper Transfer Markup Language',
        'Home Tool Markup Language'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'st19',
      question: 'Which planet has the most gravity?',
      options: ['Earth', 'Mars', 'Jupiter', 'Saturn'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st20',
      question: 'Which of these is not an element on the periodic table?',
      options: ['Titanium', 'Neptunium', 'Adamantium', 'Californium'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st21',
      question: 'What is the study of fossils called?',
      options: ['Archaeology', 'Anthropology', 'Paleontology', 'Geology'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st22',
      question: 'Who is known as the father of modern computing?',
      options: [
        'Charles Babbage',
        'Alan Turing',
        'John von Neumann',
        'Tim Berners-Lee'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st23',
      question: 'Which of these is not a browser?',
      options: ['Chrome', 'Firefox', 'Safari', 'Oracle'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'st24',
      question: 'What is the speed of light in a vacuum?',
      options: [
        '300,000 km/s',
        '150,000 km/s',
        '500,000 km/s',
        '1,000,000 km/s'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'st25',
      question: "What is the name of Elon Musk's aerospace company?",
      options: ['Boeing', 'Blue Origin', 'SpaceX', 'Virgin Galactic'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st26',
      question: 'What is the main component of the sun?',
      options: ['Oxygen', 'Helium', 'Carbon', 'Hydrogen'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'st27',
      question: 'Which is the densest naturally occurring element?',
      options: ['Gold', 'Uranium', 'Platinum', 'Osmium'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'st28',
      question: 'What social media platform was founded by Jack Dorsey?',
      options: ['Instagram', 'Twitter', 'Facebook', 'Snapchat'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st29',
      question: 'Which organ in the human body produces insulin?',
      options: ['Liver', 'Kidney', 'Pancreas', 'Spleen'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st30',
      question:
          'What is the name of the largest known asteroid in the asteroid belt?',
      options: ['Vesta', 'Juno', 'Ceres', 'Pallas'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st31',
      question: 'What technology is used in a Tesla Powerwall?',
      options: [
        'Fuel cell',
        'Lithium-ion battery',
        'Nuclear fusion',
        'Solar panels'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st32',
      question:
          'Which scientist formulated the laws of motion and universal gravitation?',
      options: [
        'Galileo Galilei',
        'Isaac Newton',
        'Albert Einstein',
        'Nikola Tesla'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st33',
      question: 'What does AI stand for?',
      options: [
        'Automated Intelligence',
        'Artificial Intelligence',
        'Assisted Information',
        'Augmented Interaction'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st34',
      question: 'What is the chemical symbol for table salt?',
      options: ['NaCl', 'H2O', 'CO2', 'CaCO3'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'st35',
      question: 'Which of these is not a primary color of light?',
      options: ['Red', 'Green', 'Blue', 'Yellow'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'st36',
      question: 'What was the first successfully cloned mammal?',
      options: [
        'Dolly the sheep',
        'Mickey the mouse',
        'Coco the cat',
        'Rex the dog'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'st37',
      question: 'What is the main function of white blood cells?',
      options: [
        'Transport oxygen',
        'Fight infection',
        'Carry nutrients',
        'Produce hormones'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st38',
      question: 'Which programming language was developed by Google?',
      options: ['Java', 'Python', 'Go', 'Swift'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st39',
      question:
          'What is the process by which plants make their own food called?',
      options: ['Respiration', 'Photosynthesis', 'Fermentation', 'Digestion'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st40',
      question: 'Which company created Flutter?',
      options: ['Facebook', 'Google', 'Apple', 'Microsoft'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st41',
      question: 'What is the study of earthquakes called?',
      options: ['Seismology', 'Volcanology', 'Geology', 'Meteorology'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'st42',
      question: 'What technology is used to create 3D printing?',
      options: [
        'Additive manufacturing',
        'Subtractive manufacturing',
        'Casting',
        'Molding'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'st43',
      question: 'Which of these is not a type of nuclear radiation?',
      options: ['Alpha', 'Beta', 'Gamma', 'Delta'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'st44',
      question: 'Who invented the telephone?',
      options: [
        'Thomas Edison',
        'Alexander Graham Bell',
        'Nikola Tesla',
        'Guglielmo Marconi'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st45',
      question: 'What does VPN stand for?',
      options: [
        'Virtual Private Network',
        'Visual Processing Node',
        'Virtual Personal Navigator',
        'Verified Protocol Network'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'st46',
      question:
          'Which of these is a device that supplies clean energy to a computer?',
      options: ['CPU', 'RAM', 'PSU', 'GPU'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st47',
      question: 'What is the chemical formula for glucose?',
      options: ['C12H22O11', 'C6H12O6', 'CH4', 'H2O2'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st48',
      question: 'Who introduced the concept of the World Wide Web?',
      options: [
        'Steve Jobs',
        'Bill Gates',
        'Tim Berners-Lee',
        'Mark Zuckerberg'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st49',
      question: 'Which planet has the Great Red Spot?',
      options: ['Mars', 'Venus', 'Jupiter', 'Saturn'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st50',
      question: 'What is the most abundant element in the universe?',
      options: ['Oxygen', 'Carbon', 'Helium', 'Hydrogen'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'st51',
      question:
          'What is the most abundant greenhouse gas in Earth\'s atmosphere?',
      options: ['Carbon dioxide', 'Methane', 'Water vapor', 'Nitrous oxide'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st52',
      question:
          'Which technology is used to make cryptocurrency transactions secure?',
      options: [
        'Machine learning',
        'Blockchain',
        'Cloud computing',
        'Virtual reality'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st53',
      question: 'What is the name of Elon Musk\'s neurotechnology company?',
      options: ['Neuralink', 'BrainSpace', 'NeuralNet', 'MindTech'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'st54',
      question:
          'What is the process of converting light energy into electrical energy called?',
      options: [
        'Thermal conversion',
        'Photosynthesis',
        'Photoelectric effect',
        'Electrolysis'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st55',
      question: 'Which planet has the most moons in our solar system?',
      options: ['Jupiter', 'Saturn', 'Uranus', 'Neptune'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st56',
      question:
          'What programming language was developed specifically for artificial intelligence?',
      options: ['Python', 'Lisp', 'Java', 'C++'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st57',
      question: 'Which of these is not a fundamental force in physics?',
      options: [
        'Gravity',
        'Electromagnetic force',
        'Strong nuclear force',
        'Centrifugal force'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'st58',
      question:
          'What part of the human brain is responsible for regulating basic functions like breathing and heart rate?',
      options: ['Cerebrum', 'Cerebellum', 'Brainstem', 'Thalamus'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st59',
      question:
          'What technology enables near-field communication (NFC) in smartphones?',
      options: ['Bluetooth', 'RFID', 'Wi-Fi', 'GPS'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st60',
      question: 'What is the study of the universe called?',
      options: ['Astronomy', 'Cosmology', 'Astrophysics', 'Astrology'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st61',
      question:
          'Which famous technology company was founded by Steve Jobs, Steve Wozniak, and Ronald Wayne?',
      options: ['Microsoft', 'Apple', 'IBM', 'Intel'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st62',
      question: 'What is the hardest natural material on Earth?',
      options: ['Titanium', 'Steel', 'Diamond', 'Graphene'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st63',
      question:
          'What is the name of the point where a black hole\'s gravity becomes so extreme that nothing can escape?',
      options: [
        'Singularity',
        'Event horizon',
        'Photon sphere',
        'Gravitational lens'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st64',
      question:
          'Which molecule carries genetic instructions in all living organisms?',
      options: ['Protein', 'Carbohydrate', 'DNA', 'Lipid'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st65',
      question:
          'What is the term for when a computer program appears to exhibit human intelligence?',
      options: [
        'Machine learning',
        'Deep learning',
        'Artificial intelligence',
        'Neural network'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st66',
      question:
          'What is the term for the science of collecting and analyzing data to uncover patterns and trends?',
      options: [
        'Computer science',
        'Data analytics',
        'Data science',
        'Information technology'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st67',
      question: 'Which of these elements has the highest melting point?',
      options: ['Titanium', 'Tungsten', 'Platinum', 'Iridium'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st68',
      question: 'What technology is used in RFID tags?',
      options: ['Infrared', 'Radio waves', 'Ultrasound', 'Microwave'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st69',
      question: 'Which of these is not a layer of the Earth\'s atmosphere?',
      options: ['Troposphere', 'Stratosphere', 'Mesosphere', 'Lithosphere'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'st70',
      question: 'What does CRISPR technology allow scientists to do?',
      options: [
        'Clone organisms',
        'Edit genes',
        'Create synthetic life',
        'Observe quantum particles'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st71',
      question: 'Which company developed the programming language Swift?',
      options: ['Google', 'Microsoft', 'Apple', 'Facebook'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st72',
      question:
          'What property of light allows a prism to separate it into a spectrum of colors?',
      options: ['Polarization', 'Reflection', 'Refraction', 'Diffraction'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st73',
      question:
          'What is the name for a computer program that can replicate itself and spread to other computers?',
      options: ['Virus', 'Worm', 'Trojan', 'Spyware'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st74',
      question: 'Which of these is not a type of machine learning?',
      options: [
        'Supervised learning',
        'Unsupervised learning',
        'Reinforcement learning',
        'Rational learning'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'st75',
      question:
          'What is the name of the particle that gives mass to other particles?',
      options: ['Boson', 'Higgs boson', 'Graviton', 'Neutrino'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st76',
      question:
          'Which of these devices converts digital signals to analog signals?',
      options: ['Processor', 'Modem', 'Router', 'Switch'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st77',
      question:
          'What is the name for the process where a solid changes directly to a gas without becoming a liquid?',
      options: ['Condensation', 'Sublimation', 'Deposition', 'Vaporization'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st78',
      question:
          'Which of these is not a basic component of a computer\'s central processing unit (CPU)?',
      options: [
        'Control unit',
        'Arithmetic logic unit',
        'Memory unit',
        'Input/output unit'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'st79',
      question: 'What is the most abundant gas in the Martian atmosphere?',
      options: ['Oxygen', 'Nitrogen', 'Carbon dioxide', 'Hydrogen'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st80',
      question:
          'Which computer programming concept involves packaging data and functions into a single unit?',
      options: ['Encapsulation', 'Polymorphism', 'Inheritance', 'Abstraction'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'st81',
      question:
          'What is the name of the technology that allows for simultaneous localization and mapping in robotics?',
      options: ['LIDAR', 'SLAM', 'GPS', 'RADAR'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st82',
      question: 'Which of these is not a type of cloud computing service?',
      options: [
        'Software as a Service (SaaS)',
        'Platform as a Service (PaaS)',
        'Infrastructure as a Service (IaaS)',
        'Hardware as a Service (HaaS)'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'st83',
      question:
          'What is the phenomenon where a quantum particle can exist in multiple states simultaneously?',
      options: [
        'Quantum tunneling',
        'Quantum entanglement',
        'Quantum superposition',
        'Quantum decoherence'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st84',
      question:
          'Which company created the first commercially successful personal computer with a graphical user interface (GUI)?',
      options: ['IBM', 'Microsoft', 'Apple', 'Dell'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st85',
      question: 'What is the primary component of natural gas?',
      options: ['Ethane', 'Propane', 'Methane', 'Butane'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st86',
      question: 'What is the standard unit of power?',
      options: ['Joule', 'Newton', 'Watt', 'Pascal'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st87',
      question:
          'Which programming language is most commonly used for iOS app development?',
      options: ['Java', 'C#', 'Swift', 'Python'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st88',
      question: 'What is the main function of DNA in an organism?',
      options: [
        'Energy storage',
        'Genetic information storage',
        'Breaking down nutrients',
        'Transporting oxygen'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st89',
      question: 'What does HTTP stand for in web addresses?',
      options: [
        'Hypertext Transfer Protocol',
        'Hypertext Technical Programming',
        'High Tech Transfer Process',
        'Hypertext Terminal Process'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'st90',
      question: 'Which part of the atom has a positive charge?',
      options: ['Electron', 'Neutron', 'Proton', 'Nucleus'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st91',
      question:
          'What is the study of heredity and the variation of inherited characteristics called?',
      options: ['Physiology', 'Genetics', 'Cytology', 'Microbiology'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st92',
      question: 'Which of these is not a fossil fuel?',
      options: ['Coal', 'Natural gas', 'Petroleum', 'Uranium'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'st93',
      question: 'What technology is used to store information in Bitcoin?',
      options: [
        'Cloud computing',
        'Neural networks',
        'Blockchain',
        'Quantum computing'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st94',
      question: 'What is the smallest unit of digital information?',
      options: ['Byte', 'Bit', 'Megabyte', 'Pixel'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st95',
      question:
          'Which planet has the strongest magnetic field in our solar system?',
      options: ['Earth', 'Jupiter', 'Saturn', 'Mercury'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'st96',
      question: 'What does AI stand for in computer science?',
      options: [
        'Advanced Integration',
        'Automated Interface',
        'Artificial Intelligence',
        'Alternative Interaction'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st97',
      question: 'Which of these is not a programming paradigm?',
      options: ['Object-oriented', 'Functional', 'Procedural', 'Systematic'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'st98',
      question: 'What is the speed of light in a vacuum?',
      options: ['300,000 km/s', '150,000 km/s', '500,000 km/s', '199,792 km/s'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'st99',
      question: 'Which of these is a renewable energy source?',
      options: ['Nuclear power', 'Coal', 'Solar power', 'Natural gas'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'st100',
      question: 'What does VR stand for in technology?',
      options: [
        'Visual Reality',
        'Virtual Reality',
        'Variable Resolution',
        'Video Recording'
      ],
      correctOptionIndex: 1,
    ),
  ];

  // Current Affairs Questions (50 questions)
  static final List<MCQQuestion> _currentAffairsQuestions = [
    MCQQuestion(
      id: 'ca1',
      question:
          'Which technology trend is expected to lead AI development in 2025?',
      options: [
        'Virtual Reality',
        'Generative AI',
        'Quantum Computing',
        'Edge Computing'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca2',
      question:
          'Which space agency plans to return humans to the moon with the Artemis program?',
      options: ['SpaceX', 'NASA', 'ESA', 'ISRO'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca3',
      question:
          'Which nation launched the world\'s first space solar power station in 2024?',
      options: ['United States', 'China', 'Russia', 'Japan'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca4',
      question:
          'What major technological milestone did Neuralink achieve in 2024?',
      options: [
        'First human brain implant',
        'Curing paralysis',
        'Digital memory storage',
        'Artificial consciousness'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca5',
      question:
          'Which global initiative aims to achieve net-zero carbon emissions by 2050?',
      options: [
        'Green Deal',
        'Paris Agreement',
        'Climate Neutral Alliance',
        'Earth Pact'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca6',
      question:
          'Which cryptocurrency became the global standard for central bank digital currencies?',
      options: [
        'Bitcoin',
        'Ethereum',
        'None yet - systems remain diverse',
        'XRP'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca7',
      question:
          'What is the primary focus of WHO\'s 2025 pandemic preparedness treaty?',
      options: [
        'Vaccine development acceleration',
        'Early warning systems',
        'Equitable resource distribution',
        'Pathogen research restrictions'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca8',
      question:
          'Which nation became the world\'s largest economy in 2024-2025?',
      options: ['United States', 'China', 'India', 'Germany'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca9',
      question:
          'What major breakthrough occurred in quantum computing in 2024?',
      options: [
        'First practical quantum advantage',
        'Quantum internet prototype',
        'Million-qubit processor',
        'Room temperature superconductor'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca10',
      question:
          "Which technology company achieved the first \$5 trillion market capitalization?",
      options: ['Apple', 'Microsoft', 'Nvidia', 'Amazon'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca11',
      question:
          'What was the focus of the 2024 United Nations Climate Change Conference?',
      options: [
        'Carbon capture technology',
        'Ocean conservation',
        'Climate finance for developing nations',
        'Methane reduction commitments'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca12',
      question:
          'Which renewable energy source saw the largest global growth in 2024?',
      options: ['Solar', 'Wind', 'Geothermal', 'Hydroelectric'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca13',
      question: 'What healthcare innovation became widely adopted in 2024?',
      options: [
        'AI-powered diagnostics',
        'mRNA treatments for multiple diseases',
        'Remote surgery platforms',
        'At-home full body scanners'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca14',
      question: 'Which country hosted the 2024 Summer Olympics?',
      options: [
        'Tokyo, Japan',
        'Paris, France',
        'Los Angeles, USA',
        'Beijing, China'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca15',
      question:
          'What major advancement in agriculture technology gained prominence in 2024?',
      options: [
        'Lab-grown crops',
        'Vertical farming automation',
        'CRISPR-enhanced seeds',
        'Drone pollination systems'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca16',
      question:
          'Which global social movement gained significant momentum in 2024?',
      options: [
        'Digital rights protection',
        'Universal basic income',
        'Four-day workweek',
        'Decentralized governance'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca17',
      question:
          'What transportation innovation began large-scale implementation in 2024?',
      options: [
        'Autonomous trucking networks',
        'Flying taxis in major cities',
        'Hyperloop systems',
        'Hydrogen-powered public transport'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca18',
      question:
          'Which material science breakthrough revolutionized battery technology in 2024?',
      options: [
        'Solid-state batteries',
        'Graphene supercapacitors',
        'Sodium-ion batteries',
        'Organic flow batteries'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca19',
      question:
          'What global policy framework for AI regulation was adopted in 2024?',
      options: [
        'AI Safety Protocol',
        'Digital Intelligence Act',
        'Responsible AI Framework',
        'Global AI Governance Treaty'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'ca20',
      question: 'Which digital technology reached 1 billion users in 2024?',
      options: [
        'AR glasses',
        'Digital IDs',
        'Metaverse platforms',
        'Web3 wallets'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca21',
      question:
          'What food technology saw widespread commercial adoption in 2024?',
      options: [
        'Lab-grown meat',
        '3D printed food',
        'Personalized nutrition algorithms',
        'Automated kitchen systems'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca22',
      question:
          'Which coastal city implemented the world\'s largest flood defense system in 2024?',
      options: ['Rotterdam', 'Miami', 'Venice', 'Jakarta'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'ca23',
      question:
          'What educational approach became standard in many countries in 2024?',
      options: [
        'Virtual reality classrooms',
        'AI-personalized learning',
        'Project-based qualification systems',
        'Mandatory coding curriculum'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca24',
      question:
          'Which pandemic response technology became globally standardized in 2024?',
      options: [
        'Genetic surveillance systems',
        'International vaccine passports',
        'Wastewater monitoring networks',
        'Pathogen prediction AI'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca25',
      question:
          'What major change occurred in global internet governance in 2024?',
      options: [
        'UN-led management system',
        'Decentralized blockchain protocols',
        'Regional internet zones',
        'Tech company consortium control'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca26',
      question:
          'Which global scientific collaboration made a breakthrough in energy production?',
      options: [
        'ITER fusion reactor',
        'Global Hydrogen Alliance',
        'Orbital Solar Array',
        'Deep Geothermal Network'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca27',
      question:
          'What became the dominant form of urban mobility in major cities by 2024?',
      options: [
        'Electric scooters',
        'Autonomous shuttles',
        'Subscription-based multimodal transport',
        'Electric bicycles'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca28',
      question:
          'Which country pioneered the world\'s first circular economy framework?',
      options: ['Sweden', 'Finland', 'Netherlands', 'Singapore'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca29',
      question: 'What major shift occurred in retail technology in 2024?',
      options: [
        'Cashierless stores as standard',
        'AR shopping experiences',
        'Drone delivery networks',
        'Blockchain verification systems'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca30',
      question:
          'Which historical archaeological discovery made headlines in 2024?',
      options: [
        'Atlantis evidence',
        'Amazon civilization confirmation',
        'Ancient technology artifacts',
        'Pre-Columbian trans-oceanic contact proof'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca31',
      question: 'What became the fastest-growing programming language of 2024?',
      options: ['Rust', 'Carbon', 'Julia', 'Mojo'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'ca32',
      question:
          'Which country became carbon-negative (absorbing more carbon than it emits) in 2024?',
      options: ['Bhutan', 'Costa Rica', 'Denmark', 'New Zealand'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca33',
      question:
          'What healthcare model became dominant in several nations by 2024?',
      options: [
        'Universal basic care',
        'Preventative subscription services',
        'AI-first diagnostics',
        'Decentralized community health networks'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca34',
      question:
          'Which major tech company made the biggest pivot in its business model in 2024?',
      options: [
        'Google to quantum computing',
        'Meta to AR hardware',
        'Amazon to healthcare',
        'Apple to transportation'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca35',
      question: 'What planetary mission made a significant discovery in 2024?',
      options: [
        'Europa Clipper finding biological markers',
        'Mars Sample Return confirming ancient life',
        'Dragonfly on Titan discovering organic compounds',
        'DAVINCI finding phosphine on Venus'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'ca36',
      question:
          'Which species was officially declared recovered from endangered status in 2024?',
      options: [
        'Giant panda',
        'Black rhino',
        'Mountain gorilla',
        'Snow leopard'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca37',
      question:
          'What economic model gained international support in post-pandemic recovery?',
      options: [
        'Circular economy',
        'Stakeholder capitalism',
        'Doughnut economics',
        'Decentralized autonomous organizations'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca38',
      question:
          'What became the standard for digital identity verification in 2024?',
      options: [
        'Biometric passports',
        'Blockchain credentials',
        'Self-sovereign identity',
        'Government-issued digital IDs'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca39',
      question:
          'Which data privacy practice became mandated across most major economies?',
      options: [
        'Data localization',
        'Right to be forgotten',
        'Algorithmic transparency',
        'Opt-in data collection'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'ca40',
      question:
          'What energy storage technology achieved commercial viability in 2024?',
      options: [
        'Iron-air batteries',
        'Liquid metal batteries',
        'Gravitational storage',
        'Hydrogen fuel cells'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca41',
      question:
          'Which manufacturing technique revolutionized construction in 2024?',
      options: [
        '3D-printed buildings',
        'Self-assembling materials',
        'Robotic construction crews',
        'Advanced prefabrication'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca42',
      question:
          'What global water management innovation gained traction in 2024?',
      options: [
        'Atmospheric water harvesters',
        'Decentralized water purification',
        'Smart water grid systems',
        'Ocean desalination networks'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca43',
      question: 'Which social platform dominated global communication in 2024?',
      options: [
        'TikTok successor',
        'Decentralized protocol networks',
        'AR social worlds',
        'Voice-first platforms'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca44',
      question:
          'What major medical treatment approach gained FDA approval in 2024?',
      options: [
        'Gene editing for inherited diseases',
        'Digital therapeutics for mental health',
        'Microbiome transplantation',
        'Nanomedicine delivery systems'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca45',
      question:
          'Which wildfire prevention technology was widely implemented in 2024?',
      options: [
        'AI prediction systems',
        'Drone monitoring networks',
        'Satellite detection arrays',
        'Controlled burn automation'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'ca46',
      question:
          'What major change occurred in global financial systems in 2024?',
      options: [
        'Central bank digital currencies',
        'Cross-border instant payments',
        'Global minimum corporate tax',
        'Open banking standards'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca47',
      question:
          'Which country led the global rankings in renewable energy transition in 2024?',
      options: ['Germany', 'China', 'Denmark', 'Australia'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca48',
      question:
          'What workspace innovation became standard for global corporations in 2024?',
      options: [
        'Remote-first policies',
        'Four-day workweek',
        'Hybrid hub-and-spoke model',
        'AI productivity augmentation'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca49',
      question:
          'Which nuclear fusion company achieved energy-positive reaction in 2024?',
      options: [
        'Commonwealth Fusion Systems',
        'TAE Technologies',
        'General Fusion',
        'Helion Energy'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca50',
      question:
          'What became the most widely adopted sustainable aviation fuel in 2024?',
      options: [
        'Hydrogen',
        'Synthetic kerosene',
        'Biofuel blends',
        'Electric hybrid systems'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca51',
      question:
          'Which innovative transport solution reached over 100 cities globally by 2025?',
      options: [
        'Urban air taxis',
        'Hyperloop networks',
        'Electric scooter sharing',
        'Underground cargo delivery'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca52',
      question:
          'Which country hosted the 2025 UN Climate Change Conference (COP31)?',
      options: ['Brazil', 'India', 'South Africa', 'Australia'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca53',
      question: 'What major advance in quantum computing occurred in 2025?',
      options: [
        'First consumer quantum computer',
        'Quantum internet prototype',
        'Error-free quantum processing',
        'Quantum-secure encryption standard'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'ca54',
      question:
          'Which augmented reality glasses became the fastest-selling consumer technology of 2025?',
      options: [
        'Apple Vision',
        'Meta Spectacles',
        'Samsung Lens',
        'Google Glass Evolution'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca55',
      question:
          'What healthcare innovation transformed cancer treatment in 2025?',
      options: [
        'Universal cancer vaccine',
        'AI diagnostic accuracy surpassing doctors',
        'Personalized mRNA therapy',
        'Non-invasive tumor elimination'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca56',
      question:
          'Which digital currency became the first to be fully adopted as legal tender by a G20 nation?',
      options: [
        'Bitcoin',
        'Ethereum',
        'Central Bank Digital Currency (CBDC)',
        'Digital Yuan'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca57',
      question:
          'What breakthrough energy technology reached commercial viability in 2025?',
      options: [
        'Room temperature superconductors',
        'Fusion power generation',
        'Grid-scale quantum batteries',
        'Orbital solar power transmission'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca58',
      question:
          'Which AI development raised the most significant ethical concerns in 2025?',
      options: [
        'Self-evolving algorithms',
        'Emotion-mimicking chatbots',
        'Autonomous military systems',
        'Deep-fake detection evasion'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca59',
      question: 'What transportation milestone was achieved in 2025?',
      options: [
        'First commercial supersonic passenger service',
        'Autonomous vehicles reaching majority market share',
        'First regular passenger flights to space',
        'Hyperloop connecting major European cities'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca60',
      question: 'Which food production technology became mainstream in 2025?',
      options: [
        'Lab-grown meat at price parity with conventional meat',
        'Automated vertical farming',
        'Home food printers',
        'Genetically optimized crops'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca61',
      question: 'What became the dominant form of energy storage in 2025?',
      options: [
        'Solid-state batteries',
        'Hydrogen fuel cells',
        'Gravity-based storage',
        'Compressed air energy storage'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca62',
      question: 'Which nation launched the first permanent lunar base in 2025?',
      options: [
        'United States',
        'China',
        'International consortium',
        'Private space company'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca63',
      question: 'What educational trend transformed learning in 2025?',
      options: [
        'Virtual reality classrooms',
        'AI personal tutors',
        'Skills-based certification replacing degrees',
        'Neural learning enhancement'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca64',
      question: 'Which global agreement on AI regulation was signed in 2025?',
      options: [
        'Digital Rights Treaty',
        'AI Ethics Convention',
        'Global AI Governance Framework',
        'Artificial Intelligence Limitations Protocol'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca65',
      question:
          'What major environmental restoration project began showing significant results in 2025?',
      options: [
        'Great Barrier Reef regeneration',
        'Amazon reforestation initiative',
        'Sahara Desert greening project',
        'Antarctic ice shelf stabilization'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca66',
      question: 'What technology dominated smart home integration in 2025?',
      options: [
        'Voice assistants',
        'Gesture control',
        'Brain-computer interfaces',
        'Ambient computing'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'ca67',
      question:
          'Which country pioneered the world\'s first national mental health monitoring system in 2025?',
      options: ['Sweden', 'Japan', 'Australia', 'Canada'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca68',
      question:
          'What became the standard interface for controlling digital devices in 2025?',
      options: [
        'Voice commands',
        'Thought recognition',
        'Gesture control',
        'Multimodal interaction'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'ca69',
      question:
          'Which cyber threat caused the most economic damage globally in 2025?',
      options: [
        'Ransomware',
        'Quantum encryption breaking',
        'AI-powered phishing',
        'Supply chain attacks'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca70',
      question:
          'What major diplomatic initiative was launched to address climate migration in 2025?',
      options: [
        'Global Migration Compact',
        'Climate Refugee Program',
        'Borders Without Carbon',
        'Planetary Citizenship Initiative'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'ca71',
      question:
          'Which disease was effectively eliminated in 2025 thanks to new vaccine technology?',
      options: ['Malaria', 'Dengue fever', 'HIV', 'Tuberculosis'],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca72',
      question:
          'What material science breakthrough revolutionized construction in 2025?',
      options: [
        'Self-healing concrete',
        'Carbon-negative building materials',
        'Transparent aluminum',
        'Programmable matter'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca73',
      question:
          'Which major tech company underwent a significant leadership change in 2025?',
      options: ['Amazon', 'Microsoft', 'Apple', 'Google'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca74',
      question:
          'What became the dominant form of urban transportation in major Asian cities by 2025?',
      options: [
        'Flying taxis',
        'Autonomous buses',
        'Maglev networks',
        'Electric bike sharing'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca75',
      question: 'Which weather event reached unprecedented frequency in 2025?',
      options: [
        'Arctic heat waves',
        'Category 6 hurricanes',
        'Megadroughts',
        'Polar vortex disruptions'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca76',
      question:
          'What financial system innovation gained widespread adoption in 2025?',
      options: [
        'Algorithmic central banking',
        'Universal basic assets',
        'Automated tax assessment',
        'Decentralized finance for public services'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'ca77',
      question:
          'Which asteroid mining company completed the first successful resource extraction mission in 2025?',
      options: [
        'Planetary Resources',
        'Deep Space Industries',
        'AstroMine',
        'Asteroid Mining Corporation'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca78',
      question:
          'What archaeological discovery changed our understanding of human history in 2025?',
      options: [
        'Pre-Clovis American settlement',
        'Advanced Bronze Age technology',
        'Evidence of ancient space visitors',
        'Unknown human ancestor species'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'ca79',
      question:
          'Which alternative protein source became mainstream in global food markets in 2025?',
      options: [
        'Lab-grown meat',
        'Insect protein',
        'Algae-based protein',
        'Fungal protein'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca80',
      question:
          'What became the defining issue of the 2024 US presidential election?',
      options: [
        'Universal basic income',
        'AI regulation',
        'Climate policy',
        'Healthcare reform'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca81',
      question:
          'Which ocean conservation initiative showed dramatic success in 2025?',
      options: [
        'Global fishing moratorium',
        'Plastics removal technology',
        'Artificial reef deployment',
        'Ocean acidification reversal'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca82',
      question:
          'What humanitarian technology helped mitigate refugee crises in 2025?',
      options: [
        'Digital identity systems',
        'Instant translation devices',
        'Humanitarian blockchain',
        'Portable water purification'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca83',
      question:
          'Which country became carbon-negative (removing more carbon than it emits) in 2025?',
      options: ['Bhutan', 'Norway', 'Costa Rica', 'Iceland'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca84',
      question: 'What development in space tourism occurred in 2025?',
      options: [
        'First hotel in low Earth orbit',
        'Lunar tourism packages',
        'Suborbital flights at commercial airline prices',
        'Zero-G theme park'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca85',
      question:
          'Which nation led global rankings in digital governance in 2025?',
      options: ['Estonia', 'Singapore', 'South Korea', 'United Arab Emirates'],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca86',
      question:
          'Which major international treaty on climate action succeeded the Paris Agreement in 2026?',
      options: [
        'Global Climate Compact',
        'New Earth Protocol',
        'Copenhagen Protocol',
        'Beijing Climate Accord'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'ca87',
      question:
          'What did the International Space Station transition into after its decommissioning in 2025?',
      options: [
        'Space museum',
        'Commercial research hub',
        'Deep space launch platform',
        'Orbital debris'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca88',
      question:
          'Which country pioneered universal neuro-rights legislation in 2025?',
      options: ['Switzerland', 'Chile', 'New Zealand', 'Finland'],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca89',
      question:
          'What major health innovation halved global cancer mortality rates by 2025?',
      options: [
        'Universal cancer screening AI',
        'Immunotherapy breakthroughs',
        'Personalized mRNA vaccines',
        'CRISPR-based early intervention'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca90',
      question:
          'Which social media platform was the first to receive over 5 billion active monthly users in 2025?',
      options: ['Instagram', 'TikTok', 'Discord', 'Meta Horizons'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'ca91',
      question:
          'What transportation technology broke commercial speed records in 2025?',
      options: [
        'Hyperloop networks',
        'Supersonic electric aircraft',
        'Autonomous shipping vessels',
        'Orbital point-to-point transport'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca92',
      question:
          'Which language became the most widely taught in global educational systems in 2025?',
      options: ['English', 'Mandarin', 'Spanish', 'Code literacy'],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'ca93',
      question:
          'What financial instrument gained universal recognition across central banks in 2025?',
      options: [
        'Central Bank Digital Currencies',
        'Carbon credits',
        'Universal Basic Income tokens',
        'International tax harmonization'
      ],
      correctOptionIndex: 0,
    ),
    MCQQuestion(
      id: 'ca94',
      question:
          'Which agricultural technology was credited with ending food insecurity in parts of Africa in 2025?',
      options: [
        'Vertical farming networks',
        'Autonomous drone farming',
        'Desert agriculture systems',
        'Cultured protein production'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca95',
      question:
          'What diplomatic breakthrough occurred in the Middle East in 2025?',
      options: [
        'Regional water sharing treaty',
        'Gulf Confederation formation',
        'Jerusalem international city agreement',
        'Comprehensive nuclear disarmament'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca96',
      question:
          'Which industry saw the largest workforce displacement due to automation in 2025?',
      options: [
        'Transportation',
        'Manufacturing',
        'Financial services',
        'Customer service'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca97',
      question: 'What became the most valuable global commodity in 2025?',
      options: [
        'Fresh water',
        'Personal data',
        'Rare earth elements',
        'Synthetic fertilizers'
      ],
      correctOptionIndex: 1,
    ),
    MCQQuestion(
      id: 'ca98',
      question:
          'Which infrastructure advancement significantly reduced urban congestion in major cities by 2025?',
      options: [
        'Elevated pedestrian networks',
        'Underground autonomous vehicle tunnels',
        'Smart traffic management systems',
        'Urban air mobility corridors'
      ],
      correctOptionIndex: 2,
    ),
    MCQQuestion(
      id: 'ca99',
      question:
          'What medical diagnostic tool became standard in homes worldwide in 2025?',
      options: [
        'AI symptom analysis apps',
        'Home blood analysis devices',
        'Virtual reality medical consultations',
        'Non-invasive health scanners'
      ],
      correctOptionIndex: 3,
    ),
    MCQQuestion(
      id: 'ca100',
      question:
          'Which ecosystem restoration project showed the most dramatic results in 2025?',
      options: [
        'Great Barrier Reef regeneration',
        'Amazon rainforest corridor',
        'Sahel greening initiative',
        'Arctic ice sheet stabilization'
      ],
      correctOptionIndex: 2,
    ),
  ];
}
