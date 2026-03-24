import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;
import 'package:dio/dio.dart';
import 'package:sm_project/controller/apiservices/api_constant.dart';
import 'package:sm_project/features/withdrawal_deposit_leaderboard/withdrawal_deposit_leaderboard_model.dart';
import 'package:sm_project/utils/filecollection.dart';

final withdrawalDepositLeaderboardNotifierProvider = AsyncNotifierProvider<
    WithdrawalDepositLeaderboardNotifier,
    WithdrawalDepositLeaderboardState>(() {
  return WithdrawalDepositLeaderboardNotifier();
});

class WithdrawalDepositLeaderboardState {
  List<String> messages = [];
  int currentIndex = 0;
  bool isLoading = false;

  // A monotonically increasing version used to force Riverpod rebuilds
  int _version = 0;

  void bumpVersion() => _version++;

  // Equality & hashCode include the version so each bump triggers UI updates
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WithdrawalDepositLeaderboardState &&
          other._version == _version);

  @override
  int get hashCode => _version.hashCode;
}

class WithdrawalDepositLeaderboardNotifier
    extends AsyncNotifier<WithdrawalDepositLeaderboardState> {
  final WithdrawalDepositLeaderboardState _state =
      WithdrawalDepositLeaderboardState();
  Timer? _timer;

  // 100 Indian full names for dummy data
  final List<String> indianNames = [
    'Rajesh Kumar',
    'Priya Sharma',
    'Amit Singh',
    'Sneha Patel',
    'Rahul Gupta',
    'Anjali Verma',
    'Vikram Reddy',
    'Pooja Iyer',
    'Arjun Nair',
    'Kavita Desai',
    'Sanjay Mehta',
    'Neha Agarwal',
    'Rohit Joshi',
    'Divya Kulkarni',
    'Karan Malhotra',
    'Ritu Kapoor',
    'Suresh Rao',
    'Meera Pillai',
    'Anil Yadav',
    'Swati Bose',
    'Manoj Sinha',
    'Preeti Bansal',
    'Deepak Choudhary',
    'Isha Saxena',
    'Vishal Chauhan',
    'Nidhi Mishra',
    'Ashok Tiwari',
    'Sunita Jain',
    'Ravi Dubey',
    'Geeta Pandey',
    'Nitin Thakur',
    'Alok Bhatt',
    'Seema Soni',
    'Mohit Arora',
    'Tanvi Ghosh',
    'Prakash Naidu',
    'Shilpa Menon',
    'Sachin Bajaj',
    'Anita Hegde',
    'Gaurav Shukla',
    'Rekha Trivedi',
    'Aditya Shah',
    'Madhuri Deshpande',
    'Vivek Bhatia',
    'Priyanka Kaur',
    'Harish Chandra',
    'Savita Goswami',
    'Kishore Das',
    'Pallavi Nambiar',
    'Manish Bhandari',
    'Lakshmi Krishnan',
    'Rajeev Chopra',
    'Sarita Rathore',
    'Naveen Kohli',
    'Usha Bhardwaj',
    'Pankaj Sood',
    'Archana Awasthi',
    'Sunil Dixit',
    'Vinita Saini',
    'Ajay Tomar',
    'Rashmi Tandon',
    'Sandeep Singhal',
    'Bharti Mittal',
    'Dinesh Varma',
    'Kamla Bisht',
    'Yogesh Rawat',
    'Poonam Dua',
    'Satish Gaur',
    'Kaveri Chaturvedi',
    'Hemant Bhagat',
    'Vaishali Khanna',
    'Ramesh Goyal',
    'Shobha Agnihotri',
    'Mukesh Sethi',
    'Anupama Pandya',
    'Jai Prakash',
    'Radha Vyas',
    'Sumit Pathak',
    'Nisha Anand',
    'Mahesh Dwivedi',
    'Lata Kashyap',
    'Sudhir Ojha',
    'Manju Tripathi',
    'Vijay Jha',
    'Urmila Rawal',
    'Krishna Murthy',
    'Gita Venkatesh',
    'Balaji Subramanian',
    'Lakshman Moorthy',
    'Padma Ranganathan',
    'Shankar Iyer',
    'Varalakshmi Srinivasan',
    'Ganesh Balakrishnan',
    'Saroja Natarajan',
    'Murali Ramachandran',
    'Janaki Sundaram',
    'Srinivas Iyengar',
    'Kamala Raman',
  ];

  @override
  WithdrawalDepositLeaderboardState build() {
    // Initialize and start the auto-cycling
    Future.microtask(() => fetchLeaderboardData());
    return _state;
  }

  Future<void> fetchLeaderboardData() async {
    try {
      _state.isLoading = true;
      state = AsyncData(_state);

      final dio = Dio();
      final response = await dio.get(
        '${APIConstants.baseUrl}app/transaction/today-summary',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
          },
        ),
      );

      if (response.statusCode == 200) {
        log('Leaderboard API Response: ${response.data}',
            name: 'WithdrawalDepositLeaderboard');
        final model = WithdrawalDepositLeaderboardModel.fromJson(response.data);

        if (model.status == "success" && model.data != null) {
          // Convert API data to messages
          List<String> apiMessages = model.data!.map((item) {
            String emoji = _getEmojiForType(item.type ?? '');
            String action = _getActionForType(item.type ?? '');
            return '${item.userName} $action ₹${item.amount} $emoji';
          }).toList();

          // Generate dummy messages
          List<String> dummyMessages = _generateDummyMessages();

          // Combine: API data first, then dummy data
          _state.messages = [...apiMessages, ...dummyMessages];
        } else {
          // If no API data, use only dummy messages
          _state.messages = _generateDummyMessages();
        }
      } else {
        log('Leaderboard API Error: ${response.statusMessage}',
            name: 'WithdrawalDepositLeaderboard');
        _state.messages = _generateDummyMessages();
      }
    } catch (e) {
      log('Leaderboard Error: $e', name: 'WithdrawalDepositLeaderboard');
      _state.messages = _generateDummyMessages();
    } finally {
      _state.isLoading = false;
      _state.bumpVersion();
      state = AsyncData(_state);
      _startTimer();
    }
  }

  List<String> _generateDummyMessages() {
    final random = Random();
    List<String> dummyMessages = [];

    // Shuffle the names to get random order
    List<String> shuffledNames = List.from(indianNames)..shuffle(random);

    // Generate messages for each name
    for (String name in shuffledNames) {
      // Randomly decide if it's withdrawal or deposit
      bool isWithdrawal = random.nextBool();
      // Generate random amount between 100 and 10000
      int amount = (random.nextInt(100) + 1) * 100;

      String action = isWithdrawal ? 'withdrew' : 'deposited';
      String emoji = isWithdrawal ? '💸' : '💰';

      dummyMessages.add('$name $action ₹$amount $emoji');
    }

    return dummyMessages;
  }

  String _getEmojiForType(String type) {
    switch (type.toLowerCase()) {
      case 'withdrawal':
        return '💸';
      case 'upi':
      case 'deposit':
        return '💰';
      default:
        return '🎉';
    }
  }

  String _getActionForType(String type) {
    switch (type.toLowerCase()) {
      case 'withdrawal':
        return 'withdrew';
      case 'upi':
      case 'deposit':
        return 'deposited';
      default:
        return 'won';
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_state.messages.isNotEmpty) {
        _state.currentIndex =
            (_state.currentIndex + 1) % _state.messages.length;
        _state.bumpVersion();
        state = AsyncData(_state);
      }
    });
  }

  void dispose() {
    _timer?.cancel();
  }

  // Method to manually refresh data
  Future<void> refresh() async {
    await fetchLeaderboardData();
  }
}
