import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PixabayPage(),
    );
  }
}

class PixabayPage extends StatefulWidget {
  const PixabayPage({Key? key}) : super(key: key);

  @override
  State<PixabayPage> createState() => _PixabayPageState();
}

class _PixabayPageState extends State<PixabayPage> {
  //空のstateを用意
  List hits = [];

  Future<void> fetchImages(String text) async {
    Response response = await Dio().get(
        'https://pixabay.com/api/?key=29402150-de7eba5f86a898a0b7aef18ba&q=$text&image_type=photo&per_page=100');
    hits = response.data['hits'];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    //最初に一度だけ実行
    fetchImages('sea');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextFormField(
            initialValue: '花',
            decoration: const InputDecoration(
              fillColor: Colors.white,
              filled: true,
            ),
            onFieldSubmitted: (text) {
              fetchImages(text);
            },
          ),
        ),
        body: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemCount: hits.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> hit = hits[index];
              return InkWell(
                onTap: () async {
                  // 1.urlから画像をダウンロード
                  Response response = await Dio().get(
                    hit['webformatURL'],
                    options: Options(responseType: ResponseType.bytes),
                  );
                  // 2.downloadしたdataをファイルに保存
                  Directory dir =
                      await getTemporaryDirectory(); //一時保存可能な領域のパスを取得
                  File file = await File('${dir.path}/image.png') //
                      .writeAsBytes(response.data);

                  // 3.shareパッケージを呼び出して共有
                  Share.shareFiles([file.path]);
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      hit['previewURL'],
                      fit: BoxFit.cover,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        color: Colors.white,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              size: 14,
                            ),
                            Text('${hit['likes']}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }));
  }
}
