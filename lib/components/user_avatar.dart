import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:cragon/services/utilities.dart';
import 'package:cragon/services/firestore_data_handler.dart';


Widget userAvatarViaSnapshot({required String imageUrl, required double radius, double? fontSize}) {
  return imageUrl.isNotEmpty 
    ? Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 6, color: utilMainTextColor)
        ),
        child: CircleAvatar(
          radius: radius,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            imageBuilder: (context, imageProvider) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover
                  ),
                  shape: BoxShape.circle
                ),
              );
            },
            placeholder: (context, imageUrl) {
              return const CircularProgressIndicator();
            },
            errorWidget: (context, url, error) => const Icon(Icons.error)
          ),
        ),
      ) 
    : Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 6, color: utilMainTextColor)
      ),
      child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[300],
          child: Text(
            FirebaseAuth.instance.currentUser!.email.toString()[0].toUpperCase(),
            style: (fontSize == null) 
              ? const TextStyle(fontSize: 25)
              : TextStyle(fontSize: fontSize)
          ),
        ),
    );
}

Future<Widget> userAvatarViaFuture({required double radius, double? fontSize}) async {
  String imageUrl = await FirestoreDataHandler().getUserAvatarImage();
  return imageUrl.isNotEmpty 
    ? Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 6, color: utilMainTextColor)
        ),
        child: CircleAvatar(
          radius: radius,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            imageBuilder: (context, ImageProvider) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: ImageProvider,
                    fit: BoxFit.cover
                  ),
                  shape: BoxShape.circle
                ),
              );
            },
            placeholder: (context, imageUrl) {
              return const CircularProgressIndicator();
            },
            errorWidget: (context, url, error) => const Icon(Icons.error)
          ),
        ),
      ) 
    : Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 6, color: utilMainTextColor)
      ),
      child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[300],
          child: Text(
            FirebaseAuth.instance.currentUser!.email.toString()[0].toUpperCase(),
            style: (fontSize == null) 
              ? const TextStyle(fontSize: 25)
              : TextStyle(fontSize: fontSize)
          ),
        ),
    );
}