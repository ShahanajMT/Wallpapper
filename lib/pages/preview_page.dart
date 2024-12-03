// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:walpapper/repo/repository.dart';

class PreviewPage extends StatefulWidget {
  final String imageUrl;
  final int imageId;
  const PreviewPage({
    super.key,
    required this.imageUrl,
    required this.imageId,
  });

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  Repository repository = Repository();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: CachedNetworkImage(
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        imageUrl: widget.imageUrl,
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () {
          repository.downloadImage(imageUrl: widget.imageUrl, imageId: widget.imageId, context: context);
        },
        child: const Icon(Icons.download),
      ),
    );
  }
}
