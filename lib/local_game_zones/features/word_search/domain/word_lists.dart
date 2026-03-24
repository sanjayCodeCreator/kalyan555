/// Word lists for the Word Search game
/// Organized by categories for variety
class WordLists {
  /// Animals category
  static const List<String> animals = [
    'TIGER',
    'LION',
    'BEAR',
    'WOLF',
    'EAGLE',
    'SNAKE',
    'HORSE',
    'ZEBRA',
    'DEER',
    'FROG',
    'DUCK',
    'CROW',
    'SEAL',
    'CRAB',
    'FISH',
    'BIRD',
    'ELEPHANT',
    'GIRAFFE',
    'MONKEY',
    'RABBIT',
    'TURTLE',
    'PARROT',
    'DOLPHIN',
    'PENGUIN',
    'GORILLA',
    'LEOPARD',
    'CHEETAH',
    'BUFFALO',
  ];

  /// Colors category
  static const List<String> colors = [
    'RED',
    'BLUE',
    'GREEN',
    'GOLD',
    'PINK',
    'GRAY',
    'CYAN',
    'LIME',
    'ORANGE',
    'PURPLE',
    'YELLOW',
    'VIOLET',
    'SILVER',
    'BRONZE',
    'MAROON',
    'INDIGO',
    'CRIMSON',
    'EMERALD',
    'SCARLET',
    'MAGENTA',
  ];

  /// Foods category
  static const List<String> foods = [
    'RICE',
    'CAKE',
    'SOUP',
    'FISH',
    'MEAT',
    'CORN',
    'MILK',
    'BEAN',
    'PIZZA',
    'BREAD',
    'PASTA',
    'SALAD',
    'APPLE',
    'GRAPE',
    'MANGO',
    'BURGER',
    'CHEESE',
    'BANANA',
    'ORANGE',
    'COOKIE',
    'CARROT',
    'SANDWICH',
    'ICECREAM',
    'CHOCOLATE',
    'PANCAKE',
    'NOODLES',
  ];

  /// Sports category
  static const List<String> sports = [
    'GOLF',
    'RUN',
    'SWIM',
    'YOGA',
    'RIDE',
    'JUMP',
    'KICK',
    'THROW',
    'SOCCER',
    'TENNIS',
    'HOCKEY',
    'BOXING',
    'DIVING',
    'SURFING',
    'CRICKET',
    'BOWLING',
    'SKATING',
    'BASEBALL',
    'FOOTBALL',
    'VOLLEYBALL',
    'BASKETBALL',
    'GYMNASTICS',
    'WRESTLING',
  ];

  /// Nature category
  static const List<String> nature = [
    'SUN',
    'SKY',
    'SEA',
    'TREE',
    'LEAF',
    'ROCK',
    'SAND',
    'RAIN',
    'MOUNTAIN',
    'RIVER',
    'OCEAN',
    'FOREST',
    'FLOWER',
    'GARDEN',
    'STREAM',
    'ISLAND',
    'DESERT',
    'VALLEY',
    'CANYON',
    'MEADOW',
    'WATERFALL',
    'RAINBOW',
    'THUNDER',
    'VOLCANO',
    'GLACIER',
  ];

  /// Space category
  static const List<String> space = [
    'SUN',
    'MOON',
    'STAR',
    'MARS',
    'EARTH',
    'VENUS',
    'COMET',
    'PLANET',
    'GALAXY',
    'METEOR',
    'ROCKET',
    'SATURN',
    'NEBULA',
    'JUPITER',
    'MERCURY',
    'NEPTUNE',
    'URANUS',
    'ASTEROID',
    'SATELLITE',
    'TELESCOPE',
    'SPACESHIP',
    'UNIVERSE',
  ];

  /// School category
  static const List<String> school = [
    'BOOK',
    'DESK',
    'MATH',
    'TEST',
    'READ',
    'WRITE',
    'LEARN',
    'PENCIL',
    'ERASER',
    'PAPER',
    'RULER',
    'SCHOOL',
    'CLASS',
    'TEACHER',
    'STUDENT',
    'LIBRARY',
    'SCIENCE',
    'HISTORY',
    'HOMEWORK',
    'NOTEBOOK',
    'COMPUTER',
    'ALPHABET',
    'GEOGRAPHY',
  ];

  /// Technology category
  static const List<String> technology = [
    'APP',
    'WEB',
    'CODE',
    'DATA',
    'FILE',
    'WIFI',
    'EMAIL',
    'PHONE',
    'MOUSE',
    'SCREEN',
    'LAPTOP',
    'TABLET',
    'CAMERA',
    'PRINTER',
    'SPEAKER',
    'BATTERY',
    'MONITOR',
    'KEYBOARD',
    'SOFTWARE',
    'INTERNET',
    'COMPUTER',
    'DOWNLOAD',
    'BLUETOOTH',
  ];

  /// Music category
  static const List<String> music = [
    'SONG',
    'BEAT',
    'NOTE',
    'JAZZ',
    'ROCK',
    'DRUM',
    'BASS',
    'PIANO',
    'FLUTE',
    'VIOLA',
    'GUITAR',
    'VIOLIN',
    'SINGER',
    'RHYTHM',
    'MELODY',
    'HARMONY',
    'CONCERT',
    'TRUMPET',
    'ORCHESTRA',
    'SYMPHONY',
    'SAXOPHONE',
    'MICROPHONE',
  ];

  /// Weather category
  static const List<String> weather = [
    'HOT',
    'WET',
    'DRY',
    'FOG',
    'ICE',
    'COLD',
    'WARM',
    'WIND',
    'RAIN',
    'SNOW',
    'HAIL',
    'STORM',
    'SUNNY',
    'CLOUD',
    'FROST',
    'THUNDER',
    'RAINBOW',
    'TORNADO',
    'MONSOON',
    'DROUGHT',
    'HUMIDITY',
    'FORECAST',
    'BLIZZARD',
    'LIGHTNING',
    'HURRICANE',
  ];

  /// Kids-friendly words (shorter and simpler)
  static const List<String> kids = [
    'CAT',
    'DOG',
    'SUN',
    'HAT',
    'BAT',
    'CUP',
    'BUS',
    'CAR',
    'TOY',
    'BOX',
    'PEN',
    'BED',
    'EGG',
    'CAN',
    'MOM',
    'DAD',
    'BALL',
    'DOLL',
    'BOOK',
    'STAR',
    'TREE',
    'BIRD',
    'FISH',
    'FROG',
    'CAKE',
    'MILK',
    'RAIN',
    'SNOW',
    'MOON',
    'RING',
  ];

  /// Get all categories
  static List<List<String>> get allCategories => [
        animals,
        colors,
        foods,
        sports,
        nature,
        space,
        school,
        technology,
        music,
        weather,
      ];

  /// Get random words from all categories
  static List<String> getRandomWords(int count, int maxWordLength) {
    final allWords = <String>[];
    for (final category in allCategories) {
      allWords.addAll(category.where((w) => w.length <= maxWordLength));
    }

    // Shuffle and return requested count
    allWords.shuffle();
    return allWords.take(count).toList();
  }

  /// Get words suitable for a specific grid size
  static List<String> getWordsForGridSize(int gridSize, int count) {
    // Max word length is grid size - 1 to ensure words fit
    final maxLength = gridSize - 1;
    return getRandomWords(count, maxLength);
  }

  /// Get kids-friendly words
  static List<String> getKidsWords(int count) {
    final words = List<String>.from(kids);
    words.shuffle();
    return words.take(count).toList();
  }

  /// Get words from a specific category
  static List<String> getWordsFromCategory(
    List<String> category,
    int count,
    int maxWordLength,
  ) {
    final filtered = category.where((w) => w.length <= maxWordLength).toList();
    filtered.shuffle();
    return filtered.take(count).toList();
  }

  /// Daily word theme based on day of year
  static List<String> getDailyWords(int count, int maxWordLength) {
    final dayOfYear = DateTime.now()
        .difference(
          DateTime(DateTime.now().year, 1, 1),
        )
        .inDays;

    // Rotate through categories based on day
    final categoryIndex = dayOfYear % allCategories.length;
    final category = allCategories[categoryIndex];

    return getWordsFromCategory(category, count, maxWordLength);
  }
}
