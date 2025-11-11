// import 'package:chatbox/Core/utils/app_router.dart';
// import 'package:chatbox/Features/calling/data/models/call_model.dart';
// import 'package:chatbox/Features/calling/presentation/manager/call/call_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';

// class IncomingCallWidget extends StatelessWidget {
//   final CallModel call;

//   const IncomingCallWidget({super.key, required this.call});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.black87,
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircleAvatar(
//                 radius: 50,
//                 backgroundColor: Colors.blue.shade100,
//                 child: Icon(
//                   call.callType == CallType.voice
//                       ? Icons.phone
//                       : Icons.videocam,
//                   size: 50,
//                   color: Colors.blue.shade900,
//                 ),
//               ),
//               const SizedBox(height: 24),

//               Text(
//                 'Incoming ${call.callType == CallType.voice ? 'Voice' : 'Video'} Call',
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 12),

//               Text(
//                 call.callerEmail,
//                 style: const TextStyle(fontSize: 18, color: Colors.white70),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 48),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Column(
//                     children: [
//                       FloatingActionButton(
//                         onPressed: () async {
//                           await context.read<CallCubit>().rejectCall(call);
//                         },
//                         backgroundColor: Colors.red,
//                         heroTag: 'reject',
//                         child: const Icon(Icons.call_end, size: 30),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Reject',
//                         style: TextStyle(color: Colors.white70),
//                       ),
//                     ],
//                   ),

//                   Column(
//                     children: [
//                       FloatingActionButton(
//                         onPressed: () async {
//                           await GoRouter.of(context).push(
//                             AppRouter.kVoiceCallViewRoute,
//                             extra: {
//                               'call': call,
//                               'localUserId': call.receiverId,
//                               'localUserName': call.receiverEmail,
//                             },
//                           );
//                         },
//                         backgroundColor: Colors.green,
//                         heroTag: 'accept',
//                         child: Icon(
//                           call.callType == CallType.voice
//                               ? Icons.phone
//                               : Icons.videocam,
//                           size: 30,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Accept',
//                         style: TextStyle(color: Colors.white70),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
