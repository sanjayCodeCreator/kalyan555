import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/features/home/home_api.dart';
import 'package:sm_project/utils/filecollection.dart';

class HomeBannerComponent extends StatelessWidget {
  const HomeBannerComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final refWatch = ref.watch(homeNotifierProvider);
      if (refWatch.value?.getParticularPlayerModel?.data?.betting == null ||
          refWatch.value?.getParticularPlayerModel?.data?.betting == false) {
        return const SizedBox();
      }
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder<(List<String>, double)>(
            future: HomeApi.getHomeBanner(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }
              final (data, aspectRatio) = snapshot.data ?? ([], 1.0);
              if (data.isEmpty) {
                return const SizedBox();
              }
              return Padding(
                padding: const EdgeInsets.all(0.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: FlutterCarousel(
                    options: FlutterCarouselOptions(
                      aspectRatio: aspectRatio,
                      showIndicator: true,
                      viewportFraction: 1,
                      autoPlay: true,
                      slideIndicator: CircularSlideIndicator(),
                    ),
                    items: data.map((i) {
                      return Image.network(
                        i,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                      );
                    }).toList(),
                  ),
                ),
              );
            }),
      );
    });
  }
}
