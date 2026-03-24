import 'dart:developer';

import 'package:sm_project/controller/model/get_bids_history_model.dart';
import 'package:sm_project/utils/filecollection.dart';

final getbidsHistoryNotifierProvider =
    AsyncNotifierProvider.autoDispose<BidsHistoryNotifier, BidsHistoryMode>(() {
  return BidsHistoryNotifier();
});

class BidsHistoryMode {
  GetBidsHistoryModel? bidsHistoryModel = GetBidsHistoryModel();
  int? total;
  DateTime? fromDate;
  DateTime? toDate;
  int skip = 0;
  int count = 10;
  bool hasMore = true;
  bool isLoadingMore = false;
}

class BidsHistoryNotifier extends AutoDisposeAsyncNotifier<BidsHistoryMode> {
  final BidsHistoryMode _outputMode = BidsHistoryMode();

  // GetTransactionHistoryModel user

  void bidsHistoryModel(String query, {bool reset = true}) async {
    try {
      if (reset) {
        _outputMode.skip = 0;
        _outputMode.hasMore = true;
        EasyLoading.show(status: 'Loading...');
      } else {
        if (!_outputMode.hasMore || _outputMode.isLoadingMore) return;
        _outputMode.isLoadingMore = true;
        state = AsyncData(_outputMode);
      }

      // Add pagination parameters to query
      final String separator = query.contains('?') ? '&' : '?';
      final String paginatedQuery =
          '$query${separator}skip=${_outputMode.skip}&count=${_outputMode.count}';

      final result = await ApiService().getBidsHistory(paginatedQuery);

      if (result?.status == "success") {
        if (reset) {
          // Ensure uniqueness even when resetting
          _outputMode.bidsHistoryModel = result;
          // Apply toSet() to ensure uniqueness in the initial load
          if (_outputMode.bidsHistoryModel?.data?.betList != null) {
            _outputMode.bidsHistoryModel?.data?.betList = [
              ...{...(_outputMode.bidsHistoryModel?.data?.betList ?? [])}
            ];
          }
        } else {
          // Append new data to existing list and ensure uniqueness with toSet()
          final currentList = _outputMode.bidsHistoryModel?.data?.betList ?? [];
          final newList = result?.data?.betList ?? [];

          if (newList.isEmpty) {
            _outputMode.hasMore = false;
          } else {
            // Convert to Set and back to List to ensure uniqueness
            _outputMode.bidsHistoryModel?.data?.betList = [
              ...{...currentList, ...newList}
            ];
            _outputMode.skip += 1;
          }
        }

        // Update total count
        _outputMode.total = result?.data?.total;
      } else if (result?.status == "failure") {
        if (reset) {
          toast('Something went wrong');
        }
      }
    } catch (e) {
      log(e.toString(), name: 'getbidsHistoryNotifierProvider');
      // Handle error during loading more data
      if (!reset) {
        _outputMode.hasMore = false; // Prevent further loading attempts
        toast('Failed to load more data. Please try again later.');
      }
    } finally {
      if (reset) {
        EasyLoading.dismiss();
      } else {
        _outputMode.isLoadingMore = false;
      }
      state = AsyncData(_outputMode);
    }
  }

  void loadMore(String baseQuery) {
    // Check if we're already loading or if there's no more data to load
    if (_outputMode.isLoadingMore || !_outputMode.hasMore) return;

    // Call bidsHistoryModel with reset=false to load more data
    bidsHistoryModel(baseQuery, reset: false);
  }

  void retryLoading(String baseQuery) {
    // Reset hasMore flag to true to allow retry
    _outputMode.hasMore = true;
    // Reset isLoadingMore to false in case it was stuck
    _outputMode.isLoadingMore = false;
    // Update state to reflect changes
    state = AsyncData(_outputMode);
    // Call loadMore to retry loading data
    loadMore(baseQuery);
  }

  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (isFromDate) {
        _outputMode.fromDate = picked;
      } else {
        _outputMode.toDate = picked;
      }
    }
    state = AsyncData(_outputMode);
  }

  @override
  build() {
    return _outputMode;
  }
}
