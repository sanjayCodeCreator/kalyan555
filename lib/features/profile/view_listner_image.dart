// import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:sm_project/utils/filecollection.dart';

// class ListnerImage extends StatelessWidget {
//   final String? image;
//   final bool? imageApi;
//   final File? fileImage;
//   const ListnerImage(
//       {Key? key, this.image, this.imageApi = true, this.fileImage})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: whiteBackgroundColor,
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(
//               Icons.arrow_back,
//               color: Colors.white,
//             ),
//             onPressed: () => Navigator.pop(context),
//           ),
//           // actions: const [
//           // Consumer(builder: (context, ref, child) {
//           //   final refRead = ref.read(editProfileNotifierProvider.notifier);
//           //   return InkWell(
//           //       onTap: () {
//           //         refRead.showModal(context);
//           //       },
//           //       child: Icon(MdiIcons.pencil));
//           // }),
//           // const SizedBox(width: 20),
//           // ],
//         ),
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: InteractiveViewer(
//               alignment: Alignment.topLeft,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   imageApi == true
//                       ? Expanded(
//                           child: CachedNetworkImage(
//                             height: double.infinity,
//                             width: double.infinity,
//                             fit: BoxFit.fill,
//                             imageUrl: image ?? '',
//                             filterQuality: FilterQuality.medium,
//                             imageBuilder: (context, imageProvider) => Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(20),
//                                 image: DecorationImage(
//                                   image: imageProvider,
//                                   // fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             placeholder: (context, url) => Container(
//                               decoration:
//                                   const BoxDecoration(color: Colors.white),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(20),
//                                   child: Image.asset(
//                                     "assets/images/boarding3.png",
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             errorWidget: (context, url, error) => Container(
//                               decoration:
//                                   const BoxDecoration(color: Colors.white),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(20),
//                                   child: Image.asset(
//                                     "assets/images/boarding3.png",
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         )
//                       : imageApi == false && fileImage != null
//                           ? Expanded(
//                               child: Container(
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(20),
//                                       image: DecorationImage(
//                                         // fit: BoxFit.fill,
//                                         image: fileImage != null
//                                             ? FileImage(fileImage ?? File(''))
//                                             : FileImage(File('')),
//                                       ))),
//                             )
//                           : ClipRRect(
//                               borderRadius: BorderRadius.circular(20),
//                               child: Image.asset(
//                                 "assets/images/boarding3.png",
//                                 width: double.infinity,
//                                 height: double.infinity,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                 ],
//               ),
//             ),
//           ),
//         ));
//   }
// }
