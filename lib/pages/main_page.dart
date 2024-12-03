import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:walpapper/pages/preview_page.dart';
import 'package:walpapper/repo/repository.dart';

import '../model/model.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Repository repository = Repository();
  ScrollController scrollController = ScrollController();
  late Future<List<Images>> imagesList;
  int pageNumber = 1;

  TextEditingController textEditingController = TextEditingController();

  final List<String> categories = [
    "Nature",
    "Abstract",
    "Technology",
    "Mountains",
    "Cars",
    "Bike",
    "People",
    "Food",
  ];

  void getImageBySearch({required String query}) {
    imagesList = repository.getImagesBySearch(query: query);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    imagesList = repository.getImageList(pageNumber: pageNumber);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Wallpapper",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 20,
              ),
            ),
            Text(
              "App",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: textEditingController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp('[a-zA-Z0-9]'),
                  ),
                ],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 25),
                  labelText: 'Search',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: IconButton(
                        onPressed: () {
                          getImageBySearch(query: textEditingController.text);
                        },
                        icon: const Icon(Icons.search)),
                  ),
                ),
                onSubmitted: (value) {
                  getImageBySearch(query: value);
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (contex, index) {
                  return InkWell(
                    onTap: () {
                      getImageBySearch(query: categories[index]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0),
                          child: Center(
                            child: Text(
                              categories[index],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            FutureBuilder(
              future: imagesList,
              builder: (context, snapshort) {
                if (snapshort.connectionState == ConnectionState.done) {
                  if (snapshort.hasError) {
                    return const Center(
                      child: Text("Something went wrong"),
                    );
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: MasonryGridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          itemCount: snapshort.data!.length,
                          itemBuilder: (context, index) {
                            double height = (index % 10 + 1) * 100;
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PreviewPage(
                                      imageUrl: snapshort
                                          .data![index].imagePotraitPath,
                                      imageId: snapshort.data![index].imageID,
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  height: height > 300 ? 300 : height,
                                  imageUrl:
                                      snapshort.data![index].imagePotraitPath,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      MaterialButton(
                        minWidth: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        color: Colors.blue,
                        textColor: Colors.white,
                        onPressed: () {
                          pageNumber++;
                          imagesList =
                              repository.getImageList(pageNumber: pageNumber);
                          setState(() {});
                        },
                        child: const Text("Load More"),
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
